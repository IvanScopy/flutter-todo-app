import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:to_do_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('To-Do App Integration Tests', () {
    testWidgets('should complete full task management flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the Add Task FloatingActionButton
      final addTaskFab = find.byType(FloatingActionButton);
      expect(addTaskFab, findsOneWidget);

      // Tap the Add Task button
      await tester.tap(addTaskFab);
      await tester.pumpAndSettle();

      // Verify we're on the Add Task screen
      expect(find.text('Add Task'), findsOneWidget);

      // Find and fill in the task title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Integration Test Task');
      await tester.pumpAndSettle();

      // Find and fill in the task description
      final descriptionField = find.byType(TextFormField).at(1);
      await tester.enterText(descriptionField, 'This is a test task created by integration test');
      await tester.pumpAndSettle();

      // Save the task
      final saveButton = find.text('Save');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify we're back on the home screen
      expect(find.text('To-Do App'), findsOneWidget);

      // Verify the new task appears in the list
      expect(find.text('Integration Test Task'), findsOneWidget);
      expect(find.text('This is a test task created by integration test'), findsOneWidget);

      // Test task completion - find the checkbox for our task
      final taskCheckbox = find.byType(Checkbox).first;
      await tester.tap(taskCheckbox);
      await tester.pumpAndSettle();

      // Test filtering - tap on Completed tab
      final completedTab = find.text('Completed');
      if (completedTab.evaluate().isNotEmpty) {
        await tester.tap(completedTab);
        await tester.pumpAndSettle();

        // Verify the completed task is shown
        expect(find.text('Integration Test Task'), findsOneWidget);
      }

      // Test filtering - tap on All tab
      final allTab = find.text('All');
      if (allTab.evaluate().isNotEmpty) {
        await tester.tap(allTab);
        await tester.pumpAndSettle();
      }

      // Test search functionality
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField, 'Integration');
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.text('Integration Test Task'), findsOneWidget);

        // Clear search
        await tester.enterText(searchField, '');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should navigate through drawer menu', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open the drawer
      final drawerButton = find.byIcon(Icons.menu);
      if (drawerButton.evaluate().isNotEmpty) {
        await tester.tap(drawerButton);
        await tester.pumpAndSettle();

        // Verify drawer items
        expect(find.text('To-Do App'), findsWidgets);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);

        // Close drawer
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle empty state correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // If there are no tasks, verify empty state
      final emptyStateText = find.text('No tasks yet');
      if (emptyStateText.evaluate().isNotEmpty) {
        expect(emptyStateText, findsOneWidget);
        expect(find.text('Create your first task to get started!'), findsOneWidget);
      }
    });
  });
}
