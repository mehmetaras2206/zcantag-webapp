// =============================================================================
// COMPANY_REPOSITORY.DART
// =============================================================================
// Repository fuer Company API Operationen
// =============================================================================

import '../../../../../shared/core/network/api_client.dart';
import '../../../../../shared/core/config/app_config.dart';
import '../../../../../shared/features/company/domain/entities/company.dart';
import '../../../../../shared/features/company/data/dtos/company_dto.dart';

/// Result Wrapper fuer Repository Operationen
class CompanyResult<T> {
  const CompanyResult.success(this.data)
      : error = null,
        isSuccess = true;
  const CompanyResult.failure(this.error)
      : data = null,
        isSuccess = false;

  final T? data;
  final String? error;
  final bool isSuccess;
}

/// Abstract Repository Interface
abstract class CompanyRepository {
  /// Holt eine Company by ID
  Future<CompanyResult<Company>> getCompany(String companyId);

  /// Aktualisiert eine Company
  Future<CompanyResult<Company>> updateCompany(
      String companyId, CompanyUpdateDto data);

  /// Laedt ein Logo hoch
  Future<CompanyResult<String>> uploadLogo(
      String companyId, List<int> imageBytes, String fileName);
}

/// Repository Implementation
class CompanyRepositoryImpl implements CompanyRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<CompanyResult<Company>> getCompany(String companyId) async {
    try {
      final response = await _apiClient.get(
        AppConfig.companyById(companyId),
      );

      if (response.isSuccess && response.data != null) {
        final company = CompanyDto.fromJson(response.data).toDomain();
        return CompanyResult.success(company);
      } else {
        return CompanyResult.failure(
            response.errorMessage ?? 'Unternehmen nicht gefunden');
      }
    } catch (e) {
      return CompanyResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CompanyResult<Company>> updateCompany(
    String companyId,
    CompanyUpdateDto data,
  ) async {
    try {
      final response = await _apiClient.put(
        AppConfig.companyUpdate(companyId),
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final company = CompanyDto.fromJson(response.data).toDomain();
        return CompanyResult.success(company);
      } else {
        return CompanyResult.failure(
            response.errorMessage ?? 'Fehler beim Aktualisieren des Unternehmens');
      }
    } catch (e) {
      return CompanyResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<CompanyResult<String>> uploadLogo(
    String companyId,
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      final response = await _apiClient.uploadFile(
        AppConfig.companyUploadLogo(companyId),
        imageBytes,
        fileName,
        fieldName: 'logo',
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final logoUrl = data['logo_url'] as String?;
        if (logoUrl != null) {
          return CompanyResult.success(logoUrl);
        }
        return CompanyResult.failure('Logo-URL nicht in Antwort gefunden');
      } else {
        return CompanyResult.failure(
            response.errorMessage ?? 'Fehler beim Hochladen des Logos');
      }
    } catch (e) {
      return CompanyResult.failure('Netzwerkfehler: $e');
    }
  }
}
