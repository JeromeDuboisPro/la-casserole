package com.addictivexp.taptone

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * Keeps the process alive, and the CPU awake, while the app is in a pocket.
 *
 * Without this the system freezes the app moments after the screen goes off and
 * the noise stops, which is the one thing the app exists to avoid.
 */
class NoiseService : Service() {

	private var wakeLock: PowerManager.WakeLock? = null

	override fun onBind(intent: Intent?): IBinder? = null

	override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
		val title = intent?.getStringExtra(EXTRA_TITLE) ?: applicationInfo.loadLabel(packageManager).toString()
		val text = intent?.getStringExtra(EXTRA_TEXT) ?: ""
		startInForeground(NOTIFICATION_ID, buildNotification(title, text))
		acquireWakeLock()
		// Restarting with no intent would leave us without a notification, so
		// let the app ask again rather than coming back half-configured.
		return START_NOT_STICKY
	}

	override fun onDestroy() {
		releaseWakeLock()
		super.onDestroy()
	}

	private fun startInForeground(id: Int, notification: Notification) {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
			startForeground(id, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
		} else {
			startForeground(id, notification)
		}
	}

	private fun buildNotification(title: String, text: String): Notification {
		val manager = getSystemService(NotificationManager::class.java)
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			val channel = NotificationChannel(
				CHANNEL_ID,
				title,
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

		return Notification.Builder(this, CHANNEL_ID)
			.setContentTitle(title)
			.setContentText(text)
			.setSmallIcon(applicationInfo.icon)
			.setOngoing(true)
			.setContentIntent(pending)
			.build()
	}

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
		private const val CHANNEL_ID = "taptone"
		private const val NOTIFICATION_ID = 1
		private const val WAKE_LOCK_TAG = "taptone:playback"
		const val EXTRA_TITLE = "title"
		const val EXTRA_TEXT = "text"

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

		fun stop(context: Context) {
			context.stopService(Intent(context, NoiseService::class.java))
		}
	}
}
