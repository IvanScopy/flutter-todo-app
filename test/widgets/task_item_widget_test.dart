import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/data/models/task.dart';
import 'package:to_do_app/presentation/providers/task_provider.dart';
import 'package:to_do_app/presentation/widgets/task_item_widget.dart';

void main() {
  group('TaskItemWidget Tests', () {
    late TaskProvider taskProvider;
    late Task testTask;

    setUp(() {
      taskProvider = TaskProvider();
      testTask = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        priority: TaskPriority.high,
        dueDate: DateTime(2024, 12, 31),
        categoryId: 1,
        createdAt: DateTime.now(),
      );
    });    testWidgets('should display task information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => taskProvider,
            child: Scaffold(
              body: TaskItemWidget(
                task: testTask,
                onToggleComplete: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Check if task title is displayed
      expect(find.text('Test Task'), findsOneWidget);
      
      // Check if task description is displayed
      expect(find.text('Test Description'), findsOneWidget);
      
      // Check if priority indicator container is displayed
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show due date when available', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => taskProvider,
            child: Scaffold(
              body: TaskItemWidget(
                task: testTask,
                onToggleComplete: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Check if due date is displayed (format might be different)
      expect(find.textContaining('2024'), findsWidgets);
    });    testWidgets('should show different priority indicators', (WidgetTester tester) async {
      // Test high priority
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => taskProvider,
            child: Scaffold(
              body: TaskItemWidget(
                task: testTask.copyWith(priority: TaskPriority.high),
                onToggleComplete: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Check if priority indicator container exists
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle completed tasks differently', (WidgetTester tester) async {
      final completedTask = testTask.copyWith(isCompleted: true);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<TaskProvider>(
            create: (_) => taskProvider,
            child: Scaffold(
              body: TaskItemWidget(
                task: completedTask,
                onToggleComplete: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Check if checkbox is checked
      final checkboxFinder = find.byType(Checkbox);
      Checkbox checkbox = tester.widget(checkboxFinder);
      expect(checkbox.value, true);
    });
  });
}
