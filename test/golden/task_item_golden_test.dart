import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/core/constants/app_theme.dart';
import 'package:to_do_app/data/models/task.dart';
import 'package:to_do_app/presentation/providers/task_provider.dart';
import 'package:to_do_app/presentation/widgets/task_item_widget.dart';

void main() {
  group('Golden Tests', () {
    testWidgets('TaskItemWidget golden test - uncompleted high priority task', (WidgetTester tester) async {
      final task = Task(
        id: 1,
        title: 'Complete project presentation',
        description: 'Prepare slides and demo for the quarterly review meeting',
        isCompleted: false,
        priority: TaskPriority.high,
        dueDate: DateTime(2024, 12, 25),
        categoryId: 1,
        createdAt: DateTime(2024, 12, 20),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => TaskProvider(),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TaskItemWidget(
                  task: task,
                  onToggleComplete: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TaskItemWidget),
        matchesGoldenFile('task_item_high_priority.png'),
      );
    });

    testWidgets('TaskItemWidget golden test - completed task', (WidgetTester tester) async {
      final task = Task(
        id: 2,
        title: 'Buy groceries',
        description: 'Milk, bread, eggs, and vegetables',
        isCompleted: true,
        priority: TaskPriority.medium,
        dueDate: DateTime(2024, 12, 20),
        categoryId: 2,
        createdAt: DateTime(2024, 12, 19),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => TaskProvider(),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TaskItemWidget(
                  task: task,
                  onToggleComplete: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TaskItemWidget),
        matchesGoldenFile('task_item_completed.png'),
      );
    });

    testWidgets('TaskItemWidget golden test - low priority task without description', (WidgetTester tester) async {
      final task = Task(
        id: 3,
        title: 'Call mom',
        isCompleted: false,
        priority: TaskPriority.low,
        categoryId: 3,
        createdAt: DateTime(2024, 12, 20),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => TaskProvider(),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TaskItemWidget(
                  task: task,
                  onToggleComplete: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TaskItemWidget),
        matchesGoldenFile('task_item_minimal.png'),
      );
    });
  });
}
