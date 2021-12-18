package com.oh.ohmmkv

import androidx.annotation.NonNull
import com.tencent.mmkv.MMKV
import com.tencent.mmkv.MMKVLogLevel

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** OhmmkvPlugin */
class OhmmkvPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ohmmkv")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "initializeMMKV") {
            val rootDir: String? = call.argument("rootDir")
            val level: Int? = call.argument("logLevel")
            val logLevel = if (level != null) MMKVLogLevel.values()[level] else MMKVLogLevel.LevelNone
            val ret: String? = MMKV.initialize(rootDir, logLevel)
            result.success(ret)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
