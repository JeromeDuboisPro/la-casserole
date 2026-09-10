extends Control

## Day 1 harness: a grey rectangle that makes a noise. No visuals on purpose.
##
## The Android side of the audio (foreground service, screen-off playback) is
## not here: Godot suspends its scene tree when the app leaves the foreground,
## so background playback has to come from a native plugin. This scene is the
## foreground path, and the one the web export will use.

const SKIN_CASSEROLE := preload("res://skins/casserole.tres")

@onready var _tap: TapCore = $TapCore
@onready var _bank: AudioBank = $AudioBank
@onready var _meter: Meter = $Meter
@onready var _pad: ColorRect = $Pad

func _ready() -> void:
	_bank.samples = SKIN_CASSEROLE.samples
	_pad.color = SKIN_CASSEROLE.background_color
	_tap.tapped.connect(_on_tapped)
	_meter.beat.connect(_bank.hit)

func _on_tapped(timestamp_usec: int) -> void:
	# Audio first, before anything that could grow into UI work.
	_bank.hit()
	if OS.is_debug_build():
		var lag := (Time.get_ticks_usec() - timestamp_usec) / 1000.0
		print("tap -> play_stream: %.2f ms" % lag)
