package com.xaut.app

import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.os.Build

class AlarmActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Keep screen on and show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }

        // Simple layout programmatically
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            gravity = android.view.Gravity.CENTER
            setBackgroundColor(0xFF0A0A0F.toInt())
            setPadding(48, 48, 48, 48)
        }

        val titleView = TextView(this).apply {
            text = "⚠ PRICE ALERT TRIGGERED"
            textSize = 18f
            setTextColor(0xFFFFD700.toInt())
            gravity = android.view.Gravity.CENTER
            setPadding(0, 0, 0, 24)
        }

        val alertLabel = TextView(this).apply {
            text = intent.getStringExtra("alert_label") ?: "Price Alert"
            textSize = 14f
            setTextColor(0xFFFFFFFF.toInt())
            gravity = android.view.Gravity.CENTER
        }

        val priceView = TextView(this).apply {
            text = "XAU/USD: ${intent.getStringExtra("trigger_price") ?: ""}"
            textSize = 28f
            setTextColor(0xFFFFFFFF.toInt())
            gravity = android.view.Gravity.CENTER
            typeface = android.graphics.Typeface.MONOSPACE
            setPadding(0, 16, 0, 32)
        }

        val dismissBtn = Button(this).apply {
            text = "DISMISS ALARM"
            setBackgroundColor(0xFFFFD700.toInt())
            setTextColor(0xFF000000.toInt())
            textSize = 16f
            setOnClickListener { finish() }
        }

        layout.addView(titleView)
        layout.addView(alertLabel)
        layout.addView(priceView)
        layout.addView(dismissBtn)

        setContentView(layout)
    }
}
