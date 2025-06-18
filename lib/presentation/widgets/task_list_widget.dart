import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/task_repository.dart';
import '../providers/task_provider.dart';
import 'task_item_widget.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;

        if (tasks.isEmpty) {
          return _buildEmptyState(context, taskProvider);
        }

        return RefreshIndicator(
          onRefresh: taskProvider.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskItemWidget(
                  task: task,
                  onToggleComplete: () => taskProvider.toggleTaskCompletion(task),
                  onDelete: () => _confirmDelete(context, taskProvider, task.id!),
                  onEdit: () => _navigateToEdit(context, task),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskProvider taskProvider) {
    String message;
    IconData icon;

    switch (taskProvider.currentFilter) {
      case TaskFilter.pending:
        message = 'No pending tasks';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.completed:
        message = 'No completed tasks';
        icon = Icons.assignment_turned_in;
        break;
      default:
        message = AppStrings.noTasksFound;
        icon = Icons.assignment;
        break;
    }

    if (taskProvider.searchQuery.isNotEmpty) {
      message = 'No tasks found for "${taskProvider.searchQuery}"';
      icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (taskProvider.searchQuery.isEmpty && 
              taskProvider.currentFilter == TaskFilter.all) ...[
            const SizedBox(height: 16),
            Text(
              'Tap the + button to add your first task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (taskProvider.searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: taskProvider.clearSearch,
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TaskProvider taskProvider,
    int taskId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(AppStrings.deleteTaskConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await taskProvider.deleteTask(taskId);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(taskProvider.error ?? 'Failed to delete task'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToEdit(BuildContext context, dynamic task) {
    // TODO: Navigate to edit task screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit task screen coming soon')),
    );
  }
}
