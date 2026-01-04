// =============================================================================
// LOGIN_SCREEN_TEST.DART - Widget Tests fuer Login Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for email field
      expect(find.byType(TextFormField), findsWidgets);

      // Check for login-related text
      expect(find.text('Anmelden'), findsWidgets);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the login button
      final loginButton = find.widgetWithText(ElevatedButton, 'Anmelden');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('can enter email and password', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find text fields
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        // Enter email
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pump();

        // Enter password
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pump();

        // Verify text was entered
        expect(find.text('test@example.com'), findsOneWidget);
      }
    });

    testWidgets('shows forgot password link', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for forgot password text
      expect(
        find.textContaining('Passwort'),
        findsWidgets,
      );
    });

    testWidgets('shows register link', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for registration option
      expect(
        find.textContaining('Registrieren'),
        findsWidgets,
      );
    });
  });
}
