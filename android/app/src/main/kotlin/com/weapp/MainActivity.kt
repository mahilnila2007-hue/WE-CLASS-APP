package com.weapp

import android.os.Bundle
import android.os.PowerManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val FOCUS_GUARD_CHANNEL = "com.we.campus/focus_guard"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FOCUS_GUARD_CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "isServiceAvailable" -> {
                    result.success(true)
                }
                "startPhoneUsageMonitoring" -> {
                    result.success(true)
                }
                "stopPhoneUsageMonitoring" -> {
                    result.success(true)
                }
                "getDeviceScreenState" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
                    val isInteractive = powerManager?.isInteractive ?: true
                    result.success(isInteractive)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
