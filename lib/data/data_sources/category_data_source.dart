import '../models/category.dart';
import 'database_helper.dart';

class CategoryDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  // Insert category
  Future<int> insertCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.insert('categories', category.toMap());
  }

  // Update category
  Future<int> updateCategory(Category category) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if category is being used by any tasks
  Future<bool> isCategoryInUse(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Get category usage count
  Future<Map<int, int>> getCategoryUsageCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT categoryId, COUNT(*) as count 
      FROM tasks 
      WHERE categoryId IS NOT NULL 
      GROUP BY categoryId
    ''');
    
    final Map<int, int> usageCount = {};
    for (final row in result) {
      final categoryId = row['categoryId'] as int;
      final count = row['count'] as int;
      usageCount[categoryId] = count;
    }
    
    return usageCount;
  }
}
