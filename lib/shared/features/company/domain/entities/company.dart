// =============================================================================
// COMPANY.DART
// =============================================================================
// Company Domain Entity
// =============================================================================

/// Plan-Typen
enum PlanType {
  free('free'),
  basic('basic'),
  premium('premium'),
  enterprise('enterprise');

  const PlanType(this.value);
  final String value;

  static PlanType fromString(String value) {
    return PlanType.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => PlanType.free,
    );
  }

  String get displayName {
    switch (this) {
      case PlanType.free:
        return 'Free';
      case PlanType.basic:
        return 'Basic';
      case PlanType.premium:
        return 'Premium';
      case PlanType.enterprise:
        return 'Enterprise';
    }
  }

  /// Features pro Plan
  int get maxContacts {
    switch (this) {
      case PlanType.free:
        return 500;
      case PlanType.basic:
        return 750;
      case PlanType.premium:
      case PlanType.enterprise:
        return -1; // Unlimited
    }
  }

  int get maxSubcards {
    switch (this) {
      case PlanType.free:
        return 0;
      case PlanType.basic:
        return 1;
      case PlanType.premium:
        return 5;
      case PlanType.enterprise:
        return 25;
    }
  }

  int get pushCampaignsPerWeek {
    switch (this) {
      case PlanType.free:
      case PlanType.basic:
        return 0;
      case PlanType.premium:
        return 2;
      case PlanType.enterprise:
        return -1; // Unlimited
    }
  }

  bool get hasAnalytics {
    return this != PlanType.free;
  }

  bool get hasPremiumAnalytics {
    return this == PlanType.premium || this == PlanType.enterprise;
  }

  bool get hasEnterpriseAnalytics {
    return this == PlanType.enterprise;
  }

  bool get hasWebContacts {
    return this != PlanType.free;
  }

  bool get hasPushCampaigns {
    return this == PlanType.premium || this == PlanType.enterprise;
  }

  bool get hasAbTest {
    return this == PlanType.enterprise;
  }

  /// Verfuegbare Rollen pro Plan
  List<String> get availableRoles {
    switch (this) {
      case PlanType.free:
        return ['mitarbeiter'];
      case PlanType.basic:
        return ['super_admin', 'mitarbeiter'];
      case PlanType.premium:
        return ['super_admin', 'filialleiter', 'teamleiter', 'mitarbeiter'];
      case PlanType.enterprise:
        return [
          'super_admin',
          'regionalleiter',
          'filialleiter',
          'teamleiter',
          'mitarbeiter'
        ];
    }
  }
}

/// Company Domain Entity
class Company {
  const Company({
    required this.id,
    required this.name,
    required this.displayName,
    this.logoUrl,
    this.websiteUrl,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.description,
    this.industry,
    required this.planType,
    this.primaryColor,
    this.secondaryColor,
    this.createdAt,
    this.updatedAt,
    this.memberCount = 0,
    this.cardCount = 0,
  });

  final String id;
  final String name;
  final String displayName;
  final String? logoUrl;
  final String? websiteUrl;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? description;
  final String? industry;
  final PlanType planType;
  final String? primaryColor;
  final String? secondaryColor;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int memberCount;
  final int cardCount;

  /// Hat die Company ein Logo?
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Vollstaendige Adresse
  String? get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (postalCode != null || city != null) {
      parts.add([postalCode, city].whereType<String>().join(' '));
    }
    if (country != null) parts.add(country!);
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Hat die Company eine Adresse?
  bool get hasAddress =>
      address != null || city != null || postalCode != null || country != null;

  /// Copy with
  Company copyWith({
    String? id,
    String? name,
    String? displayName,
    String? logoUrl,
    String? websiteUrl,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? description,
    String? industry,
    PlanType? planType,
    String? primaryColor,
    String? secondaryColor,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
    int? cardCount,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      planType: planType ?? this.planType,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      cardCount: cardCount ?? this.cardCount,
    );
  }
}
