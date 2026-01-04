// =============================================================================
// PUSH_CAMPAIGN_REPOSITORY.DART
// =============================================================================
// Repository fuer Push Campaign API Operationen
// =============================================================================

import '../../../../../shared/core/network/api_client.dart';
import '../../../../../shared/core/config/app_config.dart';
import '../../../../../shared/features/push_campaigns/domain/entities/push_campaign.dart';
import '../../../../../shared/features/push_campaigns/data/dtos/push_campaign_dto.dart';

/// Result Wrapper
class CampaignResult<T> {
  const CampaignResult.success(this.data)
      : error = null,
        isSuccess = true;
  const CampaignResult.failure(this.error)
      : data = null,
        isSuccess = false;

  final T? data;
  final String? error;
  final bool isSuccess;
}

/// Abstract Repository Interface
abstract class PushCampaignRepository {
  /// Holt alle Kampagnen
  Future<CampaignResult<List<PushCampaign>>> getCampaigns();

  /// Holt eine Kampagne
  Future<CampaignResult<PushCampaign>> getCampaign(String campaignId);

  /// Erstellt eine Kampagne
  Future<CampaignResult<PushCampaign>> createCampaign(
      CreateCampaignRequest request);

  /// Aktualisiert eine Kampagne
  Future<CampaignResult<PushCampaign>> updateCampaign(
      String campaignId, UpdateCampaignRequest request);

  /// Loescht eine Kampagne
  Future<CampaignResult<void>> deleteCampaign(String campaignId);

  /// Sendet eine Kampagne
  Future<CampaignResult<void>> sendCampaign(String campaignId);

  /// Bricht eine Kampagne ab
  Future<CampaignResult<void>> cancelCampaign(String campaignId);

  /// Holt Kampagnen-Analytics
  Future<CampaignResult<CampaignAnalytics>> getCampaignAnalytics(
      String campaignId);

  /// Holt woechentliche Nutzung
  Future<CampaignResult<WeeklyUsage>> getWeeklyUsage(String companyId);
}

/// Repository Implementation
class PushCampaignRepositoryImpl implements PushCampaignRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<CampaignResult<List<PushCampaign>>> getCampaigns() async {
    try {
      final response = await _apiClient.get(AppConfig.pushCampaignsAll);

      if (response.isSuccess && response.data != null) {
        final List<dynamic> campaignsList = response.data is List
            ? response.data
            : response.data['campaigns'] as List<dynamic>? ?? [];

        final campaigns = campaignsList
            .map((json) =>
                PushCampaignDto.fromJson(json as Map<String, dynamic>)
                    .toDomain())
            .toList();

        return CampaignResult.success(campaigns);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Kampagnen');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<PushCampaign>> getCampaign(String campaignId) async {
    try {
      final response =
          await _apiClient.get(AppConfig.pushCampaignById(campaignId));

      if (response.isSuccess && response.data != null) {
        final campaign = PushCampaignDto.fromJson(response.data).toDomain();
        return CampaignResult.success(campaign);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Kampagne');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<PushCampaign>> createCampaign(
      CreateCampaignRequest request) async {
    try {
      final dto = CreateCampaignDto.fromDomain(request);
      final response = await _apiClient.post(
        AppConfig.pushCampaignsCreate,
        body: dto.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final campaign = PushCampaignDto.fromJson(response.data).toDomain();
        return CampaignResult.success(campaign);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Erstellen der Kampagne');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<PushCampaign>> updateCampaign(
      String campaignId, UpdateCampaignRequest request) async {
    try {
      final dto = UpdateCampaignDto.fromDomain(request);
      final response = await _apiClient.put(
        AppConfig.pushCampaignById(campaignId),
        body: dto.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final campaign = PushCampaignDto.fromJson(response.data).toDomain();
        return CampaignResult.success(campaign);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Aktualisieren der Kampagne');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<void>> deleteCampaign(String campaignId) async {
    try {
      final response =
          await _apiClient.delete(AppConfig.pushCampaignById(campaignId));

      if (response.isSuccess) {
        return const CampaignResult.success(null);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Loeschen der Kampagne');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<void>> sendCampaign(String campaignId) async {
    try {
      final response =
          await _apiClient.post(AppConfig.pushCampaignSend(campaignId));

      if (response.isSuccess) {
        return const CampaignResult.success(null);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Senden der Kampagne');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<void>> cancelCampaign(String campaignId) async {
    try {
      final response =
          await _apiClient.post(AppConfig.pushCampaignCancel(campaignId));

      if (response.isSuccess) {
        return const CampaignResult.success(null);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Abbrechen der Kampagne');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<CampaignAnalytics>> getCampaignAnalytics(
      String campaignId) async {
    try {
      final response =
          await _apiClient.get(AppConfig.pushCampaignAnalytics(campaignId));

      if (response.isSuccess && response.data != null) {
        final analytics =
            CampaignAnalyticsDto.fromJson(response.data).toDomain();
        return CampaignResult.success(analytics);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Analytics');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CampaignResult<WeeklyUsage>> getWeeklyUsage(String companyId) async {
    try {
      final response =
          await _apiClient.get(AppConfig.pushCampaignsWeeklyUsage(companyId));

      if (response.isSuccess && response.data != null) {
        final usage = WeeklyUsageDto.fromJson(response.data).toDomain();
        return CampaignResult.success(usage);
      } else {
        return CampaignResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Nutzung');
      }
    } catch (e) {
      return CampaignResult.failure('Netzwerkfehler: $e');
    }
  }
}
