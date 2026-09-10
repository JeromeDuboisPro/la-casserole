class_name TapCore
extends Node

## Turns raw pointer input into timestamped tap events. Nothing else.
##
## Reusable across projects: this node knows nothing about audio, visuals or
## game state. It only answers the question "when did a finger go down?".

## Emitted on touch DOWN, with the monotonic timestamp of the event.
signal tapped(timestamp_usec: int)

func _input(event: InputEvent) -> void:
	# Deliberately handled in _input rather than through a Button pressed signal:
	# GUI dispatch adds a frame, and a frame is audible.
	if event is InputEventScreenTouch:
		if event.pressed:
			_fire()
	elif event is InputEventMouseButton:
		# Desktop editor only; mouse emulation from touch is disabled.
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_fire()

func _fire() -> void:
	tapped.emit(Time.get_ticks_usec())
	get_viewport().set_input_as_handled()
