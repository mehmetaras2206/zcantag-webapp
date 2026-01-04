// =============================================================================
// ANALYTICS.DART
// =============================================================================
// Analytics Domain Entities
// =============================================================================

/// Card Analytics
class CardAnalytics {
  const CardAnalytics({
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
  final List<DateValue>? viewsByDate;
  final List<LocationValue>? viewsByLocation;
  final DeviceBreakdown? viewsByDevice;

  /// Konversionsrate (Kontakte / Views)
  double get conversionRate {
    if (uniqueViews == 0) return 0;
    return contactsSaved / uniqueViews;
  }

  /// Gesamte Klicks
  int get totalClicks => clicksEmail + clicksPhone + clicksWebsite + clicksSocial;

  /// Click-Through-Rate
  double get clickThroughRate {
    if (uniqueViews == 0) return 0;
    return totalClicks / uniqueViews;
  }
}

/// Company Analytics
class CompanyAnalytics {
  const CompanyAnalytics({
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
  final List<TopCard> topCards;
  final List<DateValue>? viewsTrend;
  final List<DateValue>? contactsTrend;

  /// Aktive Karten Prozentsatz
  double get activeCardPercentage {
    if (totalCards == 0) return 0;
    return activeCards / totalCards;
  }
}

/// Conversion Funnel (Enterprise)
class ConversionFunnel {
  const ConversionFunnel({
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

  /// Funnel-Raten
  double get viewToProfileRate =>
      totalViews > 0 ? profileViews / totalViews : 0;
  double get profileToClickRate =>
      profileViews > 0 ? contactClicks / profileViews : 0;
  double get clickToSaveRate =>
      contactClicks > 0 ? contactsSaved / contactClicks : 0;
  double get saveToFollowUpRate =>
      contactsSaved > 0 ? followUps / contactsSaved : 0;

  /// Gesamte Conversion
  double get overallConversionRate =>
      totalViews > 0 ? contactsSaved / totalViews : 0;
}

/// Date-Value Pair
class DateValue {
  const DateValue({required this.date, required this.value});
  final DateTime date;
  final int value;
}

/// Location-Value Pair
class LocationValue {
  const LocationValue({
    required this.country,
    this.city,
    required this.count,
  });
  final String country;
  final String? city;
  final int count;
}

/// Device Breakdown
class DeviceBreakdown {
  const DeviceBreakdown({
    required this.mobile,
    required this.desktop,
    required this.tablet,
  });
  final int mobile;
  final int desktop;
  final int tablet;

  int get total => mobile + desktop + tablet;
  double get mobilePercent => total > 0 ? mobile / total : 0;
  double get desktopPercent => total > 0 ? desktop / total : 0;
  double get tabletPercent => total > 0 ? tablet / total : 0;
}

/// Top Card
class TopCard {
  const TopCard({
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

  double get conversionRate => views > 0 ? contacts / views : 0;
}

/// Real-Time Data Point (Enterprise)
class RealTimeDataPoint {
  const RealTimeDataPoint({
    required this.timestamp,
    required this.activeUsers,
    required this.pageViews,
    required this.events,
  });
  final DateTime timestamp;
  final int activeUsers;
  final int pageViews;
  final Map<String, int> events;
}

/// Export Format
enum ExportFormat {
  csv('csv', 'CSV'),
  xlsx('xlsx', 'Excel'),
  pdf('pdf', 'PDF');

  const ExportFormat(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Export Request
class AnalyticsExportRequest {
  const AnalyticsExportRequest({
    required this.format,
    required this.startDate,
    required this.endDate,
    this.cardIds,
    this.includeDetails = false,
  });

  final ExportFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? cardIds;
  final bool includeDetails;
}
