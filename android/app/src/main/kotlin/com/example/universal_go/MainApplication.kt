package com.example.universal_go

import androidx.multidex.MultiDexApplication
import com.yandex.mapkit.MapKitFactory

class MainApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        try {
            val apiKey = BuildConfig.YANDEX_API_KEY
            if (apiKey.isNotEmpty()) {
                MapKitFactory.setApiKey(apiKey)
                MapKitFactory.initialize(this)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}