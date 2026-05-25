package com.xaut.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    private val channel = "com.xaut.app/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    pushWidgetUpdate(this)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        fun pushWidgetUpdate(context: Context) {
            try {
                val prefs: SharedPreferences =
                    context.getSharedPreferences(
                        "FlutterSharedPreferences",
                        Context.MODE_PRIVATE,
                    )

                val price = prefs.getString(
                    "flutter.xaut_price", "---.--",
                ) ?: "---.--"
                val change = prefs.getString(
                    "flutter.xaut_change", "+0.00 (0.00%)",
                ) ?: "+0.00 (0.00%)"
                val isPositive = prefs.getBoolean("flutter.xaut_is_positive", true)
                val time = prefs.getString(
                    "flutter.xaut_time", "--:--:--",
                ) ?: "--:--:--"
                val isLive = prefs.getBoolean("flutter.xaut_is_live", false)

                val intent = Intent(
                    context,
                    com.xaut.app.widget.GoldPriceWidgetReceiver::class.java,
                ).apply {
                    action = "com.xaut.app.UPDATE_WIDGET"
                    putExtra("price", price)
                    putExtra("change", change)
                    putExtra("is_positive", isPositive)
                    putExtra("time", time)
                    putExtra("is_live", isLive)
                }

                context.sendBroadcast(intent)

                // Also update via AppWidgetManager directly
                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(
                    ComponentName(
                        context,
                        com.xaut.app.widget.GoldPriceWidgetReceiver::class.java,
                    ),
                )
                if (ids.isNotEmpty()) {
                    val updateIntent = Intent(
                        AppWidgetManager.ACTION_APPWIDGET_UPDATE,
                    ).apply {
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                        setClass(
                            context,
                            com.xaut.app.widget.GoldPriceWidgetReceiver::class.java,
                        )
                    }
                    context.sendBroadcast(updateIntent)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
