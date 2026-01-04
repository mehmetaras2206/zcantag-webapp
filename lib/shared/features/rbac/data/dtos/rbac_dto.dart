// =============================================================================
// RBAC_DTO.DART
// =============================================================================
// DTOs fuer RBAC API Operationen
// =============================================================================

import '../../domain/entities/rbac.dart';

/// TeamMember DTO
class TeamMemberDto {
  const TeamMemberDto({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.teamId,
    this.teamName,
    this.avatarUrl,
    this.joinedAt,
    this.lastActiveAt,
    this.cardCount,
    this.contactCount,
  });

  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? teamId;
  final String? teamName;
  final String? avatarUrl;
  final DateTime? joinedAt;
  final DateTime? lastActiveAt;
  final int? cardCount;
  final int? contactCount;

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) {
    return TeamMemberDto(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      role: json['role'] as String,
      teamId: json['team_id'] as String?,
      teamName: json['team_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String)
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.tryParse(json['last_active_at'] as String)
          : null,
      cardCount: json['card_count'] as int?,
      contactCount: json['contact_count'] as int?,
    );
  }

  TeamMember toDomain() {
    return TeamMember(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      role: UserRole.fromString(role),
      teamId: teamId,
      teamName: teamName,
      avatarUrl: avatarUrl,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt,
      cardCount: cardCount ?? 0,
      contactCount: contactCount ?? 0,
    );
  }
}

/// Team DTO
class TeamDto {
  const TeamDto({
    required this.id,
    required this.name,
    this.description,
    required this.companyId,
    this.parentTeamId,
    this.leaderId,
    this.leaderName,
    this.memberCount,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String companyId;
  final String? parentTeamId;
  final String? leaderId;
  final String? leaderName;
  final int? memberCount;
  final DateTime? createdAt;

  factory TeamDto.fromJson(Map<String, dynamic> json) {
    return TeamDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      companyId: json['company_id'] as String,
      parentTeamId: json['parent_team_id'] as String?,
      leaderId: json['leader_id'] as String?,
      leaderName: json['leader_name'] as String?,
      memberCount: json['member_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'company_id': companyId,
      'parent_team_id': parentTeamId,
      'leader_id': leaderId,
      'leader_name': leaderName,
      'member_count': memberCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Team toDomain() {
    return Team(
      id: id,
      name: name,
      description: description,
      companyId: companyId,
      parentTeamId: parentTeamId,
      leaderId: leaderId,
      leaderName: leaderName,
      memberCount: memberCount ?? 0,
      createdAt: createdAt,
    );
  }
}

/// Team Create DTO
class TeamCreateDto {
  const TeamCreateDto({
    required this.name,
    this.description,
    required this.companyId,
    this.parentTeamId,
    this.leaderId,
  });

  final String name;
  final String? description;
  final String companyId;
  final String? parentTeamId;
  final String? leaderId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'company_id': companyId,
    };
    if (description != null) map['description'] = description;
    if (parentTeamId != null) map['parent_team_id'] = parentTeamId;
    if (leaderId != null) map['leader_id'] = leaderId;
    return map;
  }
}

/// Team Update DTO
class TeamUpdateDto {
  const TeamUpdateDto({
    this.name,
    this.description,
    this.parentTeamId,
    this.leaderId,
  });

  final String? name;
  final String? description;
  final String? parentTeamId;
  final String? leaderId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (parentTeamId != null) map['parent_team_id'] = parentTeamId;
    if (leaderId != null) map['leader_id'] = leaderId;
    return map;
  }
}

/// Role Assignment DTO
class RoleAssignmentDto {
  const RoleAssignmentDto({
    required this.email,
    required this.role,
    this.teamId,
  });

  final String email;
  final String role;
  final String? teamId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'email': email,
      'role': role,
    };
    if (teamId != null) map['team_id'] = teamId;
    return map;
  }
}

/// Role Update DTO
class RoleUpdateDto {
  const RoleUpdateDto({
    required this.role,
    this.teamId,
  });

  final String role;
  final String? teamId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'role': role};
    if (teamId != null) map['team_id'] = teamId;
    return map;
  }
}

/// Invitation DTO
class InvitationDto {
  const InvitationDto({
    required this.id,
    required this.email,
    required this.role,
    required this.companyId,
    this.teamId,
    required this.status,
    required this.invitedBy,
    this.invitedByName,
    required this.createdAt,
    this.expiresAt,
    this.acceptedAt,
  });

  final String id;
  final String email;
  final String role;
  final String companyId;
  final String? teamId;
  final String status;
  final String invitedBy;
  final String? invitedByName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;

  factory InvitationDto.fromJson(Map<String, dynamic> json) {
    return InvitationDto(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      companyId: json['company_id'] as String,
      teamId: json['team_id'] as String?,
      status: json['status'] as String,
      invitedBy: json['invited_by'] as String,
      invitedByName: json['invited_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'] as String)
          : null,
    );
  }

  Invitation toDomain() {
    return Invitation(
      id: id,
      email: email,
      role: UserRole.fromString(role),
      companyId: companyId,
      teamId: teamId,
      status: InvitationStatus.fromString(status),
      invitedBy: invitedBy,
      invitedByName: invitedByName,
      createdAt: createdAt,
      expiresAt: expiresAt,
      acceptedAt: acceptedAt,
    );
  }
}
