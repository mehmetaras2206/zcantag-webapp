// =============================================================================
// ADMIN_FLOW_TEST.DART - Integration Tests fuer Admin Flow
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() {
  group('Admin Flow Integration Tests', () {
    group('Admin Dashboard', () {
      testWidgets('renders admin dashboard', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const AdminDashboardScreen(),
              routes: {
                '/admin/company': (context) => const Scaffold(
                      body: Center(child: Text('Company')),
                    ),
                '/admin/team/invite': (context) => const Scaffold(
                      body: Center(child: Text('Invite')),
                    ),
                '/admin/analytics': (context) => const Scaffold(
                      body: Center(child: Text('Analytics')),
                    ),
                '/admin/campaigns/new': (context) => const Scaffold(
                      body: Center(child: Text('New Campaign')),
                    ),
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show dashboard title
        expect(find.text('Dashboard'), findsOneWidget);

        // Should show welcome message
        expect(find.text('Willkommen im Admin-Bereich'), findsOneWidget);
      });

      testWidgets('shows stat cards', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const AdminDashboardScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show stat cards
        expect(find.text('Aktive Karten'), findsOneWidget);
        expect(find.text('Team-Mitglieder'), findsOneWidget);
        expect(find.text('Kartenaufrufe'), findsOneWidget);
        expect(find.text('Neue Kontakte'), findsOneWidget);
      });

      testWidgets('shows quick actions', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const AdminDashboardScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show quick actions
        expect(find.text('Schnellzugriff'), findsOneWidget);
        expect(find.text('Unternehmensprofil'), findsOneWidget);
        expect(find.text('Mitarbeiter einladen'), findsOneWidget);
        expect(find.text('Analytics ansehen'), findsOneWidget);
        expect(find.text('Kampagne erstellen'), findsOneWidget);
      });

      testWidgets('shows recent activities', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: const AdminDashboardScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show activity section
        expect(find.text('Letzte Aktivitaeten'), findsOneWidget);
      });
    });
  });
}
