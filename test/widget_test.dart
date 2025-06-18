// This is a basic Flutter widget test for To-Do App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/main.dart';

void main() {
  testWidgets('To-Do App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that our app title is correct.
    expect(find.text('To-Do App'), findsOneWidget);
    
    // Verify that the FloatingActionButton exists.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    // Verify that we have filter tabs.
    expect(find.text('All'), findsOneWidget);
  });
}
