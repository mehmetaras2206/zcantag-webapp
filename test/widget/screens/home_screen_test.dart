// =============================================================================
// HOME_SCREEN_TEST.DART - Widget Tests fuer Home Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/home/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: const HomeScreen(),
          routes: {
            '/cards': (context) => const Scaffold(
                  body: Center(child: Text('My Cards')),
                ),
            '/contacts': (context) => const Scaffold(
                  body: Center(child: Text('Contacts')),
                ),
            '/admin': (context) => const Scaffold(
                  body: Center(child: Text('Admin')),
                ),
            '/settings': (context) => const Scaffold(
                  body: Center(child: Text('Settings')),
                ),
          },
        ),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Home screen should render
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows navigation elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have navigation options
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('has scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should be scrollable
      final scrollables = find.byType(Scrollable);
      expect(scrollables, findsWidgets);
    });
  });
}
