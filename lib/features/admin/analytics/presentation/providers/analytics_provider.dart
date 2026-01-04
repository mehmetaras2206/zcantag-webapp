// =============================================================================
// ANALYTICS_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Analytics State Management
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/features/analytics/domain/entities/analytics.dart';
import '../../data/repositories/analytics_repository.dart';

// =============================================================================
// DATE RANGE
// =============================================================================

enum DateRangePreset {
  today('Heute'),
  yesterday('Gestern'),
  last7Days('Letzte 7 Tage'),
  last30Days('Letzte 30 Tage'),
  thisMonth('Dieser Monat'),
  lastMonth('Letzter Monat'),
  thisQuarter('Dieses Quartal'),
  thisYear('Dieses Jahr'),
  custom('Benutzerdefiniert');

  const DateRangePreset(this.displayName);
  final String displayName;

  DateTimeRange get dateRange {
    final now = DateTime.now();
    switch (this) {
      case DateRangePreset.today:
        return DateTimeRange(
          start: DateTime(now.year, now.month, now.day),
          end: now,
        );
      case DateRangePreset.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: DateTime(yesterday.year, yesterday.month, yesterday.day),
          end: DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
        );
      case DateRangePreset.last7Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      case DateRangePreset.last30Days:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case DateRangePreset.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case DateRangePreset.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: lastMonth, end: lastDayOfLastMonth);
      case DateRangePreset.thisQuarter:
        final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1);
        return DateTimeRange(start: quarterStart, end: now);
      case DateRangePreset.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
      case DateRangePreset.custom:
        return DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
    }
  }
}

class DateTimeRange {
  const DateTimeRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

// =============================================================================
// ANALYTICS STATE
// =============================================================================

sealed class AnalyticsState {
  const AnalyticsState();
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded({
    required this.companyAnalytics,
    this.selectedCardAnalytics,
    this.conversionFunnel,
    required this.dateRange,
    required this.preset,
  });

  final CompanyAnalytics companyAnalytics;
  final CardAnalytics? selectedCardAnalytics;
  final ConversionFunnel? conversionFunnel;
  final DateTimeRange dateRange;
  final DateRangePreset preset;
}

class AnalyticsError extends AnalyticsState {
  const AnalyticsError(this.message);
  final String message;
}

// =============================================================================
// ANALYTICS NOTIFIER
// =============================================================================

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsInitial());

  final _repository = AnalyticsRepositoryImpl();

  /// Laedt Company Analytics
  Future<void> loadAnalytics(
    String companyId, {
    DateRangePreset preset = DateRangePreset.last30Days,
    DateTimeRange? customRange,
  }) async {
    state = const AnalyticsLoading();

    final dateRange = preset == DateRangePreset.custom && customRange != null
        ? customRange
        : preset.dateRange;

    final result = await _repository.getCompanyAnalytics(
      companyId,
      startDate: dateRange.start,
      endDate: dateRange.end,
    );

    if (result.isSuccess && result.data != null) {
      state = AnalyticsLoaded(
        companyAnalytics: result.data!,
        dateRange: dateRange,
        preset: preset,
      );
    } else {
      state = AnalyticsError(result.error ?? 'Unbekannter Fehler');
    }
  }

  /// Laedt Card Analytics
  Future<void> loadCardAnalytics(String cardId) async {
    final currentState = state;
    if (currentState is! AnalyticsLoaded) return;

    final result = await _repository.getCardAnalytics(
      cardId,
      startDate: currentState.dateRange.start,
      endDate: currentState.dateRange.end,
    );

    if (result.isSuccess && result.data != null) {
      state = AnalyticsLoaded(
        companyAnalytics: currentState.companyAnalytics,
        selectedCardAnalytics: result.data,
        conversionFunnel: currentState.conversionFunnel,
        dateRange: currentState.dateRange,
        preset: currentState.preset,
      );
    }
  }

  /// Laedt Conversion Funnel (Enterprise)
  Future<void> loadConversionFunnel(String companyId) async {
    final currentState = state;
    if (currentState is! AnalyticsLoaded) return;

    final result = await _repository.getConversionFunnel(
      companyId,
      startDate: currentState.dateRange.start,
      endDate: currentState.dateRange.end,
    );

    if (result.isSuccess && result.data != null) {
      state = AnalyticsLoaded(
        companyAnalytics: currentState.companyAnalytics,
        selectedCardAnalytics: currentState.selectedCardAnalytics,
        conversionFunnel: result.data,
        dateRange: currentState.dateRange,
        preset: currentState.preset,
      );
    }
  }

  /// Aendert Zeitraum
  Future<void> changeDateRange(
    String companyId,
    DateRangePreset preset, {
    DateTimeRange? customRange,
  }) async {
    await loadAnalytics(companyId, preset: preset, customRange: customRange);
  }

  /// Exportiert Analytics
  Future<String?> exportAnalytics(
    String companyId,
    ExportFormat format, {
    List<String>? cardIds,
    bool includeDetails = false,
  }) async {
    final currentState = state;
    if (currentState is! AnalyticsLoaded) return null;

    final request = AnalyticsExportRequest(
      format: format,
      startDate: currentState.dateRange.start,
      endDate: currentState.dateRange.end,
      cardIds: cardIds,
      includeDetails: includeDetails,
    );

    final result = await _repository.exportAnalytics(companyId, request);

    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

final dateRangePresetProvider = StateProvider<DateRangePreset>((ref) {
  return DateRangePreset.last30Days;
});
