package com.addictivexp.taptone

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.os.Handler
import android.os.HandlerThread
import android.os.SystemClock
import android.util.Log
import kotlin.math.pow
import kotlin.random.Random

/**
 * Plays short samples through SoundPool, and can beat them at a fixed tempo on
 * its own thread.
 *
 * This is where the sound lives on Android, rather than in the engine, because
 * Godot suspends its scene tree as soon as the app leaves the foreground. A
 * single playback path means the app sounds the same whether the screen is on
 * or in a pocket.
 *
 * It is deliberately ignorant of the app using it: samples arrive as file paths.
 */
object NoiseEngine {

	private const val TAG = "TapTone"
	private const val MAX_STREAMS = 24

	private var pool: SoundPool? = null
	/** Sample ids in load order, cycled round-robin by the auto mode. */
	private val loaded = mutableListOf<Int>()
	private val ready = mutableSetOf<Int>()

	private var thread: HandlerThread? = null
	private var handler: Handler? = null

	private var autoRunning = false
	private var periodMs = 500L
	private var nextBeatAt = 0L
	private var nextIndex = 0

	private var pitchJitter = 0.06f
	private var volumeJitter = 0.12f

	@Synchronized
	fun open(context: Context) {
		if (pool != null) return
		val attributes = AudioAttributes.Builder()
			// MEDIA rather than GAME: a protest tool should behave like a player,
			// keep playing with the screen off, and follow the media volume.
			.setUsage(AudioAttributes.USAGE_MEDIA)
			.setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
			.build()
		pool = SoundPool.Builder()
			.setMaxStreams(MAX_STREAMS)
			.setAudioAttributes(attributes)
			.build()
			.also { sp ->
				sp.setOnLoadCompleteListener { _, sampleId, status ->
					if (status == 0) {
						synchronized(this) { ready.add(sampleId) }
					} else {
						Log.w(TAG, "sample $sampleId failed to load, status $status")
					}
				}
			}
		val thread = HandlerThread("TapTone", android.os.Process.THREAD_PRIORITY_URGENT_AUDIO)
		thread.start()
		this.thread = thread
		handler = Handler(thread.looper)
		context.applicationContext.getSystemService(Context.AUDIO_SERVICE) // touch, so the service is up
	}

	/** Loads a sample from an absolute file path. Returns its id, or 0 on failure. */
	@Synchronized
	fun load(path: String): Int {
		val sp = pool ?: return 0
		val id = sp.load(path, 1)
		if (id != 0) loaded.add(id)
		return id
	}

	/**
	 * @param volume linear gain, 0..1
	 * @param pitch playback rate, 0.5..2.0
	 */
	fun play(id: Int, volume: Float, pitch: Float) {
		val sp = pool ?: return
		if (!isReady(id)) return
		val v = volume.coerceIn(0f, 1f)
		sp.play(id, v, v, 1, 0, pitch.coerceIn(0.5f, 2.0f))
	}

	@Synchronized
	private fun isReady(id: Int): Boolean = ready.contains(id)

	@Synchronized
	fun readyCount(): Int = ready.size

	/** One hit with the jitter applied, cycling through the loaded samples. */
	@Synchronized
	private fun hitNext() {
		if (loaded.isEmpty()) return
		val id = loaded[nextIndex % loaded.size]
		nextIndex++
		val pitch = 1f + Random.nextFloat().times(2f).minus(1f) * pitchJitter
		val volume = 1f - Random.nextFloat() * volumeJitter
		play(id, volume, pitch)
	}

	fun setJitter(pitch: Float, volume: Float) {
		pitchJitter = pitch.coerceIn(0f, 0.5f)
		volumeJitter = volume.coerceIn(0f, 1f)
	}

	/**
	 * Auto mode. Beats are scheduled against the monotonic uptime clock rather
	 * than by re-posting a delay, so the tempo does not drift over a long
	 * session and a busy moment does not stretch the interval.
	 */
	fun setAuto(enabled: Boolean, bpm: Float) {
		val h = handler ?: return
		periodMs = (60_000f / bpm.coerceIn(20f, 480f)).toLong().coerceAtLeast(20L)
		if (enabled && !autoRunning) {
			autoRunning = true
			nextBeatAt = SystemClock.uptimeMillis()
			h.post(beat)
		} else if (!enabled && autoRunning) {
			autoRunning = false
			h.removeCallbacks(beat)
		}
	}

	fun isAutoRunning(): Boolean = autoRunning

	private var beatCount = 0L

	private val beat = object : Runnable {
		override fun run() {
			if (!autoRunning) return
			hitNext()
			beatCount++
			// One line every few seconds, so a screen-off session can be checked
			// from logcat without guessing.
			if (beatCount % 8L == 0L) Log.i(TAG, "beat $beatCount")
			nextBeatAt += periodMs
			val now = SystemClock.uptimeMillis()
			// After a long stall, drop the backlog instead of firing it all at once.
			if (nextBeatAt < now) nextBeatAt = now + periodMs
			handler?.postAtTime(this, nextBeatAt)
		}
	}

	@Synchronized
	fun close() {
		setAuto(false, 60f)
		pool?.release()
		pool = null
		loaded.clear()
		ready.clear()
		thread?.quitSafely()
		thread = null
		handler = null
	}

	/** Converts the dB the engine side thinks in into SoundPool's linear gain. */
	fun dbToLinear(db: Float): Float = 10f.pow(db / 20f).coerceIn(0f, 1f)
}
