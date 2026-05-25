package com.xaut.app

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.graphics.Color
import android.os.Build
import androidx.work.Configuration

class XautApplication : Application(), Configuration.Provider {

    override fun onCreate() {
        super.onCreate()
        createNotificationChannels()
    }

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder()
            .setMinimumLoggingLevel(android.util.Log.INFO)
            .build()

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            // Live Price Channel
            val priceChannel = NotificationChannel(
                "xaut_price_service",
                "Live Gold Price Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Persistent notification for live gold price monitoring"
                setShowBadge(false)
                setSound(null, null)
                enableLights(false)
                enableVibration(false)
            }

            // Standard Alert Channel
            val alertChannel = NotificationChannel(
                "xaut_alerts",
                "Price Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "XAUUSD price alert notifications"
                enableLights(true)
                lightColor = Color.parseColor("#FFD700")
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 250, 250, 250)
            }

            // High Priority Alert Channel
            val highPriorityChannel = NotificationChannel(
                "xaut_alerts_high",
                "High Priority Price Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "High priority XAUUSD price alerts"
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 250, 500, 250, 500)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }

            // Alarm Channel (Full screen)
            val alarmChannel = NotificationChannel(
                "xaut_alarm",
                "Gold Price Alarms",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Full-screen alarm notifications for critical price levels"
                enableLights(true)
                lightColor = Color.RED
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                setBypassDnd(true)
            }

            notificationManager.createNotificationChannels(
                listOf(priceChannel, alertChannel, highPriorityChannel, alarmChannel)
            )
        }
    }
}
