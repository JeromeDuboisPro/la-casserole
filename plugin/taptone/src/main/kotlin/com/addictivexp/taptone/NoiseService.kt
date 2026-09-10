package com.addictivexp.taptone

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * Keeps the process alive, and the CPU awake, while the app is in a pocket.
 *
 * Without this the system freezes the app moments after the screen goes off and
 * the noise stops, which is the one thing the app exists to avoid.
 *
 * The notification carries the only controls reachable once the phone is away:
 * pause or resume, and stop.
 */
class NoiseService : Service() {

	private var wakeLock: PowerManager.WakeLock? = null
	private var session: MediaSession? = null
	private var title: String = ""
	private var text: String = ""

	override fun onBind(intent: Intent?): IBinder? = null

	override fun onCreate() {
		super.onCreate()
		// A media session is what turns this into a media notification. Android
		// 12 and later hide the icons of ordinary notification actions and show
		// the labels alone; only the media style keeps the shapes. It also puts
		// the controls on the lock screen and makes a headset button work.
		session = MediaSession(this, "TapTone").apply {
			setCallback(object : MediaSession.Callback() {
				override fun onPlay() = toggle()
				override fun onPause() = toggle()
				override fun onStop() = stopEverything()
			})
			isActive = true
		}
	}

	private fun toggle() {
		NoiseEngine.setAuto(!NoiseEngine.isAutoRunning(), NoiseEngine.bpm())
		startInForeground(NOTIFICATION_ID, buildNotification())
	}

	private fun stopEverything() {
		NoiseEngine.setAuto(false, NoiseEngine.bpm())
		isRunning = false
		releaseWakeLock()
		stopForeground(STOP_FOREGROUND_REMOVE)
		stopSelf()
	}

	override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
		// A refresh must never bring a stopped service back to life: it arrives
		// with no title, and it would put back a notification the user just
		// dismissed with Stop.
		if (intent?.action == ACTION_REFRESH && !isRunning) {
			stopSelf()
			return START_NOT_STICKY
		}
		when (intent?.action) {
			ACTION_TOGGLE -> NoiseEngine.setAuto(!NoiseEngine.isAutoRunning(), NoiseEngine.bpm())
			ACTION_STOP -> {
				stopEverything()
				return START_NOT_STICKY
			}
			ACTION_REFRESH -> Unit   // keep title and text, only the icons change
			else -> {
				title = intent?.getStringExtra(EXTRA_TITLE).orEmpty().ifBlank { appLabel() }
				text = intent?.getStringExtra(EXTRA_TEXT) ?: ""
			}
		}
		startInForeground(NOTIFICATION_ID, buildNotification())
		acquireWakeLock()
		isRunning = true
		// Restarting with no intent would leave us without a notification, so
		// let the app ask again rather than coming back half-configured.
		return START_NOT_STICKY
	}

	override fun onDestroy() {
		isRunning = false
		releaseWakeLock()
		session?.isActive = false
		session?.release()
		session = null
		super.onDestroy()
	}

	private fun startInForeground(id: Int, notification: Notification) {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			startForeground(id, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
		} else {
			startForeground(id, notification)
		}
	}

	private fun pendingFor(name: String): PendingIntent {
		val intent = Intent(this, NoiseService::class.java).setAction(name)
		return PendingIntent.getService(
			this, name.hashCode(), intent,
			PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
		)
	}

	private fun action(name: String, icon: Int, label: String): Notification.Action =
		Notification.Action.Builder(Icon.createWithResource(this, icon), label, pendingFor(name)).build()

	private fun buildNotification(): Notification {
		val manager = getSystemService(NotificationManager::class.java)
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			// The channel name is what the user sees in the system settings, and
			// Android rejects an empty one outright, so it never depends on a
			// value that arrives with an intent.
			val channel = NotificationChannel(
				CHANNEL_ID,
				appLabel(),
				// LOW: visible and dismissable, but it must never make a sound of
				// its own on top of the one we are playing.
				NotificationManager.IMPORTANCE_LOW,
			).apply {
				setShowBadge(false)
				enableVibration(false)
			}
			manager.createNotificationChannel(channel)
		}

		val launch = packageManager.getLaunchIntentForPackage(packageName)
		val pending = launch?.let {
			PendingIntent.getActivity(
				this, 0, it,
				PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
			)
		}

		val running = NoiseEngine.isAutoRunning()
		// The transport triad, drawn as the shapes everyone already knows: two
		// bars, a triangle, a square. A cross would read as "close the app"
		// rather than "stop the noise".
		val toggle = action(
			ACTION_TOGGLE,
			if (running) R.drawable.tt_pause else R.drawable.tt_play,
			if (running) "Pause" else "Play",
		)
		val stop = action(ACTION_STOP, R.drawable.tt_stop, "Stop")

		// The session state drives the lock screen and any headset button.
		session?.setPlaybackState(
			PlaybackState.Builder()
				.setActions(
					PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE or PlaybackState.ACTION_STOP
				)
				.setState(
					if (running) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED,
					PlaybackState.PLAYBACK_POSITION_UNKNOWN,
					1.0f,
				)
				.build()
		)

		val builder = Notification.Builder(this, CHANNEL_ID)
			.setContentTitle(title.ifBlank { appLabel() })
			.setContentText(if (running) "%d".format(NoiseEngine.bpm().toInt()) else text)
			.setSmallIcon(R.drawable.tt_status)
			.setOngoing(true)
			.setContentIntent(pending)
			.addAction(toggle)
			.addAction(stop)
			// The system composes the media controls itself and may leave the
			// square out of the collapsed view. A paused media notification can
			// be swiped away, so swiping it is made to mean Stop rather than
			// leaving the service and its wake lock behind.
			.setDeleteIntent(pendingFor(ACTION_STOP))
		session?.sessionToken?.let { token ->
			builder.setStyle(
				Notification.MediaStyle()
					.setMediaSession(token)
					.setShowActionsInCompactView(0, 1)
			)
		}
		return builder.build()
	}

	private fun appLabel(): String = applicationInfo.loadLabel(packageManager).toString()

	private fun acquireWakeLock() {
		if (wakeLock != null) return
		val power = getSystemService(Context.POWER_SERVICE) as PowerManager
		wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKE_LOCK_TAG).apply {
			setReferenceCounted(false)
			acquire()
		}
	}

	private fun releaseWakeLock() {
		wakeLock?.let { if (it.isHeld) it.release() }
		wakeLock = null
	}

	companion object {
		/** Whether a foreground instance is up, so a refresh cannot restart one. */
		@Volatile
		private var isRunning = false

		private const val CHANNEL_ID = "taptone"
		private const val NOTIFICATION_ID = 1
		private const val WAKE_LOCK_TAG = "taptone:playback"
		const val EXTRA_TITLE = "title"
		const val EXTRA_TEXT = "text"
		const val ACTION_TOGGLE = "com.addictivexp.taptone.TOGGLE"
		const val ACTION_STOP = "com.addictivexp.taptone.STOP"

		fun start(context: Context, title: String, text: String) {
			val intent = Intent(context, NoiseService::class.java)
				.putExtra(EXTRA_TITLE, title)
				.putExtra(EXTRA_TEXT, text)
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				context.startForegroundService(intent)
			} else {
				context.startService(intent)
			}
		}

		/** Re-posts the notification so its play/pause icon matches the engine. */
		fun refresh(context: Context) {
			if (!isRunning) return
			val intent = Intent(context, NoiseService::class.java).setAction(ACTION_REFRESH)
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				context.startForegroundService(intent)
			} else {
				context.startService(intent)
			}
		}

		const val ACTION_REFRESH = "com.addictivexp.taptone.REFRESH"

		fun stop(context: Context) {
			isRunning = false
			context.stopService(Intent(context, NoiseService::class.java))
		}
	}
}
