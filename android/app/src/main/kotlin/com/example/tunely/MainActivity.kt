package com.example.tunely

import android.net.Uri
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "tunely/artwork"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getArtwork") {
                val uri = Uri.parse(call.arguments as String)
                try {
                    val bytes = contentResolver
                        .openInputStream(uri)
                        ?.use { it.readBytes() }
                    if (bytes != null) result.success(bytes)
                    else result.error("NOT_FOUND", "No artwork", null)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            }
        }
    }
}