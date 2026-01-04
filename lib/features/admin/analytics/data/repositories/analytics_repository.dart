// =============================================================================
// ANALYTICS_REPOSITORY.DART
// =============================================================================
// Repository fuer Analytics API Operationen
// =============================================================================

import '../../../../../shared/core/network/api_client.dart';
import '../../../../../shared/core/config/app_config.dart';
import '../../../../../shared/features/analytics/domain/entities/analytics.dart';
import '../../../../../shared/features/analytics/data/dtos/analytics_dto.dart';

/// Result Wrapper
class AnalyticsResult<T> {
  const AnalyticsResult.success(this.data)
      : error = null,
        isSuccess = true;
  const AnalyticsResult.failure(this.error)
      : data = null,
        isSuccess = false;

  final T? data;
  final String? error;
  final bool isSuccess;
}

/// Abstract Repository Interface
abstract class AnalyticsRepository {
  /// Holt Analytics fuer eine Karte
  Future<AnalyticsResult<CardAnalytics>> getCardAnalytics(
    String cardId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Holt Analytics fuer eine Company
  Future<AnalyticsResult<CompanyAnalytics>> getCompanyAnalytics(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Holt Conversion Funnel (Enterprise)
  Future<AnalyticsResult<ConversionFunnel>> getConversionFunnel(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Exportiert Analytics
  Future<AnalyticsResult<String>> exportAnalytics(
    String companyId,
    AnalyticsExportRequest request,
  );
}

/// Repository Implementation
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<AnalyticsResult<CardAnalytics>> getCardAnalytics(
    String cardId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var url = AppConfig.analyticsCard(cardId);

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$queryString';
      }

      final response = await _apiClient.get(url);

      if (response.isSuccess && response.data != null) {
        final analytics = CardAnalyticsDto.fromJson(response.data).toDomain();
        return AnalyticsResult.success(analytics);
      } else {
        return AnalyticsResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Analytics');
      }
    } catch (e) {
      return AnalyticsResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<AnalyticsResult<CompanyAnalytics>> getCompanyAnalytics(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var url = AppConfig.analyticsCompany(companyId);

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$queryString';
      }

      final response = await _apiClient.get(url);

      if (response.isSuccess && response.data != null) {
        final analytics =
            CompanyAnalyticsDto.fromJson(response.data).toDomain();
        return AnalyticsResult.success(analytics);
      } else {
        return AnalyticsResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Analytics');
      }
    } catch (e) {
      return AnalyticsResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<AnalyticsResult<ConversionFunnel>> getConversionFunnel(
    String companyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var url = AppConfig.analyticsConversionFunnel(companyId);

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url = '$url?$queryString';
      }

      final response = await _apiClient.get(url);

      if (response.isSuccess && response.data != null) {
        final funnel = ConversionFunnelDto.fromJson(response.data).toDomain();
        return AnalyticsResult.success(funnel);
      } else {
        return AnalyticsResult.failure(
            response.errorMessage ?? 'Fehler beim Laden des Funnels');
      }
    } catch (e) {
      return AnalyticsResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<AnalyticsResult<String>> exportAnalytics(
    String companyId,
    AnalyticsExportRequest request,
  ) async {
    try {
      final dto = ExportRequestDto(
        format: request.format.value,
        startDate: request.startDate.toIso8601String().split('T')[0],
        endDate: request.endDate.toIso8601String().split('T')[0],
        cardIds: request.cardIds,
        includeDetails: request.includeDetails,
      );

      final response = await _apiClient.post(
        AppConfig.analyticsExport(companyId),
        body: dto.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        // Erwarte Download-URL zurueck
        final downloadUrl = response.data['download_url'] as String?;
        if (downloadUrl != null) {
          return AnalyticsResult.success(downloadUrl);
        }
        return AnalyticsResult.failure('Keine Download-URL erhalten');
      } else {
        return AnalyticsResult.failure(
            response.errorMessage ?? 'Fehler beim Export');
      }
    } catch (e) {
      return AnalyticsResult.failure('Netzwerkfehler: $e');
    }
  }
}
