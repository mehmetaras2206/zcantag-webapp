// =============================================================================
// COMPANY_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Company State Management
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/features/company/domain/entities/company.dart';
import '../../../../../shared/features/company/data/dtos/company_dto.dart';
import '../../data/repositories/company_repository.dart';

/// Company State
sealed class CompanyState {
  const CompanyState();
}

class CompanyInitial extends CompanyState {
  const CompanyInitial();
}

class CompanyLoading extends CompanyState {
  const CompanyLoading();
}

class CompanyLoaded extends CompanyState {
  const CompanyLoaded(this.company);
  final Company company;
}

class CompanyError extends CompanyState {
  const CompanyError(this.message);
  final String message;
}

class CompanyUpdating extends CompanyState {
  const CompanyUpdating(this.company);
  final Company company;
}

/// Company Notifier
class CompanyNotifier extends StateNotifier<CompanyState> {
  CompanyNotifier() : super(const CompanyInitial());

  final _repository = CompanyRepositoryImpl();

  /// Laedt Company-Daten
  Future<void> loadCompany(String companyId) async {
    state = const CompanyLoading();

    final result = await _repository.getCompany(companyId);

    if (result.isSuccess && result.data != null) {
      state = CompanyLoaded(result.data!);
    } else {
      state = CompanyError(result.error ?? 'Unbekannter Fehler');
    }
  }

  /// Aktualisiert Company-Daten
  Future<bool> updateCompany(String companyId, CompanyUpdateDto data) async {
    final currentState = state;
    if (currentState is! CompanyLoaded) return false;

    state = CompanyUpdating(currentState.company);

    final result = await _repository.updateCompany(companyId, data);

    if (result.isSuccess && result.data != null) {
      state = CompanyLoaded(result.data!);
      return true;
    } else {
      state = CompanyLoaded(currentState.company);
      return false;
    }
  }

  /// Aktualisiert nur das Logo (per URL)
  Future<bool> updateLogo(String companyId, String logoUrl) async {
    return updateCompany(companyId, CompanyUpdateDto(logoUrl: logoUrl));
  }

  /// Laedt ein Logo hoch und aktualisiert das Profil
  Future<bool> uploadLogo(
    String companyId,
    List<int> imageBytes,
    String fileName,
  ) async {
    final currentState = state;
    if (currentState is! CompanyLoaded) return false;

    state = CompanyUpdating(currentState.company);

    final result = await _repository.uploadLogo(companyId, imageBytes, fileName);

    if (result.isSuccess && result.data != null) {
      // Reload company to get updated logo
      await loadCompany(companyId);
      return true;
    } else {
      state = CompanyLoaded(currentState.company);
      return false;
    }
  }

  /// Aktualisiert Branding (Farben)
  Future<bool> updateBranding(
    String companyId, {
    String? primaryColor,
    String? secondaryColor,
  }) async {
    return updateCompany(
      companyId,
      CompanyUpdateDto(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
    );
  }
}

/// Provider Definition
final companyProvider =
    StateNotifierProvider<CompanyNotifier, CompanyState>((ref) {
  return CompanyNotifier();
});

/// Aktueller Company ID Provider (sollte aus Auth kommen)
final currentCompanyIdProvider = Provider<String?>((ref) {
  // TODO: Aus Auth-State holen
  return null;
});
