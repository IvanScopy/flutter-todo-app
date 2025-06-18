import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as app_date_utils;
import '../../data/models/task.dart';

class TaskItemWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.info,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => onToggleComplete(),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted 
                  ? TextDecoration.lineThrough 
                  : null,
              color: task.isCompleted 
                  ? AppColors.textSecondary 
                  : AppColors.textPrimary,
              fontWeight: task.isCompleted 
                  ? FontWeight.normal 
                  : FontWeight.w500,
            ),
          ),
          subtitle: _buildSubtitle(),
          trailing: _buildTrailing(),
          onTap: onEdit,
        ),
      ),
    );
  }

  Widget? _buildSubtitle() {
    final List<Widget> subtitleWidgets = [];

    // Add description if available
    if (task.description != null && task.description!.isNotEmpty) {
      subtitleWidgets.add(
        Text(
          task.description!,
          style: TextStyle(
            color: task.isCompleted 
                ? AppColors.textHint 
                : AppColors.textSecondary,
            decoration: task.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Add due date if available
    if (task.dueDate != null) {
      if (subtitleWidgets.isNotEmpty) {
        subtitleWidgets.add(const SizedBox(height: 4));
      }
      
      subtitleWidgets.add(_buildDueDateWidget());
    }

    if (subtitleWidgets.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: subtitleWidgets,
    );
  }

  Widget _buildDueDateWidget() {
    final dueDate = task.dueDate!;
    final isOverdue = app_date_utils.DateUtils.isOverdue(dueDate) && !task.isCompleted;
    final isToday = app_date_utils.DateUtils.isToday(dueDate);
    final isTomorrow = app_date_utils.DateUtils.isTomorrow(dueDate);
    
    String dateText;
    Color textColor;
    IconData icon;

    if (isOverdue) {
      dateText = 'Overdue • ${app_date_utils.DateUtils.formatDate(dueDate)}';
      textColor = AppColors.error;
      icon = Icons.warning;
    } else if (isToday) {
      dateText = 'Today • ${app_date_utils.DateUtils.formatTime(dueDate)}';
      textColor = AppColors.warning;
      icon = Icons.today;
    } else if (isTomorrow) {
      dateText = 'Tomorrow • ${app_date_utils.DateUtils.formatTime(dueDate)}';
      textColor = AppColors.info;
      icon = Icons.event;
    } else {
      dateText = app_date_utils.DateUtils.getRelativeDateString(dueDate);
      textColor = AppColors.textSecondary;
      icon = Icons.schedule;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: textColor,
        ),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: isOverdue || isToday ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget? _buildTrailing() {
    return _buildPriorityIndicator();
  }

  Widget _buildPriorityIndicator() {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = AppColors.priorityHigh;
        break;
      case TaskPriority.medium:
        priorityColor = AppColors.priorityMedium;
        break;
      case TaskPriority.low:
        priorityColor = AppColors.priorityLow;
        break;
    }

    return Container(
      width: 4,
      height: 32,
      decoration: BoxDecoration(
        color: task.isCompleted ? AppColors.textHint : priorityColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
