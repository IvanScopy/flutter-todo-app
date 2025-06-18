import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late SharedPreferences _prefs;
  final Map<String, dynamic> _sessionData = {};

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _startSession();
  }

  // Session Management
  void _startSession() {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _sessionData['session_id'] = sessionId;
    _sessionData['session_start'] = DateTime.now().toIso8601String();
    _sessionData['events'] = <Map<String, dynamic>>[];
    
    logEvent('app_session_start');
  }

  void endSession() {
    _sessionData['session_end'] = DateTime.now().toIso8601String();
    final startTime = DateTime.parse(_sessionData['session_start']);
    final endTime = DateTime.now();
    _sessionData['session_duration_seconds'] = endTime.difference(startTime).inSeconds;
    
    logEvent('app_session_end');
    _saveSessionData();
  }

  // Event Logging
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    final event = {
      'event_name': eventName,
      'timestamp': DateTime.now().toIso8601String(),
      'parameters': parameters ?? {},
    };

    final events = _sessionData['events'] as List<Map<String, dynamic>>;
    events.add(event);

    print('📊 Analytics Event: $eventName ${parameters ?? ''}');
    
    // Auto-save every 10 events
    if (events.length % 10 == 0) {
      _saveSessionData();
    }
  }

  // Task Analytics
  void logTaskCreated({required String priority, String? category}) {
    logEvent('task_created', parameters: {
      'priority': priority,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('tasks_created_total');
    _incrementCounter('tasks_created_priority_$priority');
  }

  void logTaskCompleted({
    required String priority,
    required int daysToComplete,
    String? category,
  }) {
    logEvent('task_completed', parameters: {
      'priority': priority,
      'category': category,
      'days_to_complete': daysToComplete,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('tasks_completed_total');
    _incrementCounter('tasks_completed_priority_$priority');
    _updateAverageCompletionTime(daysToComplete);
  }

  void logTaskDeleted({required String priority, String? category}) {
    logEvent('task_deleted', parameters: {
      'priority': priority,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('tasks_deleted_total');
  }

  void logTaskOverdue({required String priority, required int daysPastDue}) {
    logEvent('task_overdue', parameters: {
      'priority': priority,
      'days_past_due': daysPastDue,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('tasks_overdue_total');
  }

  // User Behavior Analytics
  void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('screen_views_$screenName');
  }

  void logFeatureUsage(String featureName) {
    logEvent('feature_used', parameters: {
      'feature_name': featureName,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('feature_usage_$featureName');
  }

  void logSearchPerformed({required String query, required int resultCount}) {
    logEvent('search_performed', parameters: {
      'query_length': query.length,
      'result_count': resultCount,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('searches_performed');
  }

  void logFilterApplied(String filterType, String filterValue) {
    logEvent('filter_applied', parameters: {
      'filter_type': filterType,
      'filter_value': filterValue,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('filters_applied_$filterType');
  }

  // Performance Analytics
  void logPerformanceMetric(String metricName, int value, {String? unit}) {
    logEvent('performance_metric', parameters: {
      'metric_name': metricName,
      'value': value,
      'unit': unit ?? 'ms',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void logError(String errorType, String errorMessage, {String? stackTrace}) {
    logEvent('error_occurred', parameters: {
      'error_type': errorType,
      'error_message': errorMessage,
      'stack_trace': stackTrace,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    _incrementCounter('errors_total');
    _incrementCounter('errors_$errorType');
  }

  // Statistics and Insights
  Map<String, dynamic> getTaskStatistics() {
    final stats = <String, dynamic>{};
    
    // Get all counters related to tasks
    final keys = _prefs.getKeys().where((key) => key.startsWith('counter_tasks_'));
    
    for (final key in keys) {
      final value = _prefs.getInt(key) ?? 0;
      final statName = key.substring(8); // Remove 'counter_' prefix
      stats[statName] = value;
    }
    
    // Calculate productivity metrics
    final tasksCreated = stats['tasks_created_total'] ?? 0;
    final tasksCompleted = stats['tasks_completed_total'] ?? 0;
    final completionRate = tasksCreated > 0 ? (tasksCompleted / tasksCreated * 100).round() : 0;
    
    stats['completion_rate_percentage'] = completionRate;
    stats['average_completion_time_days'] = _prefs.getDouble('avg_completion_time') ?? 0.0;
    
    return stats;
  }

  Map<String, dynamic> getUserBehaviorStats() {
    final stats = <String, dynamic>{};
    
    // Get screen view counts
    final screenKeys = _prefs.getKeys().where((key) => key.startsWith('counter_screen_views_'));
    for (final key in screenKeys) {
      final screenName = key.substring(21); // Remove 'counter_screen_views_' prefix
      stats['screen_views_$screenName'] = _prefs.getInt(key) ?? 0;
    }
    
    // Get feature usage counts
    final featureKeys = _prefs.getKeys().where((key) => key.startsWith('counter_feature_usage_'));
    for (final key in featureKeys) {
      final featureName = key.substring(22); // Remove 'counter_feature_usage_' prefix
      stats['feature_usage_$featureName'] = _prefs.getInt(key) ?? 0;
    }
    
    // Add total searches
    stats['total_searches'] = _prefs.getInt('counter_searches_performed') ?? 0;
    
    return stats;
  }

  List<Map<String, dynamic>> getRecentEvents({int limit = 50}) {
    final allEvents = <Map<String, dynamic>>[];
    
    // Get current session events
    final sessionEvents = _sessionData['events'] as List<Map<String, dynamic>>? ?? [];
    allEvents.addAll(sessionEvents);
    
    // Get saved session events
    final savedSessions = _getSavedSessions();
    for (final session in savedSessions) {
      final events = session['events'] as List<dynamic>? ?? [];
      allEvents.addAll(events.cast<Map<String, dynamic>>());
    }
    
    // Sort by timestamp and limit
    allEvents.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return allEvents.take(limit).toList();
  }

  // Export data for analysis
  Map<String, dynamic> exportAnalyticsData() {
    final export = <String, dynamic>{};
    
    export['task_statistics'] = getTaskStatistics();
    export['user_behavior'] = getUserBehaviorStats();
    export['recent_events'] = getRecentEvents(limit: 100);
    export['saved_sessions'] = _getSavedSessions();
    export['export_timestamp'] = DateTime.now().toIso8601String();
    
    return export;
  }

  // Privacy Controls
  void clearAllAnalyticsData() {
    final keys = _prefs.getKeys().where((key) => 
        key.startsWith('counter_') || 
        key.startsWith('analytics_') ||
        key.startsWith('avg_')
    );
    
    for (final key in keys) {
      _prefs.remove(key);
    }
    
    _sessionData.clear();
    _startSession();
    
    print('🗑️ All analytics data cleared');
  }

  // Helper methods
  void _incrementCounter(String counterName) {
    final key = 'counter_$counterName';
    final currentValue = _prefs.getInt(key) ?? 0;
    _prefs.setInt(key, currentValue + 1);
  }

  void _updateAverageCompletionTime(int daysToComplete) {
    final currentAvg = _prefs.getDouble('avg_completion_time') ?? 0.0;
    final totalCompleted = _prefs.getInt('counter_tasks_completed_total') ?? 0;
    
    if (totalCompleted > 0) {
      final newAvg = ((currentAvg * (totalCompleted - 1)) + daysToComplete) / totalCompleted;
      _prefs.setDouble('avg_completion_time', newAvg);
    }
  }

  void _saveSessionData() {
    final sessions = _getSavedSessions();
    sessions.add(Map<String, dynamic>.from(_sessionData));
    
    // Keep only last 10 sessions to save storage
    if (sessions.length > 10) {
      sessions.removeRange(0, sessions.length - 10);
    }
    
    final sessionsJson = jsonEncode(sessions);
    _prefs.setString('analytics_sessions', sessionsJson);
  }

  List<Map<String, dynamic>> _getSavedSessions() {
    final sessionsJson = _prefs.getString('analytics_sessions') ?? '[]';
    final sessionsList = jsonDecode(sessionsJson) as List<dynamic>;
    return sessionsList.cast<Map<String, dynamic>>();
  }
}
