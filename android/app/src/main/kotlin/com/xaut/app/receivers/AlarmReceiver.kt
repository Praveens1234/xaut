package com.xaut.app.receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import com.xaut.app.services.AlertMonitorService

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alertId = intent.getStringExtra("alert_id") ?: return
        val serviceIntent = Intent(context, AlertMonitorService::class.java).apply {
            action = "TRIGGER_ALERT"
            putExtra("alert_id", alertId)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }
    }
}
