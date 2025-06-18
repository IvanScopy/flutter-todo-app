import 'package:flutter/foundation.dart';
import '../../../data/models/task.dart';
import '../../../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository = TaskRepository();
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSortBy _currentSort = TaskSortBy.createdDate;
  bool _sortAscending = false;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  TaskStatistics? _statistics;

  // Getters
  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  TaskSortBy get currentSort => _currentSort;
  bool get sortAscending => _sortAscending;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskStatistics? get statistics => _statistics;

  // Computed getters
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  int get totalTasksCount => _tasks.length;
  int get pendingTasksCount => pendingTasks.length;
  int get completedTasksCount => completedTasks.length;

  // Initialize provider
  Future<void> initialize() async {
    await loadTasks();
    await loadStatistics();
  }

  // Load tasks
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _clearError();
      
      _tasks = await _taskRepository.getTasks(
        filter: _currentFilter,
        sortBy: _currentSort,
        ascending: _sortAscending,
      );
      
      _applySearchFilter();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add new task
  Future<bool> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    int? categoryId,
  }) async {
    try {
      _clearError();
      
      final newTask = await _taskRepository.addTask(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        categoryId: categoryId,
      );
      
      _tasks.insert(0, newTask);
      _applySearchFilter();
      await loadStatistics();
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to add task: ${e.toString()}');
      return false;
    }
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      _clearError();
      
      final updatedTask = await _taskRepository.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      
      if (index != -1) {
        _tasks[index] = updatedTask;
        _applySearchFilter();
        await loadStatistics();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update task: ${e.toString()}');
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(Task task) async {
    try {
      _clearError();
      
      final updatedTask = await _taskRepository.toggleTaskCompletion(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      
      if (index != -1) {
        _tasks[index] = updatedTask;
        _applySearchFilter();
        await loadStatistics();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to toggle task: ${e.toString()}');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(int taskId) async {
    try {
      _clearError();
      
      await _taskRepository.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _applySearchFilter();
      await loadStatistics();
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to delete task: ${e.toString()}');
      return false;
    }
  }

  // Delete all completed tasks
  Future<bool> deleteAllCompletedTasks() async {
    try {
      _clearError();
      
      await _taskRepository.deleteAllCompletedTasks();
      _tasks.removeWhere((task) => task.isCompleted);
      _applySearchFilter();
      await loadStatistics();
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to delete completed tasks: ${e.toString()}');
      return false;
    }
  }

  // Set filter
  void setFilter(TaskFilter filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      loadTasks();
    }
  }

  // Set sort
  void setSort(TaskSortBy sortBy, {bool? ascending}) {
    bool changed = false;
    
    if (_currentSort != sortBy) {
      _currentSort = sortBy;
      changed = true;
    }
    
    if (ascending != null && _sortAscending != ascending) {
      _sortAscending = ascending;
      changed = true;
    }
    
    if (changed) {
      loadTasks();
    }
  }

  // Search tasks
  void searchTasks(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applySearchFilter();
    notifyListeners();
  }

  // Apply search filter
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTasks = List.from(_tasks);
    } else {
      _filteredTasks = _tasks.where((task) {
        final query = _searchQuery.toLowerCase();
        return task.title.toLowerCase().contains(query) ||
               (task.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _taskRepository.getTaskStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load statistics: $e');
    }
  }

  // Get task by ID
  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadTasks();
    await loadStatistics();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  void _clearError() {
    _error = null;
  }
}
