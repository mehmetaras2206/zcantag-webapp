// =============================================================================
// FORGOT_PASSWORD_SCREEN_TEST.DART - Widget Tests fuer Forgot Password Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/auth/presentation/screens/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('renders forgot password form', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for password reset text
      expect(find.textContaining('Passwort'), findsWidgets);
    });

    testWidgets('shows email input field', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have text form field for email
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('can enter email address', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find email field
      final textFields = find.byType(TextFormField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.pump();

        expect(find.text('test@example.com'), findsOneWidget);
      }
    });

    testWidgets('shows submit button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have a button to submit
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('has app bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have AppBar
      expect(find.byType(AppBar), findsWidgets);
    });
  });
}
