class_name AudioBank
extends Node

## Plays the hit samples through a single polyphonic voice pool.
##
## Reusable across projects. One AudioStreamPolyphonic is started once and kept
## running, so a hit costs one play_stream() call and allocates nothing.

## Samples cycled round-robin, one per hit.
@export var samples: Array[AudioStream] = []
## Overlapping voices. A fast hand plus a long tail needs headroom.
@export var max_voices: int = 24
## Random pitch spread per hit. Without it, fast tapping sounds like a machine gun.
@export var pitch_jitter: float = 0.06
## Random attenuation per hit, in dB. Same reason.
@export var volume_jitter_db: float = 1.5
## Software volume boost, set from the UI. Positive values clip on purpose.
@export var volume_boost_db: float = 0.0

var _player: AudioStreamPlayer
var _playback: AudioStreamPlaybackPolyphonic
var _next_index: int = 0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	var poly := AudioStreamPolyphonic.new()
	poly.polyphony = max_voices
	_player = AudioStreamPlayer.new()
	_player.stream = poly
	add_child(_player)
	# The stream runs forever and stays silent until a sample is pushed into it.
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamPlaybackPolyphonic

func hit() -> void:
	if samples.is_empty() or _playback == null:
		return
	var sample: AudioStream = samples[_next_index]
	_next_index = (_next_index + 1) % samples.size()
	var pitch := 1.0 + _rng.randf_range(-pitch_jitter, pitch_jitter)
	# Jitter only downwards, so the boost stays the ceiling.
	var volume := volume_boost_db + _rng.randf_range(-volume_jitter_db, 0.0)
	_playback.play_stream(sample, 0.0, volume, pitch)
