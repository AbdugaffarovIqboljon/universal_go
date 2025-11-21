package com.example.universal_go

import android.os.Bundle
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    
    override fun onStart() {
        super.onStart()
        MapKitFactory.getInstance().onStart()
    }
    
    override fun onStop() {
        MapKitFactory.getInstance().onStop()
        super.onStop()
    }
}