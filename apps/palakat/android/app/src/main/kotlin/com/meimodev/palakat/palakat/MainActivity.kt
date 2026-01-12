package com.meimodev.palakat.palakat

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "palakat/exact_alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canScheduleExactAlarms" -> {
                        result.success(canScheduleExactAlarms())
                    }
                    "requestExactAlarmPermission" -> {
                        requestExactAlarmPermission()
                        result.success(null)
                    }
                    "canUseFullScreenIntent" -> {
                        result.success(canUseFullScreenIntent())
                    }
                    "requestFullScreenIntentPermission" -> {
                        requestFullScreenIntentPermission()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return alarmManager.canScheduleExactAlarms()
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
        intent.data = Uri.parse("package:$packageName")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < 34) return true
        return try {
            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val method = NotificationManager::class.java.getMethod("canUseFullScreenIntent")
            (method.invoke(notificationManager) as? Boolean) ?: true
        } catch (e: Exception) {
            true
        }
    }

    private fun requestFullScreenIntentPermission() {
        if (Build.VERSION.SDK_INT < 34) return

        val intent = Intent("android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT")
        intent.data = Uri.parse("package:$packageName")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        try {
            startActivity(intent)
        } catch (e: Exception) {
            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
            fallback.data = Uri.parse("package:$packageName")
            fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(fallback)
        }
    }
}
