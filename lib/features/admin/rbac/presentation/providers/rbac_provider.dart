// =============================================================================
// RBAC_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer RBAC State Management
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/features/rbac/domain/entities/rbac.dart';
import '../../../../../shared/features/rbac/data/dtos/rbac_dto.dart';
import '../../data/repositories/rbac_repository.dart';

// =============================================================================
// MEMBERS STATE
// =============================================================================

sealed class MembersState {
  const MembersState();
}

class MembersInitial extends MembersState {
  const MembersInitial();
}

class MembersLoading extends MembersState {
  const MembersLoading();
}

class MembersLoaded extends MembersState {
  const MembersLoaded(this.members);
  final List<TeamMember> members;

  /// Gefilterte Mitglieder nach Rolle
  List<TeamMember> byRole(UserRole role) =>
      members.where((m) => m.role == role).toList();

  /// Gefilterte Mitglieder nach Team
  List<TeamMember> byTeam(String teamId) =>
      members.where((m) => m.teamId == teamId).toList();

  /// Mitglieder ohne Team
  List<TeamMember> get unassigned =>
      members.where((m) => m.teamId == null).toList();

  /// Anzahl pro Rolle
  Map<UserRole, int> get countByRole {
    final counts = <UserRole, int>{};
    for (final member in members) {
      counts[member.role] = (counts[member.role] ?? 0) + 1;
    }
    return counts;
  }
}

class MembersError extends MembersState {
  const MembersError(this.message);
  final String message;
}

// =============================================================================
// MEMBERS NOTIFIER
// =============================================================================

class MembersNotifier extends StateNotifier<MembersState> {
  MembersNotifier() : super(const MembersInitial());

  final _repository = RbacRepositoryImpl();

  Future<void> loadMembers(String companyId) async {
    state = const MembersLoading();

    final result = await _repository.getMembers(companyId);

    if (result.isSuccess && result.data != null) {
      state = MembersLoaded(result.data!);
    } else {
      state = MembersError(result.error ?? 'Unbekannter Fehler');
    }
  }

  Future<bool> inviteMember(
    String companyId,
    String email,
    UserRole role, {
    String? teamId,
  }) async {
    final data = RoleAssignmentDto(
      email: email,
      role: role.value,
      teamId: teamId,
    );

    final result = await _repository.assignRole(companyId, data);

    if (result.isSuccess) {
      // Reload members
      await loadMembers(companyId);
      return true;
    }
    return false;
  }

  Future<bool> updateRole(
    String companyId,
    String userId,
    UserRole newRole, {
    String? teamId,
  }) async {
    final data = RoleUpdateDto(role: newRole.value, teamId: teamId);
    final result = await _repository.updateRole(companyId, userId, data);

    if (result.isSuccess) {
      // Update local state
      final currentState = state;
      if (currentState is MembersLoaded) {
        final updatedMembers = currentState.members.map((m) {
          if (m.userId == userId && result.data != null) {
            return result.data!;
          }
          return m;
        }).toList();
        state = MembersLoaded(updatedMembers);
      }
      return true;
    }
    return false;
  }

  Future<bool> removeMember(String companyId, String userId) async {
    final result = await _repository.removeUser(companyId, userId);

    if (result.isSuccess) {
      // Update local state
      final currentState = state;
      if (currentState is MembersLoaded) {
        final updatedMembers =
            currentState.members.where((m) => m.userId != userId).toList();
        state = MembersLoaded(updatedMembers);
      }
      return true;
    }
    return false;
  }
}

// =============================================================================
// TEAMS STATE
// =============================================================================

sealed class TeamsState {
  const TeamsState();
}

class TeamsInitial extends TeamsState {
  const TeamsInitial();
}

class TeamsLoading extends TeamsState {
  const TeamsLoading();
}

class TeamsLoaded extends TeamsState {
  const TeamsLoaded(this.teams);
  final List<Team> teams;
}

class TeamsError extends TeamsState {
  const TeamsError(this.message);
  final String message;
}

// =============================================================================
// TEAMS NOTIFIER
// =============================================================================

class TeamsNotifier extends StateNotifier<TeamsState> {
  TeamsNotifier() : super(const TeamsInitial());

  final _repository = RbacRepositoryImpl();

  Future<void> loadTeams() async {
    state = const TeamsLoading();

    final result = await _repository.getTeams();

    if (result.isSuccess && result.data != null) {
      state = TeamsLoaded(result.data!);
    } else {
      state = TeamsError(result.error ?? 'Unbekannter Fehler');
    }
  }

  Future<bool> createTeam(TeamCreateDto data) async {
    final result = await _repository.createTeam(data);

    if (result.isSuccess) {
      await loadTeams();
      return true;
    }
    return false;
  }

  Future<bool> updateTeam(String teamId, TeamUpdateDto data) async {
    final result = await _repository.updateTeam(teamId, data);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is TeamsLoaded && result.data != null) {
        final updatedTeams = currentState.teams.map((t) {
          if (t.id == teamId) return result.data!;
          return t;
        }).toList();
        state = TeamsLoaded(updatedTeams);
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteTeam(String teamId) async {
    final result = await _repository.deleteTeam(teamId);

    if (result.isSuccess) {
      final currentState = state;
      if (currentState is TeamsLoaded) {
        final updatedTeams =
            currentState.teams.where((t) => t.id != teamId).toList();
        state = TeamsLoaded(updatedTeams);
      }
      return true;
    }
    return false;
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final membersProvider =
    StateNotifierProvider<MembersNotifier, MembersState>((ref) {
  return MembersNotifier();
});

final teamsProvider = StateNotifierProvider<TeamsNotifier, TeamsState>((ref) {
  return TeamsNotifier();
});

/// Selected Member (fuer Detail-Ansicht)
final selectedMemberProvider = StateProvider<TeamMember?>((ref) => null);

/// Selected Team (fuer Detail-Ansicht)
final selectedTeamProvider = StateProvider<Team?>((ref) => null);
