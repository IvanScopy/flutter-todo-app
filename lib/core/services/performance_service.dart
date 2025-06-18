import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  late SharedPreferences _prefs;
  final Map<String, dynamic> _cache = {};
  final Map<String, Timer> _cacheTimers = {};
  
  // Performance metrics
  final Map<String, int> _operationCounts = {};
  final Map<String, int> _totalExecutionTime = {};

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCacheFromPrefs();
  }

  // Cache Management
  void setCache(String key, dynamic value, {Duration? duration}) {
    _cache[key] = value;
    
    // Set expiration timer if duration is provided
    if (duration != null) {
      _cacheTimers[key]?.cancel();
      _cacheTimers[key] = Timer(duration, () {
        _cache.remove(key);
        _cacheTimers.remove(key);
      });
    }
    
    // Persist to SharedPreferences for important data
    if (_isImportantCacheKey(key)) {
      _saveCacheToPrefs(key, value);
    }
  }

  T? getCache<T>(String key) {
    return _cache[key] as T?;
  }

  void removeCache(String key) {
    _cache.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);
    _prefs.remove('cache_$key');
  }

  void clearCache() {
    _cache.clear();
    _cacheTimers.values.forEach((timer) => timer.cancel());
    _cacheTimers.clear();
    
    // Clear persisted cache
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      _prefs.remove(key);
    }
  }

  // Performance Metrics
  void recordOperationStart(String operation) {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    setCache('operation_start_$operation', startTime);
  }

  void recordOperationEnd(String operation) {
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final startTime = getCache<int>('operation_start_$operation');
    
    if (startTime != null) {
      final duration = endTime - startTime;
      
      _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
      _totalExecutionTime[operation] = (_totalExecutionTime[operation] ?? 0) + duration;
      
      removeCache('operation_start_$operation');
      
      // Log slow operations
      if (duration > 1000) { // More than 1 second
        print('⚠️ Slow operation detected: $operation took ${duration}ms');
      }
    }
  }

  Map<String, dynamic> getPerformanceMetrics() {
    final metrics = <String, dynamic>{};
    
    for (final operation in _operationCounts.keys) {
      final count = _operationCounts[operation] ?? 0;
      final totalTime = _totalExecutionTime[operation] ?? 0;
      final avgTime = count > 0 ? totalTime / count : 0;
      
      metrics[operation] = {
        'count': count,
        'total_time_ms': totalTime,
        'average_time_ms': avgTime.round(),
      };
    }
    
    return metrics;
  }

  // Memory Management
  void optimizeMemoryUsage() {
    // Remove expired cache entries
    final expiredKeys = <String>[];
    final now = DateTime.now();
    
    for (final entry in _cache.entries) {
      if (entry.key.startsWith('temp_')) {
        // Remove temporary cache entries older than 1 hour
        final cacheTime = getCache<DateTime>('${entry.key}_time');
        if (cacheTime != null && now.difference(cacheTime).inHours > 1) {
          expiredKeys.add(entry.key);
        }
      }
    }
    
    for (final key in expiredKeys) {
      removeCache(key);
    }
    
    // Force garbage collection hint
    print('🧹 Memory optimization completed. Removed ${expiredKeys.length} expired cache entries.');
  }

  // Battery Optimization
  void setBatteryOptimizedMode(bool enabled) {
    setCache('battery_optimized', enabled);
    
    if (enabled) {
      print('🔋 Battery optimization enabled');
      // Reduce background processing
      // Increase cache durations
      // Reduce animation frame rates
    } else {
      print('⚡ Performance mode enabled');
    }
  }

  bool get isBatteryOptimized => getCache<bool>('battery_optimized') ?? false;

  // Network Optimization
  void cacheNetworkResponse(String url, dynamic response) {
    setCache('network_$url', response, duration: const Duration(minutes: 30));
    setCache('network_${url}_time', DateTime.now());
  }

  dynamic getCachedNetworkResponse(String url) {
    final cached = getCache('network_$url');
    final cacheTime = getCache<DateTime>('network_${url}_time');
    
    if (cached != null && cacheTime != null) {
      final age = DateTime.now().difference(cacheTime);
      if (age.inMinutes < 30) {
        return cached;
      } else {
        removeCache('network_$url');
        removeCache('network_${url}_time');
      }
    }
    
    return null;
  }

  // Helper methods
  bool _isImportantCacheKey(String key) {
    return key.startsWith('user_') || 
           key.startsWith('settings_') || 
           key.startsWith('task_filter_');
  }

  void _loadCacheFromPrefs() {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    
    for (final key in keys) {
      final value = _prefs.get(key);
      if (value != null) {
        final cacheKey = key.substring(6); // Remove 'cache_' prefix
        _cache[cacheKey] = value;
      }
    }
  }

  void _saveCacheToPrefs(String key, dynamic value) {
    try {
      if (value is String) {
        _prefs.setString('cache_$key', value);
      } else if (value is int) {
        _prefs.setInt('cache_$key', value);
      } else if (value is double) {
        _prefs.setDouble('cache_$key', value);
      } else if (value is bool) {
        _prefs.setBool('cache_$key', value);
      } else if (value is List<String>) {
        _prefs.setStringList('cache_$key', value);
      }
    } catch (e) {
      print('Error saving cache to prefs: $e');
    }
  }

  // Cleanup on app termination
  void dispose() {
    _cacheTimers.values.forEach((timer) => timer.cancel());
    _cacheTimers.clear();
  }
}
