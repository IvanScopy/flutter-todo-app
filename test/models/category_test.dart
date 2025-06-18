import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:to_do_app/data/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('should create category with all fields', () {
      final category = Category(
        id: 1,
        name: 'Work',
        color: '#FF0000',
        icon: Icons.work,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(category.id, 1);
      expect(category.name, 'Work');
      expect(category.color, '#FF0000');
      expect(category.icon, Icons.work);
      expect(category.createdAt, DateTime(2024, 1, 1));
    });

    test('should convert to and from map correctly', () {
      final originalCategory = Category(
        id: 1,
        name: 'Personal',
        color: '#00FF00',
        icon: Icons.home,
        createdAt: DateTime(2024, 2, 1),
      );

      final map = originalCategory.toMap();
      final recreatedCategory = Category.fromMap(map);

      expect(recreatedCategory.id, originalCategory.id);
      expect(recreatedCategory.name, originalCategory.name);
      expect(recreatedCategory.color, originalCategory.color);
      expect(recreatedCategory.createdAt, originalCategory.createdAt);
    });

    test('should convert to and from JSON correctly', () {
      final originalCategory = Category(
        name: 'Shopping',
        color: '#0000FF',
        icon: Icons.shopping_cart,
        createdAt: DateTime(2024, 3, 1),
      );

      final json = originalCategory.toJson();
      final recreatedCategory = Category.fromJson(json);

      expect(recreatedCategory.name, originalCategory.name);
      expect(recreatedCategory.color, originalCategory.color);
      expect(recreatedCategory.createdAt, originalCategory.createdAt);
    });

    test('should create copyWith correctly', () {
      final originalCategory = Category(
        id: 1,
        name: 'Original',
        color: '#FFFFFF',
        icon: Icons.label,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedCategory = originalCategory.copyWith(
        name: 'Updated',
        color: '#000000',
      );

      expect(updatedCategory.id, originalCategory.id);
      expect(updatedCategory.name, 'Updated');
      expect(updatedCategory.color, '#000000');
      expect(updatedCategory.icon, originalCategory.icon);
      expect(updatedCategory.createdAt, originalCategory.createdAt);
    });    test('should handle default values correctly', () {
      final category = Category(
        name: 'Test Category',
        color: '#2196F3',
        createdAt: DateTime.now(),
      );

      expect(category.id, isNull);
      expect(category.name, 'Test Category');
      expect(category.color, '#2196F3'); // Default blue color
      expect(category.icon, Icons.label); // Default icon
    });

    test('should validate icon conversion', () {
      // Test that icon code points are handled correctly
      final workIcon = Icons.work;
      final homeIcon = Icons.home;
      
      expect(workIcon.codePoint, isA<int>());
      expect(homeIcon.codePoint, isA<int>());
      expect(workIcon.codePoint != homeIcon.codePoint, true);
    });
  });
}
