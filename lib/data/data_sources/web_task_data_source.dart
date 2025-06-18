import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class WebTaskDataSource {
  static const String _tasksKey = 'tasks';
  
  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus({required bool isCompleted}) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.isCompleted == isCompleted).toList();
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    final tasks = await getAllTasks();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Insert task
  Future<int> insertTask(Task task) async {
    final tasks = await getAllTasks();
    final newId = tasks.isEmpty ? 1 : tasks.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    final newTask = task.copyWith(id: newId);
    tasks.add(newTask);
    await _saveTasks(tasks);
    return newId;
  }

  // Update task
  Future<int> updateTask(Task task) async {
    final tasks = await getAllTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(tasks);
      return 1;
    }
    return 0;
  }

  // Delete task
  Future<int> deleteTask(int id) async {
    final tasks = await getAllTasks();
    final initialLength = tasks.length;
    tasks.removeWhere((task) => task.id == id);
    await _saveTasks(tasks);
    return initialLength - tasks.length;
  }

  // Delete all completed tasks
  Future<int> deleteAllCompletedTasks() async {
    final tasks = await getAllTasks();
    final initialLength = tasks.length;
    tasks.removeWhere((task) => task.isCompleted);
    await _saveTasks(tasks);
    return initialLength - tasks.length;
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStatistics() async {
    final tasks = await getAllTasks();
    final total = tasks.length;
    final completed = tasks.where((task) => task.isCompleted).length;
    final pending = total - completed;
    final overdue = tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(DateTime.now()) && 
      !task.isCompleted
    ).length;
    
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => 
      task.title.toLowerCase().contains(query.toLowerCase()) ||
      (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  // Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    final tasks = await getAllTasks();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return tasks.where((task) => 
      task.dueDate != null &&
      task.dueDate!.isAfter(startOfDay) &&
      task.dueDate!.isBefore(endOfDay) &&
      !task.isCompleted
    ).toList();
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    final tasks = await getAllTasks();
    final now = DateTime.now();
    
    return tasks.where((task) => 
      task.dueDate != null &&
      task.dueDate!.isBefore(now) &&
      !task.isCompleted
    ).toList();
  }

  Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }
}
