import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _attempted = false;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<bool> ensureInitialized() async {
    if (_initialized) return true;
    if (_attempted) return false;

    _attempted = true;
    try {
      await Firebase.initializeApp();
      _initialized = true;
      return true;
    } catch (e) {
      // Keep app usable even when Firebase is not configured
      // (for example web/iOS without platform config files).
      debugPrint('Firebase init skipped: $e');
      _initialized = false;
      return false;
    }
  }
}
