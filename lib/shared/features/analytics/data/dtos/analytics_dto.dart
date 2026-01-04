// =============================================================================
// ANALYTICS_DTO.DART
// =============================================================================
// DTOs fuer Analytics API Operationen
// =============================================================================

import '../../domain/entities/analytics.dart';

/// Card Analytics DTO
class CardAnalyticsDto {
  const CardAnalyticsDto({
    required this.cardId,
    required this.totalViews,
    required this.uniqueViews,
    required this.contactsSaved,
    required this.clicksEmail,
    required this.clicksPhone,
    required this.clicksWebsite,
    required this.clicksSocial,
    this.viewsByDate,
    this.viewsByLocation,
    this.viewsByDevice,
  });

  final String cardId;
  final int totalViews;
  final int uniqueViews;
  final int contactsSaved;
  final int clicksEmail;
  final int clicksPhone;
  final int clicksWebsite;
  final int clicksSocial;
  final List<DateValueDto>? viewsByDate;
  final List<LocationValueDto>? viewsByLocation;
  final DeviceBreakdownDto? viewsByDevice;

  factory CardAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return CardAnalyticsDto(
      cardId: json['card_id'] as String,
      totalViews: json['total_views'] as int? ?? 0,
      uniqueViews: json['unique_views'] as int? ?? 0,
      contactsSaved: json['contacts_saved'] as int? ?? 0,
      clicksEmail: json['clicks_email'] as int? ?? 0,
      clicksPhone: json['clicks_phone'] as int? ?? 0,
      clicksWebsite: json['clicks_website'] as int? ?? 0,
      clicksSocial: json['clicks_social'] as int? ?? 0,
      viewsByDate: (json['views_by_date'] as List<dynamic>?)
          ?.map((e) => DateValueDto.fromJson(e))
          .toList(),
      viewsByLocation: (json['views_by_location'] as List<dynamic>?)
          ?.map((e) => LocationValueDto.fromJson(e))
          .toList(),
      viewsByDevice: json['views_by_device'] != null
          ? DeviceBreakdownDto.fromJson(json['views_by_device'])
          : null,
    );
  }

  CardAnalytics toDomain() {
    return CardAnalytics(
      cardId: cardId,
      totalViews: totalViews,
      uniqueViews: uniqueViews,
      contactsSaved: contactsSaved,
      clicksEmail: clicksEmail,
      clicksPhone: clicksPhone,
      clicksWebsite: clicksWebsite,
      clicksSocial: clicksSocial,
      viewsByDate: viewsByDate?.map((e) => e.toDomain()).toList(),
      viewsByLocation: viewsByLocation?.map((e) => e.toDomain()).toList(),
      viewsByDevice: viewsByDevice?.toDomain(),
    );
  }
}

/// Company Analytics DTO
class CompanyAnalyticsDto {
  const CompanyAnalyticsDto({
    required this.companyId,
    required this.totalCards,
    required this.activeCards,
    required this.totalViews,
    required this.totalContacts,
    required this.totalClicks,
    required this.avgConversionRate,
    required this.topCards,
    this.viewsTrend,
    this.contactsTrend,
  });

  final String companyId;
  final int totalCards;
  final int activeCards;
  final int totalViews;
  final int totalContacts;
  final int totalClicks;
  final double avgConversionRate;
  final List<TopCardDto> topCards;
  final List<DateValueDto>? viewsTrend;
  final List<DateValueDto>? contactsTrend;

  factory CompanyAnalyticsDto.fromJson(Map<String, dynamic> json) {
    return CompanyAnalyticsDto(
      companyId: json['company_id'] as String,
      totalCards: json['total_cards'] as int? ?? 0,
      activeCards: json['active_cards'] as int? ?? 0,
      totalViews: json['total_views'] as int? ?? 0,
      totalContacts: json['total_contacts'] as int? ?? 0,
      totalClicks: json['total_clicks'] as int? ?? 0,
      avgConversionRate: (json['avg_conversion_rate'] as num?)?.toDouble() ?? 0,
      topCards: (json['top_cards'] as List<dynamic>?)
              ?.map((e) => TopCardDto.fromJson(e))
              .toList() ??
          [],
      viewsTrend: (json['views_trend'] as List<dynamic>?)
          ?.map((e) => DateValueDto.fromJson(e))
          .toList(),
      contactsTrend: (json['contacts_trend'] as List<dynamic>?)
          ?.map((e) => DateValueDto.fromJson(e))
          .toList(),
    );
  }

  CompanyAnalytics toDomain() {
    return CompanyAnalytics(
      companyId: companyId,
      totalCards: totalCards,
      activeCards: activeCards,
      totalViews: totalViews,
      totalContacts: totalContacts,
      totalClicks: totalClicks,
      avgConversionRate: avgConversionRate,
      topCards: topCards.map((e) => e.toDomain()).toList(),
      viewsTrend: viewsTrend?.map((e) => e.toDomain()).toList(),
      contactsTrend: contactsTrend?.map((e) => e.toDomain()).toList(),
    );
  }
}

/// Conversion Funnel DTO
class ConversionFunnelDto {
  const ConversionFunnelDto({
    required this.totalViews,
    required this.profileViews,
    required this.contactClicks,
    required this.contactsSaved,
    required this.followUps,
  });

  final int totalViews;
  final int profileViews;
  final int contactClicks;
  final int contactsSaved;
  final int followUps;

  factory ConversionFunnelDto.fromJson(Map<String, dynamic> json) {
    return ConversionFunnelDto(
      totalViews: json['total_views'] as int? ?? 0,
      profileViews: json['profile_views'] as int? ?? 0,
      contactClicks: json['contact_clicks'] as int? ?? 0,
      contactsSaved: json['contacts_saved'] as int? ?? 0,
      followUps: json['follow_ups'] as int? ?? 0,
    );
  }

  ConversionFunnel toDomain() {
    return ConversionFunnel(
      totalViews: totalViews,
      profileViews: profileViews,
      contactClicks: contactClicks,
      contactsSaved: contactsSaved,
      followUps: followUps,
    );
  }
}

/// Date-Value DTO
class DateValueDto {
  const DateValueDto({required this.date, required this.value});
  final String date;
  final int value;

  factory DateValueDto.fromJson(Map<String, dynamic> json) {
    return DateValueDto(
      date: json['date'] as String,
      value: json['value'] as int? ?? 0,
    );
  }

  DateValue toDomain() {
    return DateValue(
      date: DateTime.parse(date),
      value: value,
    );
  }
}

/// Location-Value DTO
class LocationValueDto {
  const LocationValueDto({
    required this.country,
    this.city,
    required this.count,
  });
  final String country;
  final String? city;
  final int count;

  factory LocationValueDto.fromJson(Map<String, dynamic> json) {
    return LocationValueDto(
      country: json['country'] as String,
      city: json['city'] as String?,
      count: json['count'] as int? ?? 0,
    );
  }

  LocationValue toDomain() {
    return LocationValue(
      country: country,
      city: city,
      count: count,
    );
  }
}

/// Device Breakdown DTO
class DeviceBreakdownDto {
  const DeviceBreakdownDto({
    required this.mobile,
    required this.desktop,
    required this.tablet,
  });
  final int mobile;
  final int desktop;
  final int tablet;

  factory DeviceBreakdownDto.fromJson(Map<String, dynamic> json) {
    return DeviceBreakdownDto(
      mobile: json['mobile'] as int? ?? 0,
      desktop: json['desktop'] as int? ?? 0,
      tablet: json['tablet'] as int? ?? 0,
    );
  }

  DeviceBreakdown toDomain() {
    return DeviceBreakdown(
      mobile: mobile,
      desktop: desktop,
      tablet: tablet,
    );
  }
}

/// Top Card DTO
class TopCardDto {
  const TopCardDto({
    required this.cardId,
    required this.cardName,
    required this.views,
    required this.contacts,
    this.thumbnailUrl,
  });
  final String cardId;
  final String cardName;
  final int views;
  final int contacts;
  final String? thumbnailUrl;

  factory TopCardDto.fromJson(Map<String, dynamic> json) {
    return TopCardDto(
      cardId: json['card_id'] as String,
      cardName: json['card_name'] as String,
      views: json['views'] as int? ?? 0,
      contacts: json['contacts'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  TopCard toDomain() {
    return TopCard(
      cardId: cardId,
      cardName: cardName,
      views: views,
      contacts: contacts,
      thumbnailUrl: thumbnailUrl,
    );
  }
}

/// Export Request DTO
class ExportRequestDto {
  const ExportRequestDto({
    required this.format,
    required this.startDate,
    required this.endDate,
    this.cardIds,
    this.includeDetails = false,
  });

  final String format;
  final String startDate;
  final String endDate;
  final List<String>? cardIds;
  final bool includeDetails;

  Map<String, dynamic> toJson() {
    return {
      'format': format,
      'start_date': startDate,
      'end_date': endDate,
      if (cardIds != null) 'card_ids': cardIds,
      'include_details': includeDetails,
    };
  }
}
