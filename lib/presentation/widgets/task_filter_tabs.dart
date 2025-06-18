import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/task_repository.dart';
import '../providers/task_provider.dart';

class TaskFilterTabs extends StatelessWidget {
  const TaskFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildTab(
                AppStrings.all,
                taskProvider.totalTasksCount,
                TaskFilter.all,
                taskProvider.currentFilter,
                taskProvider,
                context,
              ),
              _buildTab(
                AppStrings.pending,
                taskProvider.pendingTasksCount,
                TaskFilter.pending,
                taskProvider.currentFilter,
                taskProvider,
                context,
              ),
              _buildTab(
                AppStrings.completed,
                taskProvider.completedTasksCount,
                TaskFilter.completed,
                taskProvider.currentFilter,
                taskProvider,
                context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    String title,
    int count,
    TaskFilter filter,
    TaskFilter currentFilter,
    TaskProvider taskProvider,
    BuildContext context,
  ) {
    final isSelected = currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => taskProvider.setFilter(filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
