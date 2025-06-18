import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/task_provider.dart';
import '../providers/category_provider.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildStatisticsSection(context),
                const Divider(),
                _buildQuickActionsSection(context),
                const Divider(),
                _buildCategoriesSection(context),
                const Divider(),
                _buildSettingsSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.assignment,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay organized, get things done',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final stats = taskProvider.statistics;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (stats != null) ...[
                _buildStatItem(
                  context,
                  'Total Tasks',
                  stats.total.toString(),
                  Icons.assignment,
                  AppColors.info,
                ),
                const SizedBox(height: 8),
                _buildStatItem(
                  context,
                  'Completed',
                  stats.completed.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
                const SizedBox(height: 8),
                _buildStatItem(
                  context,
                  'Pending',
                  stats.pending.toString(),
                  Icons.pending,
                  AppColors.warning,
                ),
                const SizedBox(height: 8),
                _buildStatItem(
                  context,
                  'Overdue',
                  stats.overdue.toString(),
                  Icons.warning,
                  AppColors.error,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: stats.total > 0 ? stats.completionRate : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.completionPercentage.toStringAsFixed(1)}% completed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                const Text('Loading statistics...'),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Clear Completed'),
          onTap: () => _clearCompletedTasks(context),
        ),
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('Refresh'),
          onTap: () => _refreshData(context),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addCategory(context),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
            ...categoryProvider.categories.take(5).map((category) {
              final usageCount = categoryProvider.getCategoryUsageCount(category);
              return ListTile(
                leading: Icon(
                  category.icon,
                  color: category.colorValue,
                ),
                title: Text(category.name),
                trailing: usageCount > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: category.colorValue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          usageCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: category.colorValue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
                onTap: () => _filterByCategory(context, category),
              );
            }),
            if (categoryProvider.categories.length > 5)
              ListTile(
                leading: const Icon(Icons.more_horiz),
                title: const Text('View all categories'),
                onTap: () => _viewAllCategories(context),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () => _openSettings(context),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About'),
          onTap: () => _showAbout(context),
        ),
      ],
    );
  }

  Future<void> _clearCompletedTasks(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text(AppStrings.deleteAllCompletedConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final success = await taskProvider.deleteAllCompletedTasks();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Completed tasks cleared successfully'
                  : taskProvider.error ?? 'Failed to clear completed tasks',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _refreshData(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    taskProvider.refresh();
    categoryProvider.refresh();
    
    Navigator.of(context).pop(); // Close drawer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data refreshed')),
    );
  }

  void _addCategory(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    // TODO: Navigate to add category screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add category screen coming soon')),
    );
  }

  void _filterByCategory(BuildContext context, dynamic category) {
    Navigator.of(context).pop(); // Close drawer
    // TODO: Filter tasks by category
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filtering by ${category.name} coming soon')),
    );
  }

  void _viewAllCategories(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    // TODO: Navigate to categories screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Categories screen coming soon')),
    );
  }
  void _openSettings(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.assignment),
      children: [
        const Text('A simple and elegant to-do app built with Flutter.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Create and manage tasks'),
        const Text('• Set priorities and due dates'),
        const Text('• Organize with categories'),
        const Text('• Track your progress'),
      ],
    );
  }
}
