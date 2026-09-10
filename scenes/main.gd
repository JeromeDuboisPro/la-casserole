extends Control

## Day 1 harness: a grey rectangle that makes a noise. No visuals on purpose.
##
## Two playback backends, picked at startup:
## - on Android, the TapTone plugin (SoundPool inside a foreground service),
##   because Godot suspends its scene tree the moment the app leaves the
##   foreground and the noise has to survive a pocket;
## - everywhere else, the engine's own AudioBank.
## Both answer hit(), so nothing below this line knows which one is live.

const SKIN_CASSEROLE := preload("res://skins/casserole.tres")

@onready var _tap: TapCore = $TapCore
@onready var _bank: AudioBank = $AudioBank
@onready var _android: AndroidNoise = $AndroidNoise
@onready var _meter: Meter = $Meter
@onready var _pad: ColorRect = $Pad
@onready var _pot: TextureRect = $Pot

var _noise: Node

## Day 1 scaffolding: with no UI yet, a double tap is the only way to start the
## auto mode and check that it keeps beating with the screen off. Goes away
## when the real controls land.
const DOUBLE_TAP_USEC := 300_000
const TEST_BPM := 120.0
var _last_tap_usec: int = 0
var _android_auto: bool = false

func _ready() -> void:
	_pad.color = SKIN_CASSEROLE.background_color
	_pot.texture = SKIN_CASSEROLE.sprite
	_setup_audio()
	_tap.tapped.connect(_on_tapped)
	_meter.beat.connect(_on_beat)
	if OS.is_debug_build():
		print("backend=%s" % _noise.name)

func _setup_audio() -> void:
	if _android.is_available():
		# Android 13+ hides the notification without this, and a foreground
		# service with no visible notification is a bad citizen.
		if not OS.request_permission("android.permission.POST_NOTIFICATIONS"):
			push_warning("notification permission refused")
		_android.load_samples(SKIN_CASSEROLE.samples)
		_android.start_background(SKIN_CASSEROLE.display_name, "En cours")
		_noise = _android
		# The engine mixer would otherwise keep an output stream open for
		# nothing, and show up as a second player in the system audio dump.
		_bank.queue_free()
		return

	_bank.samples = SKIN_CASSEROLE.samples
	_noise = _bank
	if OS.is_debug_build():
		print("audio driver=%s output_latency=%.1f ms mix_rate=%d" % [
			AudioServer.get_driver_name(),
			AudioServer.get_output_latency() * 1000.0,
			AudioServer.get_mix_rate(),
		])

func _on_tapped(timestamp_usec: int) -> void:
	# Audio first, before anything that could grow into UI work.
	_noise.hit()
	if OS.is_debug_build():
		if timestamp_usec - _last_tap_usec < DOUBLE_TAP_USEC:
			_toggle_auto()
			_last_tap_usec = 0
		else:
			_last_tap_usec = timestamp_usec
	if OS.is_debug_build():
		var lag := (Time.get_ticks_usec() - timestamp_usec) / 1000.0
		print("tap -> play: %.2f ms" % lag)

func _toggle_auto() -> void:
	if _android.is_available():
		var running := not _android_auto
		_android_auto = running
		_android.set_auto(running, TEST_BPM)
		print("auto=%s (native)" % running)
		return
	if _meter.is_running():
		_meter.stop()
	else:
		_meter.bpm = TEST_BPM
		_meter.start()
	print("auto=%s (engine)" % _meter.is_running())

## The engine-side Meter only drives the desktop and web builds. On Android the
## tempo is kept by the plugin, which still ticks while the app is suspended.
func _on_beat() -> void:
	_noise.hit()
