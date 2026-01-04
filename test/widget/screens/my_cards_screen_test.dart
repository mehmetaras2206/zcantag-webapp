// =============================================================================
// MY_CARDS_SCREEN_TEST.DART - Widget Tests fuer My Cards Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/cards/presentation/screens/my_cards_screen.dart';
import 'package:webapp/features/cards/presentation/providers/cards_provider.dart';

void main() {
  group('MyCardsScreen Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: const MyCardsScreen(),
          routes: {
            '/cards/new': (context) => const Scaffold(
                  body: Center(child: Text('New Card')),
                ),
          },
        ),
      );
    }

    testWidgets('renders screen title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Meine Karten'), findsOneWidget);
    });

    testWidgets('shows floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Neue Karte'), findsOneWidget);
    });

    testWidgets('shows refresh button in appbar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // May have multiple refresh icons (appbar + pull-to-refresh)
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Screen should render without throwing exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('has app bar with correct title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Meine Karten'), findsOneWidget);
    });
  });

  group('CardsState Tests', () {
    test('CardsInitial is created correctly', () {
      const state = CardsInitial();
      expect(state, isA<CardsState>());
    });

    test('CardsLoading is created correctly', () {
      const state = CardsLoading();
      expect(state, isA<CardsState>());
    });

    test('CardsError contains message', () {
      const state = CardsError('Test error');
      expect(state.message, 'Test error');
    });
  });
}
