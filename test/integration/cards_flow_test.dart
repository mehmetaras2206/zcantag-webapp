// =============================================================================
// CARDS_FLOW_TEST.DART - Integration Tests fuer Cards Flow
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/cards/presentation/screens/my_cards_screen.dart';
import 'package:webapp/features/cards/presentation/providers/cards_provider.dart';

void main() {
  group('Cards Flow Integration Tests', () {
    group('My Cards Screen', () {
      testWidgets('renders cards list screen', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const MyCardsScreen(),
              routes: {
                '/cards/new': (context) => const Scaffold(
                      body: Center(child: Text('New Card')),
                    ),
              },
            ),
          ),
        );

        await tester.pump();

        // Should render screen title
        expect(find.text('Meine Karten'), findsOneWidget);

        // Should show FAB for creating new card
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('shows refresh button', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const MyCardsScreen(),
            ),
          ),
        );

        await tester.pump();

        // Should have refresh button(s) - may have multiple (appbar + pull-to-refresh)
        expect(find.byIcon(Icons.refresh), findsWidgets);
      });
    });
  });

  group('Cards State Tests', () {
    test('CardsInitial state is default', () {
      const state = CardsInitial();
      expect(state, isA<CardsState>());
    });

    test('CardsLoading state is valid', () {
      const state = CardsLoading();
      expect(state, isA<CardsState>());
    });

    test('CardsError state contains message', () {
      const state = CardsError('Network error');
      expect(state.message, 'Network error');
    });
  });
}
