package com.example.universal_go

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.yandex.mapkit.MapKitFactory

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Set API key before calling initialize so MapKit can use it during initialization.
        val apiKey = BuildConfig.YANDEX_API_KEY ?: ""
        if (apiKey.isNotEmpty()) {
            MapKitFactory.setApiKey(apiKey)
        }
        // Initialize MapKitFactory. Docs recommend initializing early (Application.onCreate ideally).
        MapKitFactory.initialize(this)
        super.onCreate(savedInstanceState)
    }

    override fun onStart() {
        super.onStart()
        // Start MapKit lifecycle
        MapKitFactory.getInstance().onStart()
    }

    override fun onStop() {
        // Stop MapKit lifecycle
        MapKitFactory.getInstance().onStop()
        super.onStop()
    }
}
