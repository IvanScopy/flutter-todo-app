import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/performance_service.dart';
import '../../core/services/analytics_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final PerformanceService _performanceService = PerformanceService();
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _notificationsEnabled = true;
  bool _batteryOptimized = false;
  bool _analyticsEnabled = true;
  String _selectedTheme = 'System';
  int _reminderHours = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _analyticsService.logScreenView('settings');
  }

  void _loadSettings() {
    setState(() {
      _batteryOptimized = _performanceService.isBatteryOptimized;
      // Load other settings from cache/preferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildPerformanceSettings(),
          const SizedBox(height: 24),
          _buildThemeSettings(),
          const SizedBox(height: 24),
          _buildAnalyticsSettings(),
          const SizedBox(height: 24),
          _buildDataManagement(),
          const SizedBox(height: 24),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Get reminders for your tasks'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _analyticsService.logFeatureUsage('notifications_toggle');
              },
            ),
            if (_notificationsEnabled) ...[
              const Divider(),
              ListTile(
                title: const Text('Reminder Time'),
                subtitle: Text('$_reminderHours hour(s) before due date'),
                trailing: DropdownButton<int>(
                  value: _reminderHours,
                  items: [1, 2, 4, 8, 24].map((hours) {
                    return DropdownMenuItem(
                      value: hours,
                      child: Text('$hours hour${hours > 1 ? 's' : ''}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _reminderHours = value;
                      });
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('Test Notification'),
                subtitle: const Text('Send a test notification'),
                trailing: const Icon(Icons.send),
                onTap: () {
                  _notificationService.showTaskCompletedNotification(
                    taskTitle: 'Test Notification',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Test notification sent!')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Battery Optimization'),
              subtitle: const Text('Reduce power consumption'),
              value: _batteryOptimized,
              onChanged: (value) {
                setState(() {
                  _batteryOptimized = value;
                });
                _performanceService.setBatteryOptimizedMode(value);
                _analyticsService.logFeatureUsage('battery_optimization');
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              trailing: const Icon(Icons.cleaning_services),
              onTap: () {
                _showClearCacheDialog();
              },
            ),
            ListTile(
              title: const Text('Performance Metrics'),
              subtitle: const Text('View app performance data'),
              trailing: const Icon(Icons.analytics),
              onTap: () {
                _showPerformanceMetrics();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Theme'),
              subtitle: Text('Current: $_selectedTheme'),
              trailing: DropdownButton<String>(
                value: _selectedTheme,
                items: ['Light', 'Dark', 'System'].map((theme) {
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(theme),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTheme = value;
                    });
                    _analyticsService.logFeatureUsage('theme_change');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Analytics & Privacy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Usage Analytics'),
              subtitle: const Text('Help improve the app'),
              value: _analyticsEnabled,
              onChanged: (value) {
                setState(() {
                  _analyticsEnabled = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('View Statistics'),
              subtitle: const Text('See your productivity stats'),
              trailing: const Icon(Icons.insights),
              onTap: () {
                _showStatistics();
              },
            ),
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Download your data'),
              trailing: const Icon(Icons.download),
              onTap: () {
                _exportData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Data Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Backup Data'),
              subtitle: const Text('Save your tasks to cloud'),
              trailing: const Icon(Icons.cloud_upload),
              onTap: () {
                // TODO: Implement backup
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup feature coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Restore Data'),
              subtitle: const Text('Restore from backup'),
              trailing: const Icon(Icons.cloud_download),
              onTap: () {
                // TODO: Implement restore
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restore feature coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Reset All Data'),
              subtitle: const Text('Delete all tasks and settings'),
              trailing: Icon(Icons.delete_forever, color: Colors.red),
              onTap: () {
                _showResetDataDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Icons.info_outline),
            ),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.privacy_tip),
              onTap: () {
                // TODO: Open privacy policy
              },
            ),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.description),
              onTap: () {
                // TODO: Open terms of service
              },
            ),
            ListTile(
              title: const Text('Contact Support'),
              trailing: const Icon(Icons.support),
              onTap: () {
                // TODO: Open support
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog methods
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _performanceService.clearCache();
              _performanceService.optimizeMemoryUsage();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text('This will permanently delete all your tasks and settings. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _analyticsService.clearAllAnalyticsData();
              _performanceService.clearCache();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset!')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPerformanceMetrics() {
    final metrics = _performanceService.getPerformanceMetrics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Metrics'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: metrics.entries.map((entry) {
              final data = entry.value as Map<String, dynamic>;
              return ListTile(
                title: Text(entry.key),
                subtitle: Text('Avg: ${data['average_time_ms']}ms | Count: ${data['count']}'),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStatistics() {
    final taskStats = _analyticsService.getTaskStatistics();
    final behaviorStats = _analyticsService.getUserBehaviorStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Statistics'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('Task Statistics:', style: Theme.of(context).textTheme.titleMedium),
              ...taskStats.entries.map((entry) => ListTile(
                title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                trailing: Text(entry.value.toString()),
              )),
              const Divider(),
              Text('Usage Statistics:', style: Theme.of(context).textTheme.titleMedium),
              ...behaviorStats.entries.take(5).map((entry) => ListTile(
                title: Text(entry.key.replaceAll('_', ' ').toUpperCase()),
                trailing: Text(entry.value.toString()),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  void _exportData() {
    // TODO: Implement actual data export
    // final data = _analyticsService.exportAnalyticsData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon!')),
    );
  }
}
