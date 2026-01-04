// =============================================================================
// ADMIN_DASHBOARD_SCREEN_TEST.DART - Widget Tests fuer Admin Dashboard Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() {
  group('AdminDashboardScreen Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: const AdminDashboardScreen(),
          routes: {
            '/admin/company': (context) => const Scaffold(
                  body: Center(child: Text('Company Profile')),
                ),
            '/admin/team/invite': (context) => const Scaffold(
                  body: Center(child: Text('Invite Member')),
                ),
            '/admin/analytics': (context) => const Scaffold(
                  body: Center(child: Text('Analytics')),
                ),
            '/admin/campaigns/new': (context) => const Scaffold(
                  body: Center(child: Text('New Campaign')),
                ),
          },
        ),
      );
    }

    testWidgets('renders dashboard title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('shows welcome message', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Willkommen im Admin-Bereich'), findsOneWidget);
    });

    testWidgets('shows stat cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for stat card titles
      expect(find.text('Aktive Karten'), findsOneWidget);
      expect(find.text('Team-Mitglieder'), findsOneWidget);
      expect(find.text('Kartenaufrufe'), findsOneWidget);
      expect(find.text('Neue Kontakte'), findsOneWidget);
    });

    testWidgets('shows stat values', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('1.2K'), findsOneWidget);
      expect(find.text('89'), findsOneWidget);
    });

    testWidgets('shows quick actions section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Schnellzugriff'), findsOneWidget);
    });

    testWidgets('shows quick action cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unternehmensprofil'), findsOneWidget);
      expect(find.text('Mitarbeiter einladen'), findsOneWidget);
      expect(find.text('Analytics ansehen'), findsOneWidget);
      expect(find.text('Kampagne erstellen'), findsOneWidget);
    });

    testWidgets('shows recent activities section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Letzte Aktivitaeten'), findsOneWidget);
    });

    testWidgets('shows activity items', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Max Mustermann eingeladen'), findsOneWidget);
      expect(find.text('Neue Karte erstellt'), findsOneWidget);
      expect(find.text('Kampagne gesendet'), findsOneWidget);
    });

    testWidgets('shows trend badges on stat cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('+3 diese Woche'), findsOneWidget);
      expect(find.text('2 offen'), findsOneWidget);
      expect(find.text('+18% MTM'), findsOneWidget);
      expect(find.text('+12 diese Woche'), findsOneWidget);
    });

    testWidgets('has scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows icons for stat cards', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.credit_card), findsWidgets);
      expect(find.byIcon(Icons.people), findsWidgets);
      expect(find.byIcon(Icons.visibility), findsWidgets);
      expect(find.byIcon(Icons.contacts), findsWidgets);
    });

    testWidgets('shows icons for quick actions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.business), findsWidgets);
      expect(find.byIcon(Icons.person_add), findsWidgets);
      expect(find.byIcon(Icons.analytics), findsWidgets);
      expect(find.byIcon(Icons.campaign), findsWidgets);
    });
  });
}
