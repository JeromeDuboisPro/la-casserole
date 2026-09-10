class_name TapCore
extends Node

## Turns raw pointer input into timestamped tap events. Nothing else.
##
## Reusable across projects: this node knows nothing about audio, visuals or
## game state. It only answers the question "when did a finger go down?".

## Emitted on touch DOWN, with the monotonic timestamp of the event.
signal tapped(timestamp_usec: int)

## Controls that swallow a press instead of making a sound. Without this the
## tap surface fires under every button, since _input runs before GUI dispatch.
var blockers: Array[Control] = []

func _input(event: InputEvent) -> void:
	# Deliberately handled in _input rather than through a Button pressed signal:
	# GUI dispatch adds a frame, and a frame is audible.
	if event is InputEventScreenTouch:
		if event.pressed:
			_fire(event.position)
	elif event is InputEventMouseButton:
		# Desktop editor only; mouse emulation from touch is disabled.
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_fire(event.position)

func _fire(position: Vector2) -> void:
	for blocker in blockers:
		if blocker.visible and blocker.get_global_rect().has_point(position):
			return
	tapped.emit(Time.get_ticks_usec())
	get_viewport().set_input_as_handled()
