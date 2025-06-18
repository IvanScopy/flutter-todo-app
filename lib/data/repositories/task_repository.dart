import '../models/task.dart';
import '../data_sources/task_data_source.dart';

enum TaskFilter {
  all,
  pending,
  completed,
  overdue,
  today,
}

enum TaskSortBy {
  createdDate,
  dueDate,
  priority,
  title,
}

class TaskRepository {
  final TaskDataSource _taskDataSource = TaskDataSource();

  // Get tasks with filtering and sorting
  Future<List<Task>> getTasks({
    TaskFilter filter = TaskFilter.all,
    TaskSortBy sortBy = TaskSortBy.createdDate,
    bool ascending = false,
    int? categoryId,
    TaskPriority? priority,
  }) async {
    List<Task> tasks;

    // Apply filter
    switch (filter) {
      case TaskFilter.pending:
        tasks = await _taskDataSource.getTasksByStatus(isCompleted: false);
        break;
      case TaskFilter.completed:
        tasks = await _taskDataSource.getTasksByStatus(isCompleted: true);
        break;
      case TaskFilter.overdue:
        tasks = await _taskDataSource.getOverdueTasks();
        break;
      case TaskFilter.today:
        tasks = await _taskDataSource.getTasksDueToday();
        break;      case TaskFilter.all:
        tasks = await _taskDataSource.getAllTasks();
        break;
    }

    // Apply category filter
    if (categoryId != null) {
      tasks = tasks.where((task) => task.categoryId == categoryId).toList();
    }

    // Apply priority filter
    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    // Apply sorting
    switch (sortBy) {
      case TaskSortBy.dueDate:
        tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          
          final comparison = a.dueDate!.compareTo(b.dueDate!);
          return ascending ? comparison : -comparison;
        });
        break;
      case TaskSortBy.priority:
        tasks.sort((a, b) {
          final comparison = a.priority.value.compareTo(b.priority.value);
          return ascending ? comparison : -comparison;
        });
        break;
      case TaskSortBy.title:
        tasks.sort((a, b) {
          final comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          return ascending ? comparison : -comparison;
        });
        break;      case TaskSortBy.createdDate:
        tasks.sort((a, b) {
          final comparison = a.createdAt.compareTo(b.createdAt);
          return ascending ? comparison : -comparison;
        });
        break;
    }

    return tasks;
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    if (query.trim().isEmpty) {
      return await getTasks();
    }
    return await _taskDataSource.searchTasks(query.trim());
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    return await _taskDataSource.getTaskById(id);
  }

  // Add new task
  Future<Task> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    int? categoryId,
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }

    final task = Task(
      title: title.trim(),
      description: description?.trim(),
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      categoryId: categoryId,
    );

    final id = await _taskDataSource.insertTask(task);
    return task.copyWith(id: id);
  }

  // Update task
  Future<Task> updateTask(Task task) async {
    if (task.id == null) {
      throw ArgumentError('Cannot update task without ID');
    }
    
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }

    await _taskDataSource.updateTask(task);
    return task;
  }

  // Toggle task completion
  Future<Task> toggleTaskCompletion(Task task) async {
    if (task.id == null) {
      throw ArgumentError('Cannot toggle task without ID');
    }

    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskDataSource.updateTask(updatedTask);
    return updatedTask;
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    await _taskDataSource.deleteTask(id);
  }

  // Delete all completed tasks
  Future<int> deleteAllCompletedTasks() async {
    return await _taskDataSource.deleteAllCompletedTasks();
  }

  // Get task statistics
  Future<TaskStatistics> getTaskStatistics() async {
    final stats = await _taskDataSource.getTaskStatistics();
    return TaskStatistics.fromMap(stats);
  }

  // Get tasks grouped by priority
  Future<Map<TaskPriority, List<Task>>> getTasksGroupedByPriority() async {
    final tasks = await getTasks(filter: TaskFilter.pending);
    final Map<TaskPriority, List<Task>> groupedTasks = {
      TaskPriority.high: [],
      TaskPriority.medium: [],
      TaskPriority.low: [],
    };

    for (final task in tasks) {
      groupedTasks[task.priority]!.add(task);
    }

    return groupedTasks;
  }

  // Get upcoming tasks (next 7 days)
  Future<List<Task>> getUpcomingTasks() async {
    final allTasks = await getTasks(filter: TaskFilter.pending);
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(nextWeek);
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }
}

// Task statistics model
class TaskStatistics {
  final int total;
  final int completed;
  final int pending;
  final int overdue;

  const TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  factory TaskStatistics.fromMap(Map<String, int> map) {
    return TaskStatistics(
      total: map['total'] ?? 0,
      completed: map['completed'] ?? 0,
      pending: map['pending'] ?? 0,
      overdue: map['overdue'] ?? 0,
    );
  }

  double get completionRate {
    if (total == 0) return 0.0;
    return completed / total;
  }

  double get completionPercentage {
    return completionRate * 100;
  }

  @override
  String toString() {
    return 'TaskStatistics(total: $total, completed: $completed, pending: $pending, overdue: $overdue)';
  }
}
