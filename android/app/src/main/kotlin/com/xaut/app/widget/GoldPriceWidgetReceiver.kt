package com.xaut.app.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.xaut.app.MainActivity
import com.xaut.app.R

class GoldPriceWidgetReceiver : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidgetFromPrefs(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        val manager = AppWidgetManager.getInstance(context)
        val componentName = android.content.ComponentName(
            context,
            GoldPriceWidgetReceiver::class.java,
        )
        val ids = manager.getAppWidgetIds(componentName)

        when (intent.action) {
            "com.xaut.app.UPDATE_WIDGET" -> {
                val price = intent.getStringExtra("price") ?: "---.--"
                val change = intent.getStringExtra("change") ?: "+0.00"
                val isPositive = intent.getBooleanExtra("is_positive", true)
                val time = intent.getStringExtra("time") ?: "--:--:--"
                val isLive = intent.getBooleanExtra("is_live", false)
                for (id in ids) {
                    applyViews(
                        context, manager, id,
                        price, change, isPositive, time, isLive,
                    )
                }
            }
            else -> {
                for (id in ids) {
                    updateWidgetFromPrefs(context, manager, id)
                }
            }
        }
    }

    private fun updateWidgetFromPrefs(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
    ) {
        val prefs: SharedPreferences = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        applyViews(
            context, manager, id,
            prefs.getString("flutter.xaut_price", "---.--") ?: "---.--",
            prefs.getString("flutter.xaut_change", "+0.00") ?: "+0.00",
            prefs.getBoolean("flutter.xaut_is_positive", true),
            prefs.getString("flutter.xaut_time", "--:--:--") ?: "--:--:--",
            prefs.getBoolean("flutter.xaut_is_live", false),
        )
    }

    private fun applyViews(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        price: String,
        change: String,
        isPositive: Boolean,
        time: String,
        isLive: Boolean,
    ) {
        val views = RemoteViews(context.packageName, R.layout.gold_price_widget_layout)

        views.setTextViewText(R.id.widget_price, price)
        views.setTextViewText(R.id.widget_change, change)
        views.setTextViewText(R.id.widget_updated, time)

        val changeColor = if (isPositive) 0xFF00E676.toInt() else 0xFFFF5252.toInt()
        views.setTextColor(R.id.widget_change, changeColor)

        val statusText = if (isLive) "● LIVE" else "○ OFF"
        val statusColor = if (isLive) 0xFF00E676.toInt() else 0xFF888888.toInt()
        views.setTextViewText(R.id.widget_market_status, statusText)
        views.setTextColor(R.id.widget_market_status, statusColor)

        val launchIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        manager.updateAppWidget(id, views)
    }
}
