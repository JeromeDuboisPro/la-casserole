extends Control

## The screen is the pot: a press anywhere that is not a control makes a noise.
##
## One action is visible by default, play. The settings sit behind a button and
## fold away as soon as playback starts, because they are set once before the
## phone goes into a pocket and only clutter the screen afterwards. Everything
## is drawn as symbols: the app is meant to be picked up in a street by someone
## who does not read French.
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
## Timer values in minutes, 0 meaning no limit. Infinity sits at the end
## because it is the longest setting, not the shortest, and the list wraps: no
## press ever does nothing, which is how a button reads as broken.
const TIMER_STEPS: Array[int] = [5, 10, 15, 20, 30, 45, 60, 0]
## Taps further apart than this are two sessions, not a rhythm.
const TEMPO_MAX_GAP_USEC := 3_000_000

const MIN_MARGIN := 48.0
const TOP_BUTTON_SIZE := 120.0
const AUTO_SIZE := 250.0
const SLIDER_HEIGHT := 180.0
## Room kept below the pot: enough for the countdown when the settings are
## folded, enough for the two rows when they are not. Reserving the larger
## figure at all times left the pot visibly high on the screen.
const POT_GAP_FOLDED := 90.0
const POT_GAP_OPEN := 380.0

@onready var _tap: TapCore = $TapCore
@onready var _bank: AudioBank = $AudioBank
@onready var _android: AndroidNoise = $AndroidNoise
@onready var _meter: Meter = $Meter
@onready var _pad: ColorRect = $Pad
@onready var _pot: TextureRect = $Pot
@onready var _auto_button: TextureButton = $Auto
@onready var _toggle_button: TextureButton = $Toggle
@onready var _settings: VBoxContainer = $Settings
@onready var _countdown: Label = $Countdown
@onready var _tempo_value: Label = $Settings/TempoRow/Value
@onready var _timer_value: Label = $Settings/TimerRow/Value
@onready var _lock_button: TextureButton = $Lock
@onready var _quit_button: TextureButton = $Quit
@onready var _unlock: UnlockSlider = $Unlock

var _noise: Node
var _bpm := DEFAULT_BPM
## Starts on the infinity entry: a tool does not stop unless asked to.
var _timer_index := TIMER_STEPS.size() - 1
var _auto := false
var _locked := false
var _settings_open := false
## Timestamps of the last taps, used to read the tempo off the hand.
var _tap_times: Array[int] = []
## Desktop and web have no plugin, so the countdown is kept here for them.
var _deadline_usec := 0

func _ready() -> void:
	_pad.color = SKIN_CASSEROLE.background_color
	_pot.texture = SKIN_CASSEROLE.sprite
	_setup_audio()
	_tap.blockers = [_settings, _auto_button, _toggle_button, _lock_button, _quit_button, _unlock]
	_tap.tapped.connect(_on_tapped)
	_meter.beat.connect(_on_beat)
	_auto_button.pressed.connect(_toggle_auto)
	_toggle_button.pressed.connect(_toggle_settings)
	$Settings/TempoRow/Less.pressed.connect(func(): _set_bpm(_bpm - BPM_STEP))
	$Settings/TempoRow/More.pressed.connect(func(): _set_bpm(_bpm + BPM_STEP))
	$Settings/TimerRow/Less.pressed.connect(func(): _step_timer(-1))
	$Settings/TimerRow/More.pressed.connect(func(): _step_timer(1))
	_lock_button.pressed.connect(_lock)
	_quit_button.pressed.connect(_on_quit_pressed)
	_unlock.unlocked.connect(_on_unlocked)
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

	_auto_button.offset_top = -(bottom + AUTO_SIZE)
	_auto_button.offset_bottom = -bottom
	_toggle_button.offset_top = -(bottom + AUTO_SIZE * 0.75)
	_toggle_button.offset_bottom = -(bottom + AUTO_SIZE * 0.75 - TOP_BUTTON_SIZE)
	_countdown.offset_top = -(bottom + AUTO_SIZE + 70.0)
	_countdown.offset_bottom = -(bottom + AUTO_SIZE + 10.0)
	_settings.offset_top = -(bottom + AUTO_SIZE + 330.0)
	_settings.offset_bottom = -(bottom + AUTO_SIZE + 90.0)
	_unlock.offset_top = -(bottom + SLIDER_HEIGHT)
	_unlock.offset_bottom = -bottom
	_pot.offset_top = top + TOP_BUTTON_SIZE + MIN_MARGIN
	_position_pot()

## The pot takes every pixel the controls are not using, so it is at its
## biggest in the state the app spends most of its time in.
func _position_pot(animate: bool = false) -> void:
	var window := DisplayServer.window_get_size()
	if window.y <= 0:
		return
	var safe := DisplayServer.get_display_safe_area()
	var scale := get_viewport_rect().size.y / float(window.y)
	var bottom: float = maxf((window.y - safe.position.y - safe.size.y) * scale, MIN_MARGIN)
	var gap := POT_GAP_OPEN if _settings_open else POT_GAP_FOLDED
	var target := -(bottom + AUTO_SIZE + gap)
	if not animate:
		_pot.offset_bottom = target
		return
	# A short ease, so the pot reads as making room rather than jumping.
	var tween := create_tween()
	tween.tween_property(_pot, "offset_bottom", target, 0.15).set_trans(Tween.TRANS_CUBIC)

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
	# The notification and the timer can both stop the auto mode while the app
	# is away, so the button follows the engine rather than the other way round.
	if _android.is_available():
		var running: bool = _android.is_auto_running()
		if running != _auto:
			_auto = running
			_refresh()
		_countdown.text = _format_remaining(_android.remaining_seconds())
	else:
		var left := 0.0
		if _auto and _deadline_usec > 0:
			left = maxf(0.0, (_deadline_usec - Time.get_ticks_usec()) / 1_000_000.0)
			if left <= 0.0:
				_auto = false
				_apply_auto(false)
				_refresh()
		_countdown.text = _format_remaining(left)

func _format_remaining(seconds: float) -> String:
	if seconds <= 0.0:
		return ""
	var total := int(ceilf(seconds))
	return "%d:%02d" % [total / 60, total % 60]

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

func _step_timer(direction: int) -> void:
	var count := TIMER_STEPS.size()
	_timer_index = (_timer_index + direction + count) % count
	_apply_timer()
	_refresh()

func _apply_timer() -> void:
	var seconds := TIMER_STEPS[_timer_index] * 60.0
	if _android.is_available():
		_android.set_timer(seconds)
		return
	_deadline_usec = 0
	if _auto and seconds > 0.0:
		_deadline_usec = Time.get_ticks_usec() + int(seconds * 1_000_000.0)

func _toggle_settings() -> void:
	_settings_open = not _settings_open
	_refresh()

func _toggle_auto() -> void:
	_auto = not _auto
	_apply_auto(_auto)
	# Starting playback is the moment the phone gets put away, so the screen
	# goes back to being just a pot.
	if _auto:
		_settings_open = false
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
		_apply_timer()
		return
	if enabled:
		_meter.bpm = _bpm
		_meter.start()
	else:
		_meter.stop()
	_apply_timer()

## The engine-side Meter only drives the desktop and web builds. On Android the
## tempo is kept by the plugin, which still ticks while the app is suspended.
func _on_beat() -> void:
	_noise.hit()

## Locking stops a pocket from pressing anything. Unlocking is a slide rather
## than a press, for the same reason, and because a knob with arrows on it says
## what to do without a word of any language.
func _lock() -> void:
	_locked = true
	_settings_open = false
	_refresh()

func _on_unlocked() -> void:
	_locked = false
	_refresh()

func _refresh() -> void:
	_auto_button.texture_normal = ICON_PAUSE if _auto else ICON_PLAY
	_auto_button.modulate = Color(0.90, 0.28, 0.30) if _auto else Color(1, 1, 1)
	_tempo_value.text = "%d" % roundi(_bpm)
	var minutes := TIMER_STEPS[_timer_index]
	_timer_value.text = "∞" if minutes == 0 else "%d min" % minutes
	_settings.visible = _settings_open and not _locked
	_position_pot(true)
	_toggle_button.modulate = Color(0.90, 0.28, 0.30) if _settings_open else Color(1, 1, 1)
	_toggle_button.visible = not _locked
	_auto_button.visible = not _locked
	_countdown.visible = not _locked
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
