import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/data/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should create task with all fields', () {
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        priority: TaskPriority.high,
        dueDate: DateTime(2024, 12, 31),
        categoryId: 1,
        createdAt: DateTime.now(),
      );

      expect(task.id, 1);
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, false);
      expect(task.priority, TaskPriority.high);
      expect(task.categoryId, 1);
    });

    test('should convert to and from map correctly', () {
      final originalTask = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        priority: TaskPriority.medium,
        dueDate: DateTime(2024, 12, 31),
        categoryId: 2,
        createdAt: DateTime(2024, 1, 1),
      );

      final map = originalTask.toMap();
      final recreatedTask = Task.fromMap(map);

      expect(recreatedTask.id, originalTask.id);
      expect(recreatedTask.title, originalTask.title);
      expect(recreatedTask.description, originalTask.description);
      expect(recreatedTask.isCompleted, originalTask.isCompleted);
      expect(recreatedTask.priority, originalTask.priority);
      expect(recreatedTask.categoryId, originalTask.categoryId);
    });

    test('should convert to and from JSON correctly', () {
      final originalTask = Task(
        title: 'JSON Test Task',
        description: 'JSON Description',
        isCompleted: false,
        priority: TaskPriority.low,
        categoryId: 3,
        createdAt: DateTime(2024, 6, 15),
      );

      final json = originalTask.toJson();
      final recreatedTask = Task.fromJson(json);

      expect(recreatedTask.title, originalTask.title);
      expect(recreatedTask.description, originalTask.description);
      expect(recreatedTask.isCompleted, originalTask.isCompleted);
      expect(recreatedTask.priority, originalTask.priority);
      expect(recreatedTask.categoryId, originalTask.categoryId);
    });

    test('should handle priority enum correctly', () {
      expect(TaskPriority.high.displayName, 'High');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.low.displayName, 'Low');

      expect(TaskPriority.high.value, 2);
      expect(TaskPriority.medium.value, 1);
      expect(TaskPriority.low.value, 0);
    });

    test('should create copyWith correctly', () {
      final originalTask = Task(
        id: 1,
        title: 'Original Task',
        description: 'Original Description',
        isCompleted: false,
        priority: TaskPriority.low,
        categoryId: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedTask = originalTask.copyWith(
        title: 'Updated Task',
        isCompleted: true,
        priority: TaskPriority.high,
      );

      expect(updatedTask.id, originalTask.id);
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.description, originalTask.description);
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.priority, TaskPriority.high);
      expect(updatedTask.categoryId, originalTask.categoryId);
    });

    test('should handle null values properly', () {
      final task = Task(
        title: 'Minimal Task',
        isCompleted: false,
        priority: TaskPriority.medium,
        createdAt: DateTime.now(),
      );

      expect(task.id, isNull);
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.categoryId, isNull);
    });
  });
}
