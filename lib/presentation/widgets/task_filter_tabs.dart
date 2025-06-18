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
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TabBar(
            controller: null,
            isScrollable: false,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,            tabs: [
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
    return GestureDetector(
      onTap: () => taskProvider.setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
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
    );
  }
}
