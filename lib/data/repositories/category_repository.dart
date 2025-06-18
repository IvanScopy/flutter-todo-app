import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data_sources/category_data_source.dart';

class CategoryRepository {
  final CategoryDataSource _categoryDataSource = CategoryDataSource();

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    return await _categoryDataSource.getAllCategories();
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    return await _categoryDataSource.getCategoryById(id);
  }

  // Add new category
  Future<Category> addCategory({
    required String name,
    required String color,
    required IconData icon,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    // Check if category name already exists
    final existingCategories = await getAllCategories();
    final nameExists = existingCategories.any(
      (category) => category.name.toLowerCase() == name.trim().toLowerCase(),
    );

    if (nameExists) {
      throw ArgumentError('Category with this name already exists');
    }

    final category = Category(
      name: name.trim(),
      color: color,
      icon: icon,
      createdAt: DateTime.now(),
    );

    final id = await _categoryDataSource.insertCategory(category);
    return category.copyWith(id: id);
  }

  // Update category
  Future<Category> updateCategory(Category category) async {
    if (category.id == null) {
      throw ArgumentError('Cannot update category without ID');
    }

    if (category.name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    // Check if category name already exists (excluding current category)
    final existingCategories = await getAllCategories();
    final nameExists = existingCategories.any(
      (c) => c.id != category.id && 
             c.name.toLowerCase() == category.name.trim().toLowerCase(),
    );

    if (nameExists) {
      throw ArgumentError('Category with this name already exists');
    }

    await _categoryDataSource.updateCategory(category);
    return category;
  }

  // Delete category
  Future<void> deleteCategory(int id) async {
    // Check if category is being used by any tasks
    final isInUse = await _categoryDataSource.isCategoryInUse(id);
    if (isInUse) {
      throw StateError('Cannot delete category that is being used by tasks');
    }

    await _categoryDataSource.deleteCategory(id);
  }

  // Force delete category (removes category from all tasks first)
  Future<void> forceDeleteCategory(int id) async {
    // Note: This would require updating all tasks to remove the category reference
    // For now, we'll just delete the category and let the database handle it with SET NULL
    await _categoryDataSource.deleteCategory(id);
  }

  // Check if category is in use
  Future<bool> isCategoryInUse(int id) async {
    return await _categoryDataSource.isCategoryInUse(id);
  }

  // Get category usage statistics
  Future<Map<Category, int>> getCategoryUsageStatistics() async {
    final categories = await getAllCategories();
    final usageCount = await _categoryDataSource.getCategoryUsageCount();
    
    final Map<Category, int> statistics = {};
    for (final category in categories) {
      if (category.id != null) {
        statistics[category] = usageCount[category.id!] ?? 0;
      }
    }
    
    return statistics;
  }

  // Get categories sorted by usage
  Future<List<Category>> getCategoriesByUsage({bool ascending = false}) async {
    final statistics = await getCategoryUsageStatistics();
    final categories = statistics.keys.toList();
    
    categories.sort((a, b) {
      final countA = statistics[a] ?? 0;
      final countB = statistics[b] ?? 0;
      final comparison = countA.compareTo(countB);
      return ascending ? comparison : -comparison;
    });
    
    return categories;
  }

  // Initialize default categories if none exist
  Future<void> initializeDefaultCategories() async {
    final existingCategories = await getAllCategories();
    if (existingCategories.isEmpty) {
      for (final defaultCategory in DefaultCategories.defaults) {
        await _categoryDataSource.insertCategory(defaultCategory);
      }
    }
  }

  // Get category colors that are already in use
  Future<List<String>> getUsedColors() async {
    final categories = await getAllCategories();
    return categories.map((category) => category.color).toList();
  }
}
