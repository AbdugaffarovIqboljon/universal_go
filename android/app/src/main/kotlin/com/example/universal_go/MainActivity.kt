package com.example.universal_go

import android.os.Bundle
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    
    companion object {
        private var isMapKitInitialized = false
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        // Initialize MapKit before Flutter starts
        if (!isMapKitInitialized) {
            MapKitFactory.setApiKey(BuildConfig.YANDEX_API_KEY)
            isMapKitInitialized = true
        }
        
        super.onCreate(savedInstanceState)
    }
    
    override fun onStart() {
        super.onStart()
        // Ensure MapKit is initialized and started
        MapKitFactory.getInstance().onStart()
    }
    
    override fun onStop() {
        // Stop MapKit when activity stops
        MapKitFactory.getInstance().onStop()
        super.onStop()
    }
}