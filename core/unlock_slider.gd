class_name UnlockSlider
extends Control

## Slide to unlock. Reusable, and deliberately the most universally understood
## unlock gesture there is: a pocket presses, it does not drag a knob across a
## track, and the chevrons say which way to go without a word.

signal unlocked

## How far along the track the knob must travel to count.
@export var travel_ratio: float = 0.85

@onready var _knob: TextureRect = $Knob
@onready var _chevrons: HBoxContainer = $Chevrons

var _dragging := false
var _touch_index := -1

func _ready() -> void:
	_reset()

## _gui_input hands positions in this control's own coordinates, not the
## viewport's, so every hit test below stays local.
func _grabbed(position: Vector2) -> bool:
	return Rect2(_knob.position, _knob.size).grow(60.0).has_point(position)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _grabbed(event.position):
			_dragging = true
			_touch_index = event.index
		elif not event.pressed and event.index == _touch_index:
			_release()
		accept_event()
	elif event is InputEventScreenDrag and _dragging and event.index == _touch_index:
		_move_to(event.position.x)
		accept_event()
	# The editor has no touchscreen, so the same gesture is accepted from a mouse.
	elif event is InputEventMouseButton:
		if event.pressed and _grabbed(event.position):
			_dragging = true
		elif not event.pressed:
			_release()
		accept_event()
	elif event is InputEventMouseMotion and _dragging:
		_move_to(event.position.x)
		accept_event()

func _move_to(local_x: float) -> void:
	var travel := _travel()
	_knob.position.x = clampf(local_x - _knob.size.x * 0.5, 0.0, travel)
	var progress: float = _knob.position.x / maxf(travel, 1.0)
	_chevrons.modulate.a = 1.0 - progress
	if progress >= travel_ratio:
		_dragging = false
		_reset()
		unlocked.emit()

func _travel() -> float:
	return maxf(size.x - _knob.size.x, 1.0)

func _release() -> void:
	_dragging = false
	_touch_index = -1
	# Not far enough: the knob goes home rather than staying half way, so the
	# gesture reads as one movement that either happened or did not.
	var tween := create_tween()
	tween.tween_property(_knob, "position:x", 0.0, 0.18).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(_chevrons, "modulate:a", 1.0, 0.18)

func _reset() -> void:
	_knob.position.x = 0.0
	_chevrons.modulate.a = 1.0

func _process(_delta: float) -> void:
	if _dragging:
		return
	# A slow pulse, so the track reads as something to act on rather than decor.
	var t := Time.get_ticks_msec() / 1000.0
	_chevrons.modulate.a = 0.45 + 0.35 * (0.5 + 0.5 * sin(t * 2.2))
