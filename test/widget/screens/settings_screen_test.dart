// =============================================================================
// SETTINGS_SCREEN_TEST.DART - Widget Tests fuer Settings Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/settings/presentation/screens/settings_screen.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('renders screen', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Screen should render
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('has app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Just ensure no exceptions are thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows screen title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Einstellungen'), findsOneWidget);
    });

    testWidgets('has scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
