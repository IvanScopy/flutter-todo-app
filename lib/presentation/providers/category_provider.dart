import 'package:flutter/material.dart';
import '../../../data/models/category.dart' as models;
import '../../../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository = CategoryRepository();
  
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  Map<models.Category, int> _usageStatistics = {};

  // Getters
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<models.Category, int> get usageStatistics => _usageStatistics;

  // Initialize provider
  Future<void> initialize() async {
    await loadCategories();
    await loadUsageStatistics();
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _clearError();
      
      _categories = await _categoryRepository.getAllCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Add new category
  Future<bool> addCategory({
    required String name,
    required String color,
    required IconData icon,
  }) async {
    try {
      _clearError();
      
      final newCategory = await _categoryRepository.addCategory(
        name: name,
        color: color,
        icon: icon,
      );
      
      _categories.add(newCategory);
      _categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to add category: ${e.toString()}');
      return false;
    }
  }
  // Update category
  Future<bool> updateCategory(models.Category category) async {
    try {
      _clearError();
      
      final updatedCategory = await _categoryRepository.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      
      if (index != -1) {
        _categories[index] = updatedCategory;
        _categories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update category: ${e.toString()}');
      return false;
    }
  }

  // Delete category
  Future<bool> deleteCategory(int categoryId) async {
    try {
      _clearError();
      
      await _categoryRepository.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      _usageStatistics.removeWhere((category, count) => category.id == categoryId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to delete category: ${e.toString()}');
      return false;
    }
  }

  // Force delete category (removes from tasks too)
  Future<bool> forceDeleteCategory(int categoryId) async {
    try {
      _clearError();
      
      await _categoryRepository.forceDeleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
      _usageStatistics.removeWhere((category, count) => category.id == categoryId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Failed to force delete category: ${e.toString()}');
      return false;
    }
  }

  // Check if category is in use
  Future<bool> isCategoryInUse(int categoryId) async {
    try {
      return await _categoryRepository.isCategoryInUse(categoryId);
    } catch (e) {
      _setError('Failed to check category usage: ${e.toString()}');
      return false;
    }
  }

  // Load usage statistics
  Future<void> loadUsageStatistics() async {
    try {
      _usageStatistics = await _categoryRepository.getCategoryUsageStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load usage statistics: $e');
    }
  }
  // Get category by ID
  models.Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get categories sorted by usage
  Future<List<models.Category>> getCategoriesByUsage({bool ascending = false}) async {
    try {
      return await _categoryRepository.getCategoriesByUsage(ascending: ascending);
    } catch (e) {
      _setError('Failed to get categories by usage: ${e.toString()}');
      return _categories;
    }
  }

  // Get used colors
  List<String> getUsedColors() {
    return _categories.map((category) => category.color).toList();
  }

  // Check if category name exists
  bool categoryNameExists(String name, {int? excludeId}) {
    return _categories.any((category) => 
      category.name.toLowerCase() == name.toLowerCase() && 
      category.id != excludeId);
  }
  // Get category usage count
  int getCategoryUsageCount(models.Category category) {
    return _usageStatistics[category] ?? 0;
  }

  // Initialize default categories
  Future<void> initializeDefaultCategories() async {
    try {
      await _categoryRepository.initializeDefaultCategories();
      await loadCategories();
    } catch (e) {
      _setError('Failed to initialize default categories: ${e.toString()}');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadCategories();
    await loadUsageStatistics();
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
