// =============================================================================
// ANALYTICS_TEST.DART - Unit Tests fuer Analytics Entities
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:webapp/shared/features/analytics/domain/entities/analytics.dart';

void main() {
  group('CardAnalytics Entity', () {
    late CardAnalytics analytics;

    setUp(() {
      analytics = const CardAnalytics(
        cardId: 'card-123',
        totalViews: 1000,
        uniqueViews: 750,
        contactsSaved: 150,
        clicksEmail: 50,
        clicksPhone: 30,
        clicksWebsite: 80,
        clicksSocial: 40,
      );
    });

    test('should create CardAnalytics with required fields', () {
      expect(analytics.cardId, 'card-123');
      expect(analytics.totalViews, 1000);
      expect(analytics.uniqueViews, 750);
      expect(analytics.contactsSaved, 150);
      expect(analytics.clicksEmail, 50);
      expect(analytics.clicksPhone, 30);
      expect(analytics.clicksWebsite, 80);
      expect(analytics.clicksSocial, 40);
    });

    test('conversionRate calculates correctly', () {
      // contactsSaved / uniqueViews = 150 / 750 = 0.2
      expect(analytics.conversionRate, 0.2);
    });

    test('conversionRate returns 0 when uniqueViews is 0', () {
      const zeroViews = CardAnalytics(
        cardId: 'card',
        totalViews: 0,
        uniqueViews: 0,
        contactsSaved: 0,
        clicksEmail: 0,
        clicksPhone: 0,
        clicksWebsite: 0,
        clicksSocial: 0,
      );
      expect(zeroViews.conversionRate, 0.0);
    });

    test('clickThroughRate calculates correctly', () {
      // totalClicks / uniqueViews = 200 / 750
      expect(analytics.clickThroughRate, closeTo(0.267, 0.001));
    });

    test('clickThroughRate returns 0 when uniqueViews is 0', () {
      const zeroViews = CardAnalytics(
        cardId: 'card',
        totalViews: 0,
        uniqueViews: 0,
        contactsSaved: 0,
        clicksEmail: 10,
        clicksPhone: 10,
        clicksWebsite: 10,
        clicksSocial: 10,
      );
      expect(zeroViews.clickThroughRate, 0.0);
    });

    test('totalClicks sums all click types', () {
      // 50 + 30 + 80 + 40 = 200
      expect(analytics.totalClicks, 200);
    });
  });

  group('CompanyAnalytics Entity', () {
    test('should create CompanyAnalytics with all fields', () {
      final companyAnalytics = CompanyAnalytics(
        companyId: 'comp-123',
        totalCards: 50,
        activeCards: 45,
        totalViews: 10000,
        totalContacts: 500,
        totalClicks: 2000,
        avgConversionRate: 0.05,
        topCards: const [
          TopCard(
            cardId: 'card-1',
            cardName: 'Top Card',
            views: 1000,
            contacts: 50,
          ),
        ],
      );

      expect(companyAnalytics.companyId, 'comp-123');
      expect(companyAnalytics.totalCards, 50);
      expect(companyAnalytics.activeCards, 45);
      expect(companyAnalytics.totalViews, 10000);
      expect(companyAnalytics.totalContacts, 500);
      expect(companyAnalytics.totalClicks, 2000);
      expect(companyAnalytics.avgConversionRate, 0.05);
      expect(companyAnalytics.topCards.length, 1);
    });

    test('activeCardPercentage calculates correctly', () {
      final analytics = CompanyAnalytics(
        companyId: 'comp',
        totalCards: 100,
        activeCards: 80,
        totalViews: 1000,
        totalContacts: 100,
        totalClicks: 500,
        avgConversionRate: 0.1,
        topCards: const [],
      );
      expect(analytics.activeCardPercentage, 0.8);
    });

    test('activeCardPercentage returns 0 when no cards', () {
      final analytics = CompanyAnalytics(
        companyId: 'comp',
        totalCards: 0,
        activeCards: 0,
        totalViews: 0,
        totalContacts: 0,
        totalClicks: 0,
        avgConversionRate: 0,
        topCards: const [],
      );
      expect(analytics.activeCardPercentage, 0.0);
    });
  });

  group('ConversionFunnel Entity', () {
    late ConversionFunnel funnel;

    setUp(() {
      funnel = const ConversionFunnel(
        totalViews: 10000,
        profileViews: 5000,
        contactClicks: 1000,
        contactsSaved: 500,
        followUps: 100,
      );
    });

    test('should create ConversionFunnel correctly', () {
      expect(funnel.totalViews, 10000);
      expect(funnel.profileViews, 5000);
      expect(funnel.contactClicks, 1000);
      expect(funnel.contactsSaved, 500);
      expect(funnel.followUps, 100);
    });

    test('viewToProfileRate calculates correctly', () {
      expect(funnel.viewToProfileRate, 0.5);
    });

    test('profileToClickRate calculates correctly', () {
      expect(funnel.profileToClickRate, 0.2);
    });

    test('clickToSaveRate calculates correctly', () {
      expect(funnel.clickToSaveRate, 0.5);
    });

    test('saveToFollowUpRate calculates correctly', () {
      expect(funnel.saveToFollowUpRate, 0.2);
    });

    test('overallConversionRate calculates correctly', () {
      expect(funnel.overallConversionRate, 0.05);
    });

    test('all rates return 0 when denominator is 0', () {
      const emptyFunnel = ConversionFunnel(
        totalViews: 0,
        profileViews: 0,
        contactClicks: 0,
        contactsSaved: 0,
        followUps: 0,
      );
      expect(emptyFunnel.viewToProfileRate, 0);
      expect(emptyFunnel.profileToClickRate, 0);
      expect(emptyFunnel.clickToSaveRate, 0);
      expect(emptyFunnel.saveToFollowUpRate, 0);
      expect(emptyFunnel.overallConversionRate, 0);
    });
  });

  group('DateValue Entity', () {
    test('should create DateValue correctly', () {
      final data = DateValue(
        date: DateTime(2024, 6, 15),
        value: 42,
      );

      expect(data.date, DateTime(2024, 6, 15));
      expect(data.value, 42);
    });
  });

  group('LocationValue Entity', () {
    test('should create LocationValue with all fields', () {
      const location = LocationValue(
        country: 'DE',
        city: 'Berlin',
        count: 500,
      );

      expect(location.country, 'DE');
      expect(location.city, 'Berlin');
      expect(location.count, 500);
    });

    test('should create LocationValue without city', () {
      const location = LocationValue(
        country: 'US',
        count: 250,
      );

      expect(location.country, 'US');
      expect(location.city, isNull);
      expect(location.count, 250);
    });
  });

  group('DeviceBreakdown Entity', () {
    late DeviceBreakdown breakdown;

    setUp(() {
      breakdown = const DeviceBreakdown(
        mobile: 600,
        desktop: 300,
        tablet: 100,
      );
    });

    test('should create DeviceBreakdown correctly', () {
      expect(breakdown.mobile, 600);
      expect(breakdown.desktop, 300);
      expect(breakdown.tablet, 100);
    });

    test('total calculates correctly', () {
      expect(breakdown.total, 1000);
    });

    test('mobilePercent calculates correctly', () {
      expect(breakdown.mobilePercent, 0.6);
    });

    test('desktopPercent calculates correctly', () {
      expect(breakdown.desktopPercent, 0.3);
    });

    test('tabletPercent calculates correctly', () {
      expect(breakdown.tabletPercent, 0.1);
    });

    test('percentages return 0 when total is 0', () {
      const empty = DeviceBreakdown(
        mobile: 0,
        desktop: 0,
        tablet: 0,
      );
      expect(empty.mobilePercent, 0);
      expect(empty.desktopPercent, 0);
      expect(empty.tabletPercent, 0);
    });
  });

  group('TopCard Entity', () {
    test('should create TopCard correctly', () {
      const topCard = TopCard(
        cardId: 'card-123',
        cardName: 'Best Card',
        views: 5000,
        contacts: 250,
        thumbnailUrl: 'https://example.com/thumb.jpg',
      );

      expect(topCard.cardId, 'card-123');
      expect(topCard.cardName, 'Best Card');
      expect(topCard.views, 5000);
      expect(topCard.contacts, 250);
      expect(topCard.thumbnailUrl, 'https://example.com/thumb.jpg');
    });

    test('conversionRate calculates correctly', () {
      const topCard = TopCard(
        cardId: 'card',
        cardName: 'Card',
        views: 1000,
        contacts: 100,
      );
      expect(topCard.conversionRate, 0.1);
    });

    test('conversionRate returns 0 when no views', () {
      const topCard = TopCard(
        cardId: 'card',
        cardName: 'Card',
        views: 0,
        contacts: 0,
      );
      expect(topCard.conversionRate, 0);
    });
  });

  group('RealTimeDataPoint Entity', () {
    test('should create RealTimeDataPoint correctly', () {
      final dataPoint = RealTimeDataPoint(
        timestamp: DateTime(2024, 6, 15, 14, 30),
        activeUsers: 150,
        pageViews: 500,
        events: const {
          'click': 100,
          'view': 400,
        },
      );

      expect(dataPoint.timestamp, DateTime(2024, 6, 15, 14, 30));
      expect(dataPoint.activeUsers, 150);
      expect(dataPoint.pageViews, 500);
      expect(dataPoint.events['click'], 100);
      expect(dataPoint.events['view'], 400);
    });
  });

  group('ExportFormat Enum', () {
    test('has correct values', () {
      expect(ExportFormat.values.length, 3);
      expect(ExportFormat.values, contains(ExportFormat.csv));
      expect(ExportFormat.values, contains(ExportFormat.xlsx));
      expect(ExportFormat.values, contains(ExportFormat.pdf));
    });

    test('has correct value strings', () {
      expect(ExportFormat.csv.value, 'csv');
      expect(ExportFormat.xlsx.value, 'xlsx');
      expect(ExportFormat.pdf.value, 'pdf');
    });

    test('has correct display names', () {
      expect(ExportFormat.csv.displayName, 'CSV');
      expect(ExportFormat.xlsx.displayName, 'Excel');
      expect(ExportFormat.pdf.displayName, 'PDF');
    });
  });

  group('AnalyticsExportRequest Entity', () {
    test('should create AnalyticsExportRequest correctly', () {
      final request = AnalyticsExportRequest(
        format: ExportFormat.csv,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 6, 30),
        cardIds: const ['card-1', 'card-2'],
        includeDetails: true,
      );

      expect(request.format, ExportFormat.csv);
      expect(request.startDate, DateTime(2024, 1, 1));
      expect(request.endDate, DateTime(2024, 6, 30));
      expect(request.cardIds, ['card-1', 'card-2']);
      expect(request.includeDetails, true);
    });

    test('should create with defaults', () {
      final request = AnalyticsExportRequest(
        format: ExportFormat.pdf,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      );

      expect(request.cardIds, isNull);
      expect(request.includeDetails, false);
    });
  });
}
