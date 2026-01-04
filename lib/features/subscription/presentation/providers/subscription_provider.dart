// =============================================================================
// SUBSCRIPTION_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Subscription State Management
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/features/subscription/domain/entities/plan.dart';
import '../../../../shared/features/company/domain/entities/company.dart';

// =============================================================================
// SUBSCRIPTION STATE
// =============================================================================

sealed class SubscriptionState {
  const SubscriptionState();
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded({
    required this.currentPlan,
    required this.subscription,
    required this.availablePlans,
    this.selectedInterval = BillingInterval.monthly,
  });

  final Plan currentPlan;
  final Subscription? subscription;
  final List<Plan> availablePlans;
  final BillingInterval selectedInterval;

  SubscriptionLoaded copyWith({
    Plan? currentPlan,
    Subscription? subscription,
    List<Plan>? availablePlans,
    BillingInterval? selectedInterval,
  }) {
    return SubscriptionLoaded(
      currentPlan: currentPlan ?? this.currentPlan,
      subscription: subscription ?? this.subscription,
      availablePlans: availablePlans ?? this.availablePlans,
      selectedInterval: selectedInterval ?? this.selectedInterval,
    );
  }
}

class SubscriptionError extends SubscriptionState {
  const SubscriptionError(this.message);
  final String message;
}

// =============================================================================
// SUBSCRIPTION NOTIFIER
// =============================================================================

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(const SubscriptionInitial());

  /// Laedt Subscription-Daten
  Future<void> loadSubscription(PlanType currentPlanType) async {
    state = const SubscriptionLoading();

    try {
      // For now, use hardcoded plans
      // In production, this would fetch from API
      final currentPlan = PlanData.byType(currentPlanType);

      state = SubscriptionLoaded(
        currentPlan: currentPlan,
        subscription: null, // Would come from API
        availablePlans: PlanData.all,
      );
    } catch (e) {
      state = SubscriptionError('Fehler beim Laden: $e');
    }
  }

  /// Wechselt Billing Interval
  void setBillingInterval(BillingInterval interval) {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return;

    state = currentState.copyWith(selectedInterval: interval);
  }

  /// Prueft ob ein Upgrade moeglich ist
  bool canUpgradeTo(PlanType targetPlan) {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return false;

    final currentIndex =
        PlanType.values.indexOf(currentState.currentPlan.type);
    final targetIndex = PlanType.values.indexOf(targetPlan);

    return targetIndex > currentIndex;
  }

  /// Prueft ob ein Downgrade moeglich ist
  bool canDowngradeTo(PlanType targetPlan) {
    final currentState = state;
    if (currentState is! SubscriptionLoaded) return false;

    final currentIndex =
        PlanType.values.indexOf(currentState.currentPlan.type);
    final targetIndex = PlanType.values.indexOf(targetPlan);

    return targetIndex < currentIndex;
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

final billingIntervalProvider = StateProvider<BillingInterval>((ref) {
  return BillingInterval.monthly;
});

/// Provider fuer Feature-Pruefungen
final canAccessFeatureProvider =
    Provider.family<bool, String>((ref, feature) {
  final subscriptionState = ref.watch(subscriptionProvider);

  if (subscriptionState is! SubscriptionLoaded) return false;

  final planType = subscriptionState.currentPlan.type;

  switch (feature) {
    case 'webContacts':
      return planType.hasWebContacts;
    case 'analytics':
      return planType.hasAnalytics;
    case 'premiumAnalytics':
      return planType.hasPremiumAnalytics;
    case 'enterpriseAnalytics':
      return planType.hasEnterpriseAnalytics;
    case 'pushCampaigns':
      return planType.hasPushCampaigns;
    case 'abTest':
      return planType.hasAbTest;
    default:
      return false;
  }
});
