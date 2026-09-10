extends Control

## The whole screen is the pot: a press anywhere that is not a control makes a
## noise. The controls sit in a row at the bottom, drawn as symbols rather than
## words, because this is meant to be picked up in a street by someone who does
## not read French.
##
## Two playback backends, picked at startup:
## - on Android, the TapTone plugin (SoundPool inside a foreground service),
##   because Godot suspends its scene tree the moment the app leaves the
##   foreground and the noise has to survive a pocket;
## - everywhere else, the engine's own AudioBank.
## Both answer hit(), so nothing below this line knows which one is live.

const SKIN_CASSEROLE := preload("res://skins/casserole.tres")

const ICON_PLAY := preload("res://assets/icons/ui/play.svg")
const ICON_PAUSE := preload("res://assets/icons/ui/pause.svg")

const DEFAULT_BPM := 120.0
const MIN_BPM := 30.0
const MAX_BPM := 300.0
const BPM_STEP := 10.0
const MIN_MARGIN := 48.0
const TOP_BUTTON_SIZE := 120.0
const BAR_HEIGHT := 190.0
const SLIDER_HEIGHT := 180.0
## Taps further apart than this are two sessions, not a rhythm.
const TEMPO_MAX_GAP_USEC := 3_000_000

@onready var _tap: TapCore = $TapCore
@onready var _bank: AudioBank = $AudioBank
@onready var _android: AndroidNoise = $AndroidNoise
@onready var _meter: Meter = $Meter
@onready var _pad: ColorRect = $Pad
@onready var _pot: TextureRect = $Pot
@onready var _bar: HBoxContainer = $Bar
@onready var _auto_button: TextureButton = $Bar/Auto
@onready var _bpm_label: Label = $Bar/Bpm
@onready var _lock_button: TextureButton = $Lock
@onready var _quit_button: TextureButton = $Quit
@onready var _unlock: UnlockSlider = $Unlock

var _noise: Node
var _bpm := DEFAULT_BPM
var _auto := false
var _locked := false
## Timestamps of the last taps, used to read the tempo off the hand.
var _tap_times: Array[int] = []

func _ready() -> void:
	_pad.color = SKIN_CASSEROLE.background_color
	_pot.texture = SKIN_CASSEROLE.sprite
	_setup_audio()
	_tap.blockers = [_bar, _lock_button, _quit_button, _unlock]
	_tap.tapped.connect(_on_tapped)
	_meter.beat.connect(_on_beat)
	_auto_button.pressed.connect(_toggle_auto)
	$Bar/Slower.pressed.connect(func(): _set_bpm(_bpm - BPM_STEP))
	$Bar/Faster.pressed.connect(func(): _set_bpm(_bpm + BPM_STEP))
	_lock_button.pressed.connect(_lock)
	_unlock.unlocked.connect(_on_unlocked)
	_quit_button.pressed.connect(_on_quit_pressed)
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	_refresh()

## Keeps the controls clear of the camera cutout at the top and of the gesture
## bar at the bottom. Without this the lock sits under the front camera on any
## phone with a notch.
func _apply_safe_area() -> void:
	var window := DisplayServer.window_get_size()
	if window.y <= 0:
		return
	var safe := DisplayServer.get_display_safe_area()
	# The scene is laid out in canvas units, the insets come back in screen
	# pixels, and the stretch between them is whatever the device imposes.
	var scale := get_viewport_rect().size.y / float(window.y)
	var top: float = maxf(safe.position.y * scale, MIN_MARGIN)
	var bottom: float = maxf((window.y - safe.position.y - safe.size.y) * scale, MIN_MARGIN)

	for button in [_lock_button, _quit_button]:
		button.offset_top = top
		button.offset_bottom = top + TOP_BUTTON_SIZE

	_bar.offset_top = -(bottom + BAR_HEIGHT)
	_bar.offset_bottom = -bottom
	_unlock.offset_top = -(bottom + SLIDER_HEIGHT)
	_unlock.offset_bottom = -bottom
	_pot.offset_top = top + TOP_BUTTON_SIZE + MIN_MARGIN
	_pot.offset_bottom = -(bottom + SLIDER_HEIGHT + MIN_MARGIN)

func _setup_audio() -> void:
	if _android.is_available():
		# Android 13+ hides the notification without this, and a foreground
		# service with no visible notification is a bad citizen.
		if not OS.request_permission("android.permission.POST_NOTIFICATIONS"):
			push_warning("notification permission refused")
		_android.load_samples(SKIN_CASSEROLE.samples)
		_noise = _android
		# The engine mixer would otherwise keep an output stream open for
		# nothing, and show up as a second player in the system audio dump.
		_bank.queue_free()
		return

	_bank.samples = SKIN_CASSEROLE.samples
	_noise = _bank

func _process(_delta: float) -> void:
	# The notification can pause or stop the auto mode while the app is away,
	# so the button follows the engine rather than the other way round.
	if _android.is_available():
		var running: bool = _android.is_auto_running()
		if running != _auto:
			_auto = running
			_refresh()

func _on_tapped(timestamp_usec: int) -> void:
	if _locked:
		return
	# Audio first, before anything that could grow into UI work.
	_noise.hit()
	_remember_tap(timestamp_usec)

## Keeps the last few intervals, so pressing play repeats the rhythm just
## played instead of asking for a number.
func _remember_tap(timestamp_usec: int) -> void:
	if not _tap_times.is_empty() and timestamp_usec - _tap_times[-1] > TEMPO_MAX_GAP_USEC:
		_tap_times.clear()
	_tap_times.append(timestamp_usec)
	if _tap_times.size() > 5:
		_tap_times.pop_front()
	var tapped_bpm := _tapped_bpm()
	if tapped_bpm > 0.0:
		_set_bpm(tapped_bpm)

func _tapped_bpm() -> float:
	if _tap_times.size() < 3:
		return 0.0
	var intervals: Array[float] = []
	for i in range(1, _tap_times.size()):
		intervals.append(float(_tap_times[i] - _tap_times[i - 1]))
	intervals.sort()
	var median: float = intervals[intervals.size() / 2]
	if median <= 0.0:
		return 0.0
	return clampf(60_000_000.0 / median, MIN_BPM, MAX_BPM)

func _set_bpm(value: float) -> void:
	_bpm = clampf(value, MIN_BPM, MAX_BPM)
	if _auto:
		_apply_auto(true)
	_refresh()

func _toggle_auto() -> void:
	_auto = not _auto
	if OS.is_debug_build():
		print("auto -> %s at %d bpm" % [_auto, roundi(_bpm)])
	_apply_auto(_auto)
	_refresh()

func _apply_auto(enabled: bool) -> void:
	if _android.is_available():
		# The service exists to outlive the screen, so it comes up with the auto
		# mode rather than with the app: no notification until there is
		# something to keep alive. Stop from the notification tears it down, and
		# playing again brings it back.
		if enabled:
			_android.start_background(SKIN_CASSEROLE.display_name, "")
		_android.set_auto(enabled, _bpm)
		return
	if enabled:
		_meter.bpm = _bpm
		_meter.start()
	else:
		_meter.stop()

## The engine-side Meter only drives the desktop and web builds. On Android the
## tempo is kept by the plugin, which still ticks while the app is suspended.
func _on_beat() -> void:
	_noise.hit()

## Locking stops a pocket from pressing anything. Unlocking is a slide rather
## than a press, for the same reason, and because a knob with arrows on it says
## what to do without a word of any language.
func _lock() -> void:
	_locked = true
	_refresh()

func _on_unlocked() -> void:
	_locked = false
	_refresh()

func _refresh() -> void:
	_auto_button.texture_normal = ICON_PAUSE if _auto else ICON_PLAY
	_auto_button.modulate = Color(0.90, 0.28, 0.30) if _auto else Color(1, 1, 1)
	_bpm_label.text = "%d" % roundi(_bpm)
	_bar.visible = not _locked
	_quit_button.visible = not _locked
	_lock_button.visible = not _locked
	_unlock.visible = _locked
	_pot.modulate = Color(1, 1, 1, 0.35) if _locked else Color(1, 1, 1, 1)

## Leaving has to silence the phone, not just close the window: the plugin
## keeps a foreground service and a wake lock alive on purpose, and they
## outlive the app unless something stops them.
func _on_quit_pressed() -> void:
	_silence()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST or what == NOTIFICATION_WM_CLOSE_REQUEST:
		# While locked, back is the emergency exit from the lock, not from the app.
		if _locked:
			_locked = false
			_refresh()
			return
		# Otherwise it takes the same road as the quit button.
		_silence()
		get_tree().quit()

func _silence() -> void:
	if _android.is_available():
		_android.set_auto(false, _bpm)
		_android.stop_background()
	elif _meter.is_running():
		_meter.stop()
