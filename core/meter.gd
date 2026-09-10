class_name Meter
extends Node

## Auto mode: emits a beat at a fixed tempo.
##
## Scheduled against the monotonic clock rather than accumulated _process
## deltas, so the tempo does not drift with the frame rate and a dropped frame
## does not swallow a beat.

signal beat

## Hits per minute.
@export var bpm: float = 120.0:
	set(value):
		bpm = clampf(value, 20.0, 480.0)

var _running: bool = false
var _next_usec: int = 0

func start() -> void:
	_next_usec = Time.get_ticks_usec()
	_running = true

func stop() -> void:
	_running = false

func is_running() -> bool:
	return _running

func _process(_delta: float) -> void:
	if not _running:
		return
	var period_usec := int(60.0 / bpm * 1_000_000.0)
	var now := Time.get_ticks_usec()
	# A long stall (app resumed, editor paused) must not fire the whole backlog.
	if now - _next_usec > 1_000_000:
		_next_usec = now
	while now >= _next_usec:
		beat.emit()
		_next_usec += period_usec
