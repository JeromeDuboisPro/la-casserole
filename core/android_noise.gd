class_name AndroidNoise
extends Node

## Godot-side handle on the TapTone Android plugin.
##
## On Android the sound does not come from the engine: Godot is suspended as
## soon as the app leaves the foreground, so playback lives in a native service
## instead. This node exposes the same hit() as AudioBank, so the rest of the
## app does not care which one it is talking to.

const PLUGIN_NAME := "TapTone"
const SAMPLE_DIR := "user://samples"

var _plugin: Object = null
var _ids: PackedInt32Array = []
var _next_index: int = 0

## True when the plugin answered. False on desktop and on the web build.
func is_available() -> bool:
	return _plugin != null

func _ready() -> void:
	if not Engine.has_singleton(PLUGIN_NAME):
		return
	_plugin = Engine.get_singleton(PLUGIN_NAME)
	_plugin.open()

## SoundPool reads files from disk, and the samples live inside the packed
## project, so they are written out to user:// and handed over by path.
##
## The file name carries a hash of the sample data. An earlier version wrote
## "sample_00.wav" once and skipped the write whenever the file already
## existed, so every later build kept playing whatever the first install had
## extracted, however many times the samples were replaced in the project.
func load_samples(streams: Array[AudioStream]) -> void:
	if _plugin == null:
		return
	DirAccess.make_dir_recursive_absolute(SAMPLE_DIR)
	var written: Array[String] = []
	for i in streams.size():
		var wav := streams[i] as AudioStreamWAV
		if wav == null:
			push_warning("TapTone only takes wav samples, skipping index %d" % i)
			continue
		var path := "%s/sample_%02d_%s.wav" % [SAMPLE_DIR, i, _digest(wav)]
		written.append(path.get_file())
		if not FileAccess.file_exists(path):
			var err := wav.save_to_wav(path)
			if err != OK:
				push_error("could not write %s: %d" % [path, err])
				continue
		var id: int = _plugin.load_sample(ProjectSettings.globalize_path(path))
		if id != 0:
			_ids.append(id)
		if OS.is_debug_build():
			print("sample %d -> %s (id %d)" % [i, path.get_file(), id])
	_purge_except(written)

## Short content hash, so replacing a sample changes the file name.
static func _digest(wav: AudioStreamWAV) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(wav.data)
	return ctx.finish().hex_encode().substr(0, 12)

## Samples from previous builds would otherwise pile up in the app data.
func _purge_except(keep: Array[String]) -> void:
	var dir := DirAccess.open(SAMPLE_DIR)
	if dir == null:
		return
	for file in dir.get_files():
		if not keep.has(file):
			dir.remove(file)

## How many samples SoundPool finished decoding. It loads asynchronously.
func ready_count() -> int:
	return _plugin.ready_count() if _plugin != null else 0

func hit() -> void:
	if _plugin == null or _ids.is_empty():
		return
	var id := _ids[_next_index]
	_next_index = (_next_index + 1) % _ids.size()
	# The jitter is applied natively, so an auto beat fired while the app is
	# suspended sounds exactly like a tap.
	_plugin.play(id, 1.0, 1.0)

func set_jitter(pitch: float, volume: float) -> void:
	if _plugin != null:
		_plugin.set_jitter(pitch, volume)

## The notification can start or pause the auto mode behind the app's back, so
## the UI reads the state from the plugin rather than assuming it owns it.
func is_auto_running() -> bool:
	return _plugin.is_auto_running() if _plugin != null else false

func set_auto(enabled: bool, bpm: float) -> void:
	if _plugin != null:
		_plugin.set_auto(enabled, bpm)

## The countdown lives in the plugin: a timer kept in the scene tree would stop
## counting the moment Android suspends the app.
func set_timer(seconds: float) -> void:
	if _plugin != null:
		_plugin.set_timer(seconds)

func remaining_seconds() -> float:
	return _plugin.remaining_seconds() if _plugin != null else 0.0

func start_background(title: String, text: String) -> void:
	if _plugin != null:
		_plugin.start_background(title, text)

func stop_background() -> void:
	if _plugin != null:
		_plugin.stop_background()
