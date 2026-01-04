// =============================================================================
// RBAC.DART
// =============================================================================
// RBAC Domain Entities (Rollen-basierte Zugriffskontrolle)
// =============================================================================

/// Rollen-Hierarchie
enum UserRole {
  superAdmin('super_admin', 1),
  regionalleiter('regionalleiter', 2),
  filialleiter('filialleiter', 3),
  teamleiter('teamleiter', 4),
  mitarbeiter('mitarbeiter', 5);

  const UserRole(this.value, this.hierarchyLevel);
  final String value;
  final int hierarchyLevel;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.mitarbeiter,
    );
  }

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super-Admin';
      case UserRole.regionalleiter:
        return 'Regionalleiter';
      case UserRole.filialleiter:
        return 'Filialleiter';
      case UserRole.teamleiter:
        return 'Teamleiter';
      case UserRole.mitarbeiter:
        return 'Mitarbeiter';
    }
  }

  String get description {
    switch (this) {
      case UserRole.superAdmin:
        return 'Vollzugriff auf alle Funktionen und Mitarbeiterverwaltung';
      case UserRole.regionalleiter:
        return 'Verwaltet mehrere Filialen in einer Region';
      case UserRole.filialleiter:
        return 'Verwaltet eine einzelne Filiale und deren Teams';
      case UserRole.teamleiter:
        return 'Verwaltet ein Team von Mitarbeitern';
      case UserRole.mitarbeiter:
        return 'Standardzugriff auf eigene Karten und Kontakte';
    }
  }

  /// Kann diese Rolle die andere Rolle verwalten?
  bool canManage(UserRole other) {
    return hierarchyLevel < other.hierarchyLevel;
  }

  /// Kann diese Rolle Rollen zuweisen?
  bool get canAssignRoles {
    return this == UserRole.superAdmin;
  }

  /// Kann diese Rolle Analytics sehen?
  bool get canViewAnalytics {
    return hierarchyLevel <= UserRole.filialleiter.hierarchyLevel;
  }

  /// Kann diese Rolle Push-Kampagnen erstellen?
  bool get canCreateCampaigns {
    return hierarchyLevel <= UserRole.teamleiter.hierarchyLevel;
  }

  /// Kann diese Rolle Mitglieder einladen?
  bool get canInviteMembers {
    return hierarchyLevel <= UserRole.teamleiter.hierarchyLevel;
  }
}

/// Berechtigungen
enum Permission {
  viewDashboard('view_dashboard'),
  viewAnalytics('view_analytics'),
  viewContacts('view_contacts'),
  manageContacts('manage_contacts'),
  viewCards('view_cards'),
  manageCards('manage_cards'),
  viewTeam('view_team'),
  manageTeam('manage_team'),
  inviteMembers('invite_members'),
  assignRoles('assign_roles'),
  viewCampaigns('view_campaigns'),
  manageCampaigns('manage_campaigns'),
  viewCompanySettings('view_company_settings'),
  manageCompanySettings('manage_company_settings');

  const Permission(this.value);
  final String value;

  static Permission? fromString(String value) {
    try {
      return Permission.values.firstWhere(
        (e) => e.value.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Team-Mitglied mit Rolle
class TeamMember {
  const TeamMember({
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
    this.cardCount = 0,
    this.contactCount = 0,
  });

  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final UserRole role;
  final String? teamId;
  final String? teamName;
  final String? avatarUrl;
  final DateTime? joinedAt;
  final DateTime? lastActiveAt;
  final int cardCount;
  final int contactCount;

  /// Vollstaendiger Name
  String get fullName {
    if (firstName == null && lastName == null) return email;
    return [firstName, lastName].whereType<String>().join(' ');
  }

  /// Initialen fuer Avatar
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return email.substring(0, 2).toUpperCase();
  }

  /// Hat Avatar?
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  TeamMember copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    UserRole? role,
    String? teamId,
    String? teamName,
    String? avatarUrl,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    int? cardCount,
    int? contactCount,
  }) {
    return TeamMember(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      cardCount: cardCount ?? this.cardCount,
      contactCount: contactCount ?? this.contactCount,
    );
  }
}

/// Team
class Team {
  const Team({
    required this.id,
    required this.name,
    this.description,
    required this.companyId,
    this.parentTeamId,
    this.leaderId,
    this.leaderName,
    this.memberCount = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String companyId;
  final String? parentTeamId;
  final String? leaderId;
  final String? leaderName;
  final int memberCount;
  final DateTime? createdAt;

  /// Hat einen Leader?
  bool get hasLeader => leaderId != null;

  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? companyId,
    String? parentTeamId,
    String? leaderId,
    String? leaderName,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      companyId: companyId ?? this.companyId,
      parentTeamId: parentTeamId ?? this.parentTeamId,
      leaderId: leaderId ?? this.leaderId,
      leaderName: leaderName ?? this.leaderName,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Einladungs-Status
enum InvitationStatus {
  pending('pending'),
  accepted('accepted'),
  expired('expired'),
  revoked('revoked');

  const InvitationStatus(this.value);
  final String value;

  static InvitationStatus fromString(String value) {
    return InvitationStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => InvitationStatus.pending,
    );
  }
}

/// Einladung
class Invitation {
  const Invitation({
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
  final UserRole role;
  final String companyId;
  final String? teamId;
  final InvitationStatus status;
  final String invitedBy;
  final String? invitedByName;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;

  /// Ist die Einladung abgelaufen?
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Kann noch angenommen werden?
  bool get canAccept => status == InvitationStatus.pending && !isExpired;
}
