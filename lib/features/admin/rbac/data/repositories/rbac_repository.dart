// =============================================================================
// RBAC_REPOSITORY.DART
// =============================================================================
// Repository fuer RBAC API Operationen
// =============================================================================

import '../../../../../shared/core/network/api_client.dart';
import '../../../../../shared/core/config/app_config.dart';
import '../../../../../shared/features/rbac/domain/entities/rbac.dart';
import '../../../../../shared/features/rbac/data/dtos/rbac_dto.dart';

/// Result Wrapper fuer Repository Operationen
class RbacResult<T> {
  const RbacResult.success(this.data)
      : error = null,
        isSuccess = true;
  const RbacResult.failure(this.error)
      : data = null,
        isSuccess = false;

  final T? data;
  final String? error;
  final bool isSuccess;
}

/// Abstract Repository Interface
abstract class RbacRepository {
  /// Holt alle Mitglieder einer Company
  Future<RbacResult<List<TeamMember>>> getMembers(String companyId);

  /// Weist eine Rolle zu (Einladung)
  Future<RbacResult<void>> assignRole(String companyId, RoleAssignmentDto data);

  /// Aktualisiert eine Rolle
  Future<RbacResult<TeamMember>> updateRole(
      String companyId, String userId, RoleUpdateDto data);

  /// Entfernt einen User aus der Company
  Future<RbacResult<void>> removeUser(String companyId, String userId);

  /// Holt alle Teams einer Company
  Future<RbacResult<List<Team>>> getTeams();

  /// Holt ein Team by ID
  Future<RbacResult<Team>> getTeam(String teamId);

  /// Erstellt ein Team
  Future<RbacResult<Team>> createTeam(TeamCreateDto data);

  /// Aktualisiert ein Team
  Future<RbacResult<Team>> updateTeam(String teamId, TeamUpdateDto data);

  /// Loescht ein Team
  Future<RbacResult<void>> deleteTeam(String teamId);
}

/// Repository Implementation
class RbacRepositoryImpl implements RbacRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<RbacResult<List<TeamMember>>> getMembers(String companyId) async {
    try {
      final response = await _apiClient.get(
        AppConfig.rbacMembers(companyId),
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data is List
            ? response.data
            : (response.data['items'] as List<dynamic>? ?? []);

        final members =
            items.map((json) => TeamMemberDto.fromJson(json).toDomain()).toList();

        return RbacResult.success(members);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Mitglieder');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<void>> assignRole(
      String companyId, RoleAssignmentDto data) async {
    try {
      final response = await _apiClient.post(
        AppConfig.rbacAssignRole(companyId),
        body: data.toJson(),
      );

      if (response.isSuccess) {
        return const RbacResult.success(null);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Zuweisen der Rolle');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<TeamMember>> updateRole(
    String companyId,
    String userId,
    RoleUpdateDto data,
  ) async {
    try {
      final response = await _apiClient.put(
        AppConfig.rbacUpdateRole(companyId, userId),
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final member = TeamMemberDto.fromJson(response.data).toDomain();
        return RbacResult.success(member);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Aktualisieren der Rolle');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<void>> removeUser(String companyId, String userId) async {
    try {
      final response = await _apiClient.delete(
        AppConfig.rbacRemoveUser(companyId, userId),
      );

      if (response.isSuccess) {
        return const RbacResult.success(null);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Entfernen des Mitglieds');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<List<Team>>> getTeams() async {
    try {
      final response = await _apiClient.get(
        AppConfig.teamsAll,
      );

      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data is List
            ? response.data
            : (response.data['items'] as List<dynamic>? ?? []);

        final teams =
            items.map((json) => TeamDto.fromJson(json).toDomain()).toList();

        return RbacResult.success(teams);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Laden der Teams');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<Team>> getTeam(String teamId) async {
    try {
      final response = await _apiClient.get(
        AppConfig.teamById(teamId),
      );

      if (response.isSuccess && response.data != null) {
        final team = TeamDto.fromJson(response.data).toDomain();
        return RbacResult.success(team);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Team nicht gefunden');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<Team>> createTeam(TeamCreateDto data) async {
    try {
      final response = await _apiClient.post(
        AppConfig.teamsCreate,
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final team = TeamDto.fromJson(response.data).toDomain();
        return RbacResult.success(team);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Erstellen des Teams');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<Team>> updateTeam(String teamId, TeamUpdateDto data) async {
    try {
      final response = await _apiClient.put(
        AppConfig.teamUpdate(teamId),
        body: data.toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final team = TeamDto.fromJson(response.data).toDomain();
        return RbacResult.success(team);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Aktualisieren des Teams');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }

  @override
  Future<RbacResult<void>> deleteTeam(String teamId) async {
    try {
      final response = await _apiClient.delete(
        AppConfig.teamDelete(teamId),
      );

      if (response.isSuccess) {
        return const RbacResult.success(null);
      } else {
        return RbacResult.failure(
            response.errorMessage ?? 'Fehler beim Loeschen des Teams');
      }
    } catch (e) {
      return RbacResult.failure('Netzwerkfehler: $e');
    }
  }
}
