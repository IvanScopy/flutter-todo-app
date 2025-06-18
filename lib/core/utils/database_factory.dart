import 'package:flutter/foundation.dart';

class DatabaseFactory {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    
    if (kIsWeb) {
      // For web, we'll use a different storage strategy
      // SQLite doesn't work well on web
      print('Web platform detected - using alternative storage');
    } else {
      // Use SQLite for mobile platforms
      print('Mobile platform detected - using SQLite');
    }
    
    _initialized = true;
  }
  
  static bool get isWeb => kIsWeb;
}
