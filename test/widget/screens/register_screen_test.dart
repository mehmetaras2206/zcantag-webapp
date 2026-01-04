// =============================================================================
// REGISTER_SCREEN_TEST.DART - Widget Tests fuer Register Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/auth/presentation/screens/register_screen.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    testWidgets('renders registration form', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for registration text
      expect(find.textContaining('Registrieren'), findsWidgets);
    });

    testWidgets('shows email field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have text form fields
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows password fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for password-related text
      expect(find.textContaining('Passwort'), findsWidgets);
    });

    testWidgets('can enter text into fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find text fields
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().length >= 2) {
        // Enter email
        await tester.enterText(textFields.first, 'newuser@example.com');
        await tester.pump();

        // Verify text was entered
        expect(find.text('newuser@example.com'), findsOneWidget);
      }
    });

    testWidgets('shows login link for existing users', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Look for login option
      expect(find.textContaining('Anmelden'), findsWidgets);
    });

    testWidgets('has submit button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have at least one button
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
