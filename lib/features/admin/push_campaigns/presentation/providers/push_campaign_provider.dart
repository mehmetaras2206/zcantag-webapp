// =============================================================================
// PUSH_CAMPAIGN_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Push Campaign State Management
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/features/push_campaigns/domain/entities/push_campaign.dart';
import '../../data/repositories/push_campaign_repository.dart';

// =============================================================================
// CAMPAIGNS LIST STATE
// =============================================================================

sealed class CampaignsState {
  const CampaignsState();
}

class CampaignsInitial extends CampaignsState {
  const CampaignsInitial();
}

class CampaignsLoading extends CampaignsState {
  const CampaignsLoading();
}

class CampaignsLoaded extends CampaignsState {
  const CampaignsLoaded({
    required this.campaigns,
    this.weeklyUsage,
    this.filterStatus,
  });

  final List<PushCampaign> campaigns;
  final WeeklyUsage? weeklyUsage;
  final CampaignStatus? filterStatus;

  /// Gefilterte Kampagnen
  List<PushCampaign> get filteredCampaigns {
    if (filterStatus == null) return campaigns;
    return campaigns.where((c) => c.status == filterStatus).toList();
  }

  /// Kampagnen nach Status
  List<PushCampaign> get draftCampaigns =>
      campaigns.where((c) => c.status.isDraft).toList();

  List<PushCampaign> get scheduledCampaigns =>
      campaigns.where((c) => c.status.isScheduled).toList();

  List<PushCampaign> get sentCampaigns =>
      campaigns.where((c) => c.status.isSent).toList();

  CampaignsLoaded copyWith({
    List<PushCampaign>? campaigns,
    WeeklyUsage? weeklyUsage,
    CampaignStatus? filterStatus,
    bool clearFilter = false,
  }) {
    return CampaignsLoaded(
      campaigns: campaigns ?? this.campaigns,
      weeklyUsage: weeklyUsage ?? this.weeklyUsage,
      filterStatus: clearFilter ? null : (filterStatus ?? this.filterStatus),
    );
  }
}

class CampaignsError extends CampaignsState {
  const CampaignsError(this.message);
  final String message;
}

// =============================================================================
// CAMPAIGN DETAIL STATE
// =============================================================================

sealed class CampaignDetailState {
  const CampaignDetailState();
}

class CampaignDetailInitial extends CampaignDetailState {
  const CampaignDetailInitial();
}

class CampaignDetailLoading extends CampaignDetailState {
  const CampaignDetailLoading();
}

class CampaignDetailLoaded extends CampaignDetailState {
  const CampaignDetailLoaded({
    required this.campaign,
    this.analytics,
  });

  final PushCampaign campaign;
  final CampaignAnalytics? analytics;

  CampaignDetailLoaded copyWith({
    PushCampaign? campaign,
    CampaignAnalytics? analytics,
  }) {
    return CampaignDetailLoaded(
      campaign: campaign ?? this.campaign,
      analytics: analytics ?? this.analytics,
    );
  }
}

class CampaignDetailError extends CampaignDetailState {
  const CampaignDetailError(this.message);
  final String message;
}

// =============================================================================
// CAMPAIGNS NOTIFIER
// =============================================================================

class CampaignsNotifier extends StateNotifier<CampaignsState> {
  CampaignsNotifier() : super(const CampaignsInitial());

  final _repository = PushCampaignRepositoryImpl();

  /// Laedt alle Kampagnen
  Future<void> loadCampaigns({String? companyId}) async {
    state = const CampaignsLoading();

    final result = await _repository.getCampaigns();

    if (result.isSuccess && result.data != null) {
      WeeklyUsage? usage;
      if (companyId != null) {
        final usageResult = await _repository.getWeeklyUsage(companyId);
        if (usageResult.isSuccess) {
          usage = usageResult.data;
        }
      }

      state = CampaignsLoaded(
        campaigns: result.data!,
        weeklyUsage: usage,
      );
    } else {
      state = CampaignsError(result.error ?? 'Unbekannter Fehler');
    }
  }

  /// Filtert nach Status
  void filterByStatus(CampaignStatus? status) {
    final currentState = state;
    if (currentState is! CampaignsLoaded) return;

    state = currentState.copyWith(
      filterStatus: status,
      clearFilter: status == null,
    );
  }

  /// Erstellt eine Kampagne
  Future<PushCampaign?> createCampaign(CreateCampaignRequest request) async {
    final result = await _repository.createCampaign(request);

    if (result.isSuccess && result.data != null) {
      // Reload campaigns
      final currentState = state;
      if (currentState is CampaignsLoaded) {
        state = currentState.copyWith(
          campaigns: [result.data!, ...currentState.campaigns],
        );
      }
      return result.data;
    }
    return null;
  }

  /// Loescht eine Kampagne
  Future<bool> deleteCampaign(String campaignId) async {
    final result = await _repository.deleteCampaign(campaignId);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is CampaignsLoaded) {
        state = currentState.copyWith(
          campaigns:
              currentState.campaigns.where((c) => c.id != campaignId).toList(),
        );
      }
      return true;
    }
    return false;
  }

  /// Sendet eine Kampagne
  Future<bool> sendCampaign(String campaignId) async {
    final result = await _repository.sendCampaign(campaignId);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is CampaignsLoaded) {
        final updatedCampaigns = currentState.campaigns.map((c) {
          if (c.id == campaignId) {
            return c.copyWith(status: CampaignStatus.sending);
          }
          return c;
        }).toList();
        state = currentState.copyWith(campaigns: updatedCampaigns);
      }
      return true;
    }
    return false;
  }

  /// Bricht eine Kampagne ab
  Future<bool> cancelCampaign(String campaignId) async {
    final result = await _repository.cancelCampaign(campaignId);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is CampaignsLoaded) {
        final updatedCampaigns = currentState.campaigns.map((c) {
          if (c.id == campaignId) {
            return c.copyWith(status: CampaignStatus.cancelled);
          }
          return c;
        }).toList();
        state = currentState.copyWith(campaigns: updatedCampaigns);
      }
      return true;
    }
    return false;
  }
}

// =============================================================================
// CAMPAIGN DETAIL NOTIFIER
// =============================================================================

class CampaignDetailNotifier extends StateNotifier<CampaignDetailState> {
  CampaignDetailNotifier() : super(const CampaignDetailInitial());

  final _repository = PushCampaignRepositoryImpl();

  /// Laedt eine Kampagne
  Future<void> loadCampaign(String campaignId) async {
    state = const CampaignDetailLoading();

    final result = await _repository.getCampaign(campaignId);

    if (result.isSuccess && result.data != null) {
      state = CampaignDetailLoaded(campaign: result.data!);

      // Lade Analytics wenn bereits gesendet
      if (result.data!.status.isSent) {
        await loadAnalytics(campaignId);
      }
    } else {
      state = CampaignDetailError(result.error ?? 'Unbekannter Fehler');
    }
  }

  /// Laedt Campaign Analytics
  Future<void> loadAnalytics(String campaignId) async {
    final currentState = state;
    if (currentState is! CampaignDetailLoaded) return;

    final result = await _repository.getCampaignAnalytics(campaignId);

    if (result.isSuccess && result.data != null) {
      state = currentState.copyWith(analytics: result.data);
    }
  }

  /// Aktualisiert eine Kampagne
  Future<bool> updateCampaign(
      String campaignId, UpdateCampaignRequest request) async {
    final result = await _repository.updateCampaign(campaignId, request);

    if (result.isSuccess && result.data != null) {
      final currentState = state;
      if (currentState is CampaignDetailLoaded) {
        state = currentState.copyWith(campaign: result.data);
      }
      return true;
    }
    return false;
  }

  /// Sendet eine Kampagne
  Future<bool> sendCampaign(String campaignId) async {
    final result = await _repository.sendCampaign(campaignId);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is CampaignDetailLoaded) {
        state = currentState.copyWith(
          campaign: currentState.campaign.copyWith(
            status: CampaignStatus.sending,
          ),
        );
      }
      return true;
    }
    return false;
  }

  /// Bricht eine Kampagne ab
  Future<bool> cancelCampaign(String campaignId) async {
    final result = await _repository.cancelCampaign(campaignId);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is CampaignDetailLoaded) {
        state = currentState.copyWith(
          campaign: currentState.campaign.copyWith(
            status: CampaignStatus.cancelled,
          ),
        );
      }
      return true;
    }
    return false;
  }

  /// Setzt State zurueck
  void reset() {
    state = const CampaignDetailInitial();
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final campaignsProvider =
    StateNotifierProvider<CampaignsNotifier, CampaignsState>((ref) {
  return CampaignsNotifier();
});

final campaignDetailProvider =
    StateNotifierProvider<CampaignDetailNotifier, CampaignDetailState>((ref) {
  return CampaignDetailNotifier();
});

final campaignFilterProvider = StateProvider<CampaignStatus?>((ref) => null);
