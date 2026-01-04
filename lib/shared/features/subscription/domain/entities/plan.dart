// =============================================================================
// PLAN.DART
// =============================================================================
// Subscription Plan Domain Entities
// =============================================================================

import '../../../../../../shared/features/company/domain/entities/company.dart';

/// Billing Interval
enum BillingInterval {
  monthly('monthly', 'Monatlich'),
  yearly('yearly', 'Jaehrlich');

  const BillingInterval(this.value, this.displayName);
  final String value;
  final String displayName;

  static BillingInterval fromValue(String value) {
    return BillingInterval.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BillingInterval.monthly,
    );
  }
}

/// Subscription Plan
class Plan {
  const Plan({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.digistore24ProductId,
    this.isPopular = false,
  });

  final String id;
  final PlanType type;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<PlanFeature> features;
  final String? digistore24ProductId;
  final bool isPopular;

  /// Jaehrlicher Rabatt in Prozent
  double get yearlyDiscount {
    if (monthlyPrice <= 0) return 0;
    final monthlyTotal = monthlyPrice * 12;
    return ((monthlyTotal - yearlyPrice) / monthlyTotal) * 100;
  }

  /// Preis pro Monat bei jaehrlicher Zahlung
  double get effectiveMonthlyPrice => yearlyPrice / 12;

  /// Digistore24 Buy-URL
  String? getBuyUrl(BillingInterval interval) {
    if (digistore24ProductId == null) return null;
    // Format: https://www.digistore24.com/product/{product_id}
    return 'https://www.digistore24.com/product/$digistore24ProductId';
  }

  /// Ist kostenlos
  bool get isFree => type == PlanType.free;

  /// Copy with
  Plan copyWith({
    String? id,
    PlanType? type,
    String? name,
    String? description,
    double? monthlyPrice,
    double? yearlyPrice,
    List<PlanFeature>? features,
    String? digistore24ProductId,
    bool? isPopular,
  }) {
    return Plan(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      features: features ?? this.features,
      digistore24ProductId: digistore24ProductId ?? this.digistore24ProductId,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}

/// Plan Feature
class PlanFeature {
  const PlanFeature({
    required this.name,
    required this.included,
    this.limit,
    this.description,
  });

  final String name;
  final bool included;
  final String? limit;
  final String? description;

  String get displayValue {
    if (!included) return '-';
    if (limit != null) return limit!;
    return 'check'; // Will be rendered as checkmark
  }
}

/// Current Subscription
class Subscription {
  const Subscription({
    required this.id,
    required this.companyId,
    required this.planType,
    required this.status,
    this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.billingInterval,
    this.cancelledAt,
    this.digistore24OrderId,
  });

  final String id;
  final String companyId;
  final PlanType planType;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final BillingInterval? billingInterval;
  final DateTime? cancelledAt;
  final String? digistore24OrderId;

  /// Ist aktiv
  bool get isActive => status == SubscriptionStatus.active;

  /// Ist gekuendigt
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  /// Laeuft bald aus
  bool get expiresSoon {
    if (endDate == null) return false;
    final daysUntilExpiry = endDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7;
  }

  /// Tage bis Ablauf
  int? get daysUntilExpiry {
    if (endDate == null) return null;
    return endDate!.difference(DateTime.now()).inDays;
  }
}

/// Subscription Status
enum SubscriptionStatus {
  active('active', 'Aktiv'),
  cancelled('cancelled', 'Gekuendigt'),
  expired('expired', 'Abgelaufen'),
  trialing('trialing', 'Testphase'),
  pastDue('past_due', 'Zahlung faellig');

  const SubscriptionStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static SubscriptionStatus fromValue(String value) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubscriptionStatus.active,
    );
  }
}

/// Hardcoded Plans for display (can be overridden by API)
class PlanData {
  static const free = Plan(
    id: 'free',
    type: PlanType.free,
    name: 'Free',
    description: 'Perfekt zum Ausprobieren',
    monthlyPrice: 0,
    yearlyPrice: 0,
    features: [
      PlanFeature(name: 'Kontakte', included: true, limit: '500'),
      PlanFeature(name: 'Subcards', included: false),
      PlanFeature(name: 'Web-Kontakte', included: false),
      PlanFeature(name: 'Analytics', included: false),
      PlanFeature(name: 'Push-Kampagnen', included: false),
      PlanFeature(name: 'Team-Rollen', included: false),
    ],
  );

  static const basic = Plan(
    id: 'basic',
    type: PlanType.basic,
    name: 'Basic',
    description: 'Fuer Einzelpersonen & kleine Teams',
    monthlyPrice: 9.99,
    yearlyPrice: 99.99,
    digistore24ProductId: 'zcantag-basic',
    features: [
      PlanFeature(name: 'Kontakte', included: true, limit: '750'),
      PlanFeature(name: 'Subcards', included: true, limit: '1'),
      PlanFeature(name: 'Web-Kontakte', included: true),
      PlanFeature(name: 'Analytics', included: true, limit: 'Basic'),
      PlanFeature(name: 'Push-Kampagnen', included: false),
      PlanFeature(name: 'Team-Rollen', included: true, limit: '2 Rollen'),
    ],
  );

  static const premium = Plan(
    id: 'premium',
    type: PlanType.premium,
    name: 'Premium',
    description: 'Fuer wachsende Unternehmen',
    monthlyPrice: 29.99,
    yearlyPrice: 299.99,
    digistore24ProductId: 'zcantag-premium',
    isPopular: true,
    features: [
      PlanFeature(name: 'Kontakte', included: true, limit: 'Unbegrenzt'),
      PlanFeature(name: 'Subcards', included: true, limit: '5'),
      PlanFeature(name: 'Web-Kontakte', included: true),
      PlanFeature(name: 'Analytics', included: true, limit: 'Premium'),
      PlanFeature(name: 'Push-Kampagnen', included: true, limit: '2/Woche'),
      PlanFeature(name: 'Team-Rollen', included: true, limit: '4 Rollen'),
    ],
  );

  static const enterprise = Plan(
    id: 'enterprise',
    type: PlanType.enterprise,
    name: 'Enterprise',
    description: 'Fuer grosse Organisationen',
    monthlyPrice: 99.99,
    yearlyPrice: 999.99,
    digistore24ProductId: 'zcantag-enterprise',
    features: [
      PlanFeature(name: 'Kontakte', included: true, limit: 'Unbegrenzt'),
      PlanFeature(name: 'Subcards', included: true, limit: '25'),
      PlanFeature(name: 'Web-Kontakte', included: true),
      PlanFeature(name: 'Analytics', included: true, limit: 'Enterprise'),
      PlanFeature(name: 'Push-Kampagnen', included: true, limit: 'Unbegrenzt'),
      PlanFeature(name: 'Team-Rollen', included: true, limit: 'Alle 5 Rollen'),
      PlanFeature(name: 'A/B-Tests', included: true),
      PlanFeature(name: 'Echtzeit-Dashboard', included: true),
    ],
  );

  static List<Plan> get all => [free, basic, premium, enterprise];

  static Plan byType(PlanType type) {
    switch (type) {
      case PlanType.free:
        return free;
      case PlanType.basic:
        return basic;
      case PlanType.premium:
        return premium;
      case PlanType.enterprise:
        return enterprise;
    }
  }
}
