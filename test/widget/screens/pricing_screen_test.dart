// =============================================================================
// PRICING_SCREEN_TEST.DART - Widget Tests fuer Pricing Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:webapp/features/subscription/presentation/screens/pricing_screen.dart';
import 'package:webapp/shared/features/subscription/domain/entities/plan.dart';
import 'package:webapp/shared/features/company/domain/entities/company.dart';

void main() {
  group('PricingScreen Widget Tests', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: PricingScreen(),
        ),
      );
    }

    testWidgets('renders screen title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Preise & Abos'), findsOneWidget);
    });

    testWidgets('shows plan selection header', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Waehlen Sie Ihren Plan'), findsOneWidget);
    });

    testWidgets('shows billing interval toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Monatlich'), findsOneWidget);
      expect(find.text('Jaehrlich'), findsOneWidget);
    });

    testWidgets('shows yearly discount badge', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('-20%'), findsOneWidget);
    });

    testWidgets('shows flexible pricing subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Flexible Preise fuer jeden Bedarf'), findsOneWidget);
    });

    testWidgets('has scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });

  group('SubscriptionState Tests', () {
    test('SubscriptionInitial is created correctly', () {
      const state = SubscriptionInitial();
      expect(state, isA<SubscriptionState>());
    });

    test('SubscriptionLoading is created correctly', () {
      const state = SubscriptionLoading();
      expect(state, isA<SubscriptionState>());
    });

    test('SubscriptionError contains message', () {
      const state = SubscriptionError('Test error');
      expect(state.message, 'Test error');
    });
  });

  group('SubscriptionNotifier Tests', () {
    test('initial state is SubscriptionInitial', () {
      final notifier = SubscriptionNotifier();
      expect(notifier.state, isA<SubscriptionInitial>());
    });

    test('loadSubscription changes state to SubscriptionLoaded', () async {
      final notifier = SubscriptionNotifier();
      await notifier.loadSubscription(PlanType.free);
      expect(notifier.state, isA<SubscriptionLoaded>());
    });

    test('canUpgradeTo returns true for higher plans', () async {
      final notifier = SubscriptionNotifier();
      await notifier.loadSubscription(PlanType.free);
      expect(notifier.canUpgradeTo(PlanType.basic), true);
      expect(notifier.canUpgradeTo(PlanType.premium), true);
      expect(notifier.canUpgradeTo(PlanType.enterprise), true);
    });

    test('canUpgradeTo returns false for same or lower plans', () async {
      final notifier = SubscriptionNotifier();
      await notifier.loadSubscription(PlanType.premium);
      expect(notifier.canUpgradeTo(PlanType.free), false);
      expect(notifier.canUpgradeTo(PlanType.basic), false);
      expect(notifier.canUpgradeTo(PlanType.premium), false);
    });

    test('canDowngradeTo returns true for lower plans', () async {
      final notifier = SubscriptionNotifier();
      await notifier.loadSubscription(PlanType.enterprise);
      expect(notifier.canDowngradeTo(PlanType.premium), true);
      expect(notifier.canDowngradeTo(PlanType.basic), true);
      expect(notifier.canDowngradeTo(PlanType.free), true);
    });

    test('canDowngradeTo returns false for same or higher plans', () async {
      final notifier = SubscriptionNotifier();
      await notifier.loadSubscription(PlanType.basic);
      expect(notifier.canDowngradeTo(PlanType.premium), false);
      expect(notifier.canDowngradeTo(PlanType.enterprise), false);
      expect(notifier.canDowngradeTo(PlanType.basic), false);
    });
  });

  group('BillingInterval Tests', () {
    test('BillingInterval enum has correct values', () {
      expect(BillingInterval.values.length, 2);
      expect(BillingInterval.values, contains(BillingInterval.monthly));
      expect(BillingInterval.values, contains(BillingInterval.yearly));
    });
  });
}
