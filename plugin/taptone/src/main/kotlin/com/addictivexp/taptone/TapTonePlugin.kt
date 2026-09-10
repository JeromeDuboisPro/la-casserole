package com.addictivexp.taptone

import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

/**
 * The Godot-facing side of the plugin. Thin on purpose: it marshals calls and
 * owns nothing.
 *
 * From GDScript:
 *     var tap_tone := Engine.get_singleton("TapTone")
 *     tap_tone.open()
 *     var id: int = tap_tone.load_sample("/data/.../bang_01.wav")
 *     tap_tone.play(id, 1.0, 1.0)
 *
 * Method names are matched verbatim by the engine, so they stay snake_case.
 */
class TapTonePlugin(godot: Godot) : GodotPlugin(godot) {

	override fun getPluginName(): String = "TapTone"

	@UsedByGodot
	fun open() {
		val context = activity?.applicationContext ?: return
		NoiseEngine.open(context)
	}

	/** Absolute path to a wav on disk. Returns the sample id, or 0 on failure. */
	@UsedByGodot
	fun load_sample(path: String): Int = NoiseEngine.load(path)

	/** How many samples finished loading. SoundPool decodes asynchronously. */
	@UsedByGodot
	fun ready_count(): Int = NoiseEngine.readyCount()

	/**
	 * @param volume linear gain, 0..1
	 * @param pitch playback rate, 0.5..2.0
	 */
	@UsedByGodot
	fun play(id: Int, volume: Float, pitch: Float) = NoiseEngine.play(id, volume, pitch)

	@UsedByGodot
	fun set_jitter(pitch: Float, volume: Float) = NoiseEngine.setJitter(pitch, volume)

	@UsedByGodot
	fun set_auto(enabled: Boolean, bpm: Float) {
		NoiseEngine.setAuto(enabled, bpm)
		// The notification is the only control left once the phone is pocketed,
		// so its play/pause icon has to follow the engine.
		activity?.applicationContext?.let { NoiseService.refresh(it) }
	}

	@UsedByGodot
	fun is_auto_running(): Boolean = NoiseEngine.isAutoRunning()

	/** Starts the foreground service that keeps playback alive off-screen. */
	@UsedByGodot
	fun start_background(title: String, text: String) {
		val context = activity?.applicationContext ?: return
		NoiseService.start(context, title, text)
	}

	@UsedByGodot
	fun stop_background() {
		val context = activity?.applicationContext ?: return
		NoiseService.stop(context)
	}

	override fun onMainDestroy() {
		val context = activity?.applicationContext
		if (context != null) NoiseService.stop(context)
		NoiseEngine.close()
		super.onMainDestroy()
	}
}
