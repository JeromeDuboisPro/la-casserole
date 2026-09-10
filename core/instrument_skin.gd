class_name InstrumentSkin
extends Resource

## Everything specific to one instrument: its samples, its image, its palette.
## Swapping this resource is what turns Casserole into the next project.

@export var display_name: String = ""
@export var samples: Array[AudioStream] = []
@export var sprite: Texture2D
@export var background_color: Color = Color(0.12, 0.12, 0.12)
