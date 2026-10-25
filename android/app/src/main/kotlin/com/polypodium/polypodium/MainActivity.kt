package com.polypodium.polypodium

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Draws behind the system bars on every Android version, as Android 15+
        // already enforces for targetSdk 35; Flutter passes the insets to
        // MediaQuery, which Scaffold/SafeArea respect. Runs after super so it
        // replaces the translucent status bar FlutterActivity sets up.
        WindowCompat.enableEdgeToEdge(window)
    }
}
