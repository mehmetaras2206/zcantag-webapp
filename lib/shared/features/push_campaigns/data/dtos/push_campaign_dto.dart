// =============================================================================
// PUSH_CAMPAIGN_DTO.DART
// =============================================================================
// DTOs fuer Push Campaign API Operationen
// =============================================================================

import '../../domain/entities/push_campaign.dart';

/// Push Campaign DTO
class PushCampaignDto {
  const PushCampaignDto({
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
  final String status;
  final TargetAudienceDto targetAudience;
  final String? scheduledAt;
  final String? sentAt;
  final List<ABTestVariantDto>? abTestVariants;
  final String createdAt;
  final String? updatedAt;

  factory PushCampaignDto.fromJson(Map<String, dynamic> json) {
    return PushCampaignDto(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      actionUrl: json['action_url'] as String?,
      status: json['status'] as String,
      targetAudience: TargetAudienceDto.fromJson(
          json['target_audience'] as Map<String, dynamic>),
      scheduledAt: json['scheduled_at'] as String?,
      sentAt: json['sent_at'] as String?,
      abTestVariants: (json['ab_test_variants'] as List<dynamic>?)
          ?.map((e) => ABTestVariantDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  PushCampaign toDomain() {
    return PushCampaign(
      id: id,
      companyId: companyId,
      title: title,
      body: body,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      status: CampaignStatus.fromValue(status),
      targetAudience: targetAudience.toDomain(),
      scheduledAt: scheduledAt != null ? DateTime.parse(scheduledAt!) : null,
      sentAt: sentAt != null ? DateTime.parse(sentAt!) : null,
      abTestVariants: abTestVariants?.map((e) => e.toDomain()).toList(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

/// Target Audience DTO
class TargetAudienceDto {
  const TargetAudienceDto({
    required this.type,
    this.segmentId,
    this.tags,
    this.cardIds,
    this.estimatedCount,
  });

  final String type;
  final String? segmentId;
  final List<String>? tags;
  final List<String>? cardIds;
  final int? estimatedCount;

  factory TargetAudienceDto.fromJson(Map<String, dynamic> json) {
    return TargetAudienceDto(
      type: json['type'] as String,
      segmentId: json['segment_id'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      cardIds: (json['card_ids'] as List<dynamic>?)?.cast<String>(),
      estimatedCount: json['estimated_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (segmentId != null) 'segment_id': segmentId,
      if (tags != null) 'tags': tags,
      if (cardIds != null) 'card_ids': cardIds,
    };
  }

  TargetAudience toDomain() {
    return TargetAudience(
      type: TargetType.fromValue(type),
      segmentId: segmentId,
      tags: tags,
      cardIds: cardIds,
      estimatedCount: estimatedCount,
    );
  }

  static TargetAudienceDto fromDomain(TargetAudience domain) {
    return TargetAudienceDto(
      type: domain.type.value,
      segmentId: domain.segmentId,
      tags: domain.tags,
      cardIds: domain.cardIds,
      estimatedCount: domain.estimatedCount,
    );
  }
}

/// A/B Test Variant DTO
class ABTestVariantDto {
  const ABTestVariantDto({
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
  final VariantAnalyticsDto? analytics;

  factory ABTestVariantDto.fromJson(Map<String, dynamic> json) {
    return ABTestVariantDto(
      variantId: json['variant_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      percentage: json['percentage'] as int,
      analytics: json['analytics'] != null
          ? VariantAnalyticsDto.fromJson(json['analytics'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'title': title,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      'percentage': percentage,
    };
  }

  ABTestVariant toDomain() {
    return ABTestVariant(
      variantId: variantId,
      title: title,
      body: body,
      imageUrl: imageUrl,
      percentage: percentage,
      analytics: analytics?.toDomain(),
    );
  }

  static ABTestVariantDto fromDomain(ABTestVariant domain) {
    return ABTestVariantDto(
      variantId: domain.variantId,
      title: domain.title,
      body: domain.body,
      imageUrl: domain.imageUrl,
      percentage: domain.percentage,
    );
  }
}

/// Variant Analytics DTO
class VariantAnalyticsDto {
  const VariantAnalyticsDto({
    required this.sent,
    required this.delivered,
    required this.opened,
    required this.clicked,
  });

  final int sent;
  final int delivered;
  final int opened;
  final int clicked;

  factory VariantAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return VariantAnalyticsDto(
      sent: json['sent'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
      opened: json['opened'] as int? ?? 0,
      clicked: json['clicked'] as int? ?? 0,
    );
  }

  VariantAnalytics toDomain() {
    return VariantAnalytics(
      sent: sent,
      delivered: delivered,
      opened: opened,
      clicked: clicked,
    );
  }
}

/// Campaign Analytics DTO
class CampaignAnalyticsDto {
  const CampaignAnalyticsDto({
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
  final List<HourlyDataDto>? opensByHour;
  final Map<String, int>? clicksByLink;
  final List<VariantAnalyticsDto>? variantAnalytics;

  factory CampaignAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return CampaignAnalyticsDto(
      campaignId: json['campaign_id'] as String,
      totalSent: json['total_sent'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
      opened: json['opened'] as int? ?? 0,
      clicked: json['clicked'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
      opensByHour: (json['opens_by_hour'] as List<dynamic>?)
          ?.map((e) => HourlyDataDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      clicksByLink: (json['clicks_by_link'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)),
      variantAnalytics: (json['variant_analytics'] as List<dynamic>?)
          ?.map((e) => VariantAnalyticsDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CampaignAnalytics toDomain() {
    return CampaignAnalytics(
      campaignId: campaignId,
      totalSent: totalSent,
      delivered: delivered,
      opened: opened,
      clicked: clicked,
      failed: failed,
      opensByHour: opensByHour?.map((e) => e.toDomain()).toList(),
      clicksByLink: clicksByLink,
      variantAnalytics: variantAnalytics?.map((e) => e.toDomain()).toList(),
    );
  }
}

/// Hourly Data DTO
class HourlyDataDto {
  const HourlyDataDto({required this.hour, required this.count});
  final int hour;
  final int count;

  factory HourlyDataDto.fromJson(Map<String, dynamic> json) {
    return HourlyDataDto(
      hour: json['hour'] as int,
      count: json['count'] as int? ?? 0,
    );
  }

  HourlyData toDomain() {
    return HourlyData(hour: hour, count: count);
  }
}

/// Weekly Usage DTO
class WeeklyUsageDto {
  const WeeklyUsageDto({
    required this.companyId,
    required this.campaignsSent,
    required this.campaignsLimit,
    required this.periodStart,
    required this.periodEnd,
  });

  final String companyId;
  final int campaignsSent;
  final int campaignsLimit;
  final String periodStart;
  final String periodEnd;

  factory WeeklyUsageDto.fromJson(Map<String, dynamic> json) {
    return WeeklyUsageDto(
      companyId: json['company_id'] as String,
      campaignsSent: json['campaigns_sent'] as int? ?? 0,
      campaignsLimit: json['campaigns_limit'] as int? ?? 0,
      periodStart: json['period_start'] as String,
      periodEnd: json['period_end'] as String,
    );
  }

  WeeklyUsage toDomain() {
    return WeeklyUsage(
      companyId: companyId,
      campaignsSent: campaignsSent,
      campaignsLimit: campaignsLimit,
      periodStart: DateTime.parse(periodStart),
      periodEnd: DateTime.parse(periodEnd),
    );
  }
}

/// Create Campaign Request DTO
class CreateCampaignDto {
  const CreateCampaignDto({
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
  final TargetAudienceDto targetAudience;
  final String? scheduledAt;
  final List<ABTestVariantDto>? abTestVariants;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      if (actionUrl != null) 'action_url': actionUrl,
      'target_audience': targetAudience.toJson(),
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (abTestVariants != null)
        'ab_test_variants': abTestVariants!.map((e) => e.toJson()).toList(),
    };
  }

  static CreateCampaignDto fromDomain(CreateCampaignRequest request) {
    return CreateCampaignDto(
      title: request.title,
      body: request.body,
      imageUrl: request.imageUrl,
      actionUrl: request.actionUrl,
      targetAudience: TargetAudienceDto.fromDomain(request.targetAudience),
      scheduledAt: request.scheduledAt?.toIso8601String(),
      abTestVariants: request.abTestVariants
          ?.map((e) => ABTestVariantDto.fromDomain(e))
          .toList(),
    );
  }
}

/// Update Campaign Request DTO
class UpdateCampaignDto {
  const UpdateCampaignDto({
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
  final TargetAudienceDto? targetAudience;
  final String? scheduledAt;
  final List<ABTestVariantDto>? abTestVariants;

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (imageUrl != null) 'image_url': imageUrl,
      if (actionUrl != null) 'action_url': actionUrl,
      if (targetAudience != null) 'target_audience': targetAudience!.toJson(),
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (abTestVariants != null)
        'ab_test_variants': abTestVariants!.map((e) => e.toJson()).toList(),
    };
  }

  static UpdateCampaignDto fromDomain(UpdateCampaignRequest request) {
    return UpdateCampaignDto(
      title: request.title,
      body: request.body,
      imageUrl: request.imageUrl,
      actionUrl: request.actionUrl,
      targetAudience: request.targetAudience != null
          ? TargetAudienceDto.fromDomain(request.targetAudience!)
          : null,
      scheduledAt: request.scheduledAt?.toIso8601String(),
      abTestVariants: request.abTestVariants
          ?.map((e) => ABTestVariantDto.fromDomain(e))
          .toList(),
    );
  }
}
