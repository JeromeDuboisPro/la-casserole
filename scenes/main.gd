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
const ICON_LOCK := preload("res://assets/icons/ui/lock.svg")
const ICON_UNLOCK := preload("res://assets/icons/ui/unlock.svg")

const DEFAULT_BPM := 120.0
const MIN_BPM := 30.0
const MAX_BPM := 300.0
const BPM_STEP := 10.0
## Taps further apart than this are two sessions, not a rhythm.
const TEMPO_MAX_GAP_USEC := 3_000_000
const UNLOCK_HOLD_SEC := 0.8

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

var _noise: Node
var _bpm := DEFAULT_BPM
var _auto := false
var _locked := false
## Timestamps of the last taps, used to read the tempo off the hand.
var _tap_times: Array[int] = []
var _lock_held_since_usec := 0
## BaseButton.button_pressed only tracks toggle buttons, so the hold is tracked here.
var _lock_held := false
## Set when a hold has already unlocked, so releasing it does not lock again.
var _lock_consumed := false

func _ready() -> void:
	_pad.color = SKIN_CASSEROLE.background_color
	_pot.texture = SKIN_CASSEROLE.sprite
	_setup_audio()
	_tap.blockers = [_bar, _lock_button, _quit_button]
	_tap.tapped.connect(_on_tapped)
	_meter.beat.connect(_on_beat)
	_auto_button.pressed.connect(_toggle_auto)
	$Bar/Slower.pressed.connect(func(): _set_bpm(_bpm - BPM_STEP))
	$Bar/Faster.pressed.connect(func(): _set_bpm(_bpm + BPM_STEP))
	_lock_button.button_down.connect(_on_lock_down)
	_lock_button.button_up.connect(_on_lock_up)
	_quit_button.pressed.connect(_on_quit_pressed)
	_refresh()

func _setup_audio() -> void:
	if _android.is_available():
		# Android 13+ hides the notification without this, and a foreground
		# service with no visible notification is a bad citizen.
		if not OS.request_permission("android.permission.POST_NOTIFICATIONS"):
			push_warning("notification permission refused")
		_android.load_samples(SKIN_CASSEROLE.samples)
		_android.start_background(SKIN_CASSEROLE.display_name, "")
		_noise = _android
		# The engine mixer would otherwise keep an output stream open for
		# nothing, and show up as a second player in the system audio dump.
		_bank.queue_free()
		return

	_bank.samples = SKIN_CASSEROLE.samples
	_noise = _bank

func _process(_delta: float) -> void:
	_update_unlock_feedback()
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

## Locking hides the controls so a pocket cannot press them. Unlocking asks for
## a deliberate hold, for the same reason: one accidental press must not undo it.
##
## The hold has to announce itself. A lock with no way out that a user can see
## is worse than no lock at all, so the padlock fills up while it is held, and
## the back gesture is kept as a way out.
func _on_lock_down() -> void:
	_lock_held_since_usec = Time.get_ticks_usec()
	_lock_held = true
	_lock_consumed = false

func _on_lock_up() -> void:
	# A hold that already unlocked must not be read as a fresh press, or the
	# release locks the app straight back and the hold looks broken.
	if not _lock_consumed:
		if not _locked:
			_locked = true
		elif _unlock_progress() >= 1.0:
			_locked = false
	_lock_held = false
	_lock_consumed = false
	_lock_held_since_usec = 0
	_refresh()

func _unlock_progress() -> float:
	if not _lock_held or _lock_held_since_usec == 0:
		return 0.0
	var held := (Time.get_ticks_usec() - _lock_held_since_usec) / 1_000_000.0
	return clampf(held / UNLOCK_HOLD_SEC, 0.0, 1.0)

func _update_unlock_feedback() -> void:
	if not _locked:
		return
	var progress := _unlock_progress()
	# Grows and reddens as the hold approaches release, so the way out is
	# visible from the first tenth of a second.
	_lock_button.scale = Vector2.ONE * (1.0 + 0.25 * progress)
	_lock_button.pivot_offset = _lock_button.size * 0.5
	_lock_button.modulate = Color(1, 1, 1).lerp(Color(0.90, 0.28, 0.30), progress)
	if progress >= 1.0 and _lock_held:
		_locked = false
		_lock_consumed = true
		_lock_held_since_usec = 0
		_refresh()

func _refresh() -> void:
	_auto_button.texture_normal = ICON_PAUSE if _auto else ICON_PLAY
	_auto_button.modulate = Color(0.90, 0.28, 0.30) if _auto else Color(1, 1, 1)
	_bpm_label.text = "%d" % roundi(_bpm)
	_bar.visible = not _locked
	_quit_button.visible = not _locked
	_lock_button.texture_normal = ICON_LOCK if _locked else ICON_UNLOCK
	_lock_button.scale = Vector2.ONE
	_lock_button.modulate = Color(1, 1, 1)
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
			_lock_held_since_usec = 0
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
