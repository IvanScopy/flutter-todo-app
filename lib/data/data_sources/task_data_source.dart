import '../models/task.dart';
import 'database_helper.dart';

class TaskDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Get tasks by status
  Future<List<Task>> getTasksByStatus({required bool isCompleted}) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [isCompleted ? 1 : 0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Get tasks by category
  Future<List<Task>> getTasksByCategory(int categoryId) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Get tasks by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'priority = ?',
      whereArgs: [priority.value],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Search tasks by title
  Future<List<Task>> searchTasks(String query) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Get tasks due today
  Future<List<Task>> getTasksDueToday() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final maps = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ? AND isCompleted = 0',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Get overdue tasks
  Future<List<Task>> getOverdueTasks() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    
    final maps = await db.query(
      'tasks',
      where: 'dueDate < ? AND isCompleted = 0 AND dueDate IS NOT NULL',
      whereArgs: [startOfDay],
      orderBy: 'dueDate ASC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  // Insert task
  Future<int> insertTask(Task task) async {
    final db = await _databaseHelper.database;
    return await db.insert('tasks', task.toMap());
  }

  // Update task
  Future<int> updateTask(Task task) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Toggle task completion
  Future<int> toggleTaskCompletion(int id, bool isCompleted) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete task
  Future<int> deleteTask(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all completed tasks
  Future<int> deleteAllCompletedTasks() async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
    );
  }

  // Get task statistics
  Future<Map<String, int>> getTaskStatistics() async {
    final db = await _databaseHelper.database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    final completedResult = await db.rawQuery('SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1');
    final pendingResult = await db.rawQuery('SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 0');
    final overdueResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE dueDate < ? AND isCompleted = 0 AND dueDate IS NOT NULL',
      [DateTime.now().millisecondsSinceEpoch],
    );
    
    return {
      'total': totalResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'pending': pendingResult.first['count'] as int,
      'overdue': overdueResult.first['count'] as int,
    };
  }
}
