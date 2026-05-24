package com.xaut.app.services

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.xaut.app.MainActivity

class AlertMonitorService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "TRIGGER_ALERT" -> {
                val alertId = intent.getStringExtra("alert_id")
                // Delegate to Flutter via broadcast
                val broadcastIntent = Intent("com.xaut.app.ALERT_TRIGGERED").apply {
                    putExtra("alert_id", alertId)
                }
                sendBroadcast(broadcastIntent)
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onCreate() {
        super.onCreate()
        startForeground(1002, buildNotification())
    }

    private fun buildNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )
        return NotificationCompat.Builder(this, "xaut_price_service")
            .setContentTitle("XAUT Alert Monitor")
            .setContentText("Monitoring price alerts")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setSilent(true)
            .build()
    }
}
