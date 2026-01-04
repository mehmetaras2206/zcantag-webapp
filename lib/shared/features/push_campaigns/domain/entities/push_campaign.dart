// =============================================================================
// PUSH_CAMPAIGN.DART
// =============================================================================
// Push Campaign Domain Entities
// =============================================================================

/// Campaign Status
enum CampaignStatus {
  draft('draft', 'Entwurf'),
  scheduled('scheduled', 'Geplant'),
  sending('sending', 'Wird gesendet'),
  sent('sent', 'Gesendet'),
  cancelled('cancelled', 'Abgebrochen'),
  failed('failed', 'Fehlgeschlagen');

  const CampaignStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static CampaignStatus fromValue(String value) {
    return CampaignStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => CampaignStatus.draft,
    );
  }

  bool get isDraft => this == CampaignStatus.draft;
  bool get isScheduled => this == CampaignStatus.scheduled;
  bool get isSent => this == CampaignStatus.sent;
  bool get canEdit => this == CampaignStatus.draft;
  bool get canSend => this == CampaignStatus.draft || this == CampaignStatus.scheduled;
  bool get canCancel => this == CampaignStatus.scheduled;
}

/// Campaign Target Type
enum TargetType {
  all('all', 'Alle Kontakte'),
  segment('segment', 'Segment'),
  tags('tags', 'Tags'),
  cardContacts('card_contacts', 'Karten-Kontakte');

  const TargetType(this.value, this.displayName);
  final String value;
  final String displayName;

  static TargetType fromValue(String value) {
    return TargetType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TargetType.all,
    );
  }
}

/// Push Campaign
class PushCampaign {
  const PushCampaign({
    required this.id,
    required this.companyId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    required this.status,
    required this.targetAudience,
    this.scheduledAt,
    this.sentAt,
    this.abTestVariants,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final CampaignStatus status;
  final TargetAudience targetAudience;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final List<ABTestVariant>? abTestVariants;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Ist A/B-Test
  bool get isABTest => abTestVariants != null && abTestVariants!.isNotEmpty;

  /// Kann bearbeitet werden
  bool get canEdit => status.canEdit;

  /// Kann gesendet werden
  bool get canSend => status.canSend;

  /// Kann abgebrochen werden
  bool get canCancel => status.canCancel;

  /// Copy with
  PushCampaign copyWith({
    String? id,
    String? companyId,
    String? title,
    String? body,
    String? imageUrl,
    String? actionUrl,
    CampaignStatus? status,
    TargetAudience? targetAudience,
    DateTime? scheduledAt,
    DateTime? sentAt,
    List<ABTestVariant>? abTestVariants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PushCampaign(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      abTestVariants: abTestVariants ?? this.abTestVariants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Target Audience
class TargetAudience {
  const TargetAudience({
    required this.type,
    this.segmentId,
    this.tags,
    this.cardIds,
    this.estimatedCount,
  });

  final TargetType type;
  final String? segmentId;
  final List<String>? tags;
  final List<String>? cardIds;
  final int? estimatedCount;

  /// Beschreibung
  String get description {
    switch (type) {
      case TargetType.all:
        return 'Alle Kontakte';
      case TargetType.segment:
        return 'Segment';
      case TargetType.tags:
        return tags?.join(', ') ?? 'Tags';
      case TargetType.cardContacts:
        return '${cardIds?.length ?? 0} Karten';
    }
  }
}

/// A/B Test Variant (Enterprise)
class ABTestVariant {
  const ABTestVariant({
    required this.variantId,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.percentage,
    this.analytics,
  });

  final String variantId;
  final String title;
  final String body;
  final String? imageUrl;
  final int percentage;
  final VariantAnalytics? analytics;
}

/// Variant Analytics
class VariantAnalytics {
  const VariantAnalytics({
    required this.sent,
    required this.delivered,
    required this.opened,
    required this.clicked,
  });

  final int sent;
  final int delivered;
  final int opened;
  final int clicked;

  double get deliveryRate => sent > 0 ? delivered / sent : 0;
  double get openRate => delivered > 0 ? opened / delivered : 0;
  double get clickRate => opened > 0 ? clicked / opened : 0;
}

/// Campaign Analytics
class CampaignAnalytics {
  const CampaignAnalytics({
    required this.campaignId,
    required this.totalSent,
    required this.delivered,
    required this.opened,
    required this.clicked,
    required this.failed,
    this.opensByHour,
    this.clicksByLink,
    this.variantAnalytics,
  });

  final String campaignId;
  final int totalSent;
  final int delivered;
  final int opened;
  final int clicked;
  final int failed;
  final List<HourlyData>? opensByHour;
  final Map<String, int>? clicksByLink;
  final List<VariantAnalytics>? variantAnalytics;

  /// Zustellrate
  double get deliveryRate => totalSent > 0 ? delivered / totalSent : 0;

  /// Oeffnungsrate
  double get openRate => delivered > 0 ? opened / delivered : 0;

  /// Klickrate
  double get clickRate => opened > 0 ? clicked / opened : 0;

  /// Fehlerrate
  double get failureRate => totalSent > 0 ? failed / totalSent : 0;
}

/// Hourly Data
class HourlyData {
  const HourlyData({required this.hour, required this.count});
  final int hour;
  final int count;
}

/// Weekly Usage
class WeeklyUsage {
  const WeeklyUsage({
    required this.companyId,
    required this.campaignsSent,
    required this.campaignsLimit,
    required this.periodStart,
    required this.periodEnd,
  });

  final String companyId;
  final int campaignsSent;
  final int campaignsLimit;
  final DateTime periodStart;
  final DateTime periodEnd;

  /// Verbleibende Kampagnen
  int get remaining => campaignsLimit > 0 ? campaignsLimit - campaignsSent : 0;

  /// Ist Limit erreicht
  bool get isLimitReached => campaignsLimit > 0 && campaignsSent >= campaignsLimit;

  /// Ist unlimitiert
  bool get isUnlimited => campaignsLimit == -1;

  /// Nutzung in Prozent
  double get usagePercentage {
    if (isUnlimited) return 0;
    if (campaignsLimit == 0) return 1;
    return campaignsSent / campaignsLimit;
  }
}

/// Create Campaign Request
class CreateCampaignRequest {
  const CreateCampaignRequest({
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    required this.targetAudience,
    this.scheduledAt,
    this.abTestVariants,
  });

  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final TargetAudience targetAudience;
  final DateTime? scheduledAt;
  final List<ABTestVariant>? abTestVariants;
}

/// Update Campaign Request
class UpdateCampaignRequest {
  const UpdateCampaignRequest({
    this.title,
    this.body,
    this.imageUrl,
    this.actionUrl,
    this.targetAudience,
    this.scheduledAt,
    this.abTestVariants,
  });

  final String? title;
  final String? body;
  final String? imageUrl;
  final String? actionUrl;
  final TargetAudience? targetAudience;
  final DateTime? scheduledAt;
  final List<ABTestVariant>? abTestVariants;
}
