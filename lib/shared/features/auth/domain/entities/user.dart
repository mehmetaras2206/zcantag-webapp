// =============================================================================
// USER.DART
// =============================================================================
// Domain Entity fuer Benutzer. Kopiert von mobilapp.
// =============================================================================

/// Domain Entity fuer einen Benutzer
class User {
  const User({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.companyId,
    required this.isActive,
    required this.emailVerified,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? name;
  final UserRole role;
  final String? companyId;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;

  /// Prueft ob der User zu einem Unternehmen gehoert
  bool get hasCompany => companyId != null;

  /// Prueft ob der User Admin-Rechte hat
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  /// Prueft ob der User Super-Admin ist
  bool get isSuperAdmin => role == UserRole.superAdmin;

  /// Prueft ob der User mindestens Editor ist
  bool get canEdit =>
      role == UserRole.editor ||
      role == UserRole.admin ||
      role == UserRole.superAdmin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';

  /// Erstellt eine Kopie mit geaenderten Werten
  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? companyId,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Benutzerrollen gemaess RBAC
enum UserRole {
  /// Einzelperson ohne Unternehmen (Free Plan)
  individual,

  /// Nur-Lesen-Zugriff (Enterprise)
  viewer,

  /// Bearbeiter mit eingeschraenkten Rechten (Enterprise)
  editor,

  /// Unternehmens-Manager (Enterprise)
  admin,

  /// Unternehmensinhaber mit vollen Rechten (Enterprise)
  superAdmin;

  /// Erstellt UserRole aus einem String (API-Response)
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'editor':
        return UserRole.editor;
      case 'viewer':
        return UserRole.viewer;
      case 'individual':
      default:
        return UserRole.individual;
    }
  }

  /// Konvertiert die Rolle zu einem API-String
  String toApiString() {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.editor:
        return 'editor';
      case UserRole.viewer:
        return 'viewer';
      case UserRole.individual:
        return 'individual';
    }
  }

  /// Benutzerfreundlicher Name
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super-Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.editor:
        return 'Editor';
      case UserRole.viewer:
        return 'Viewer';
      case UserRole.individual:
        return 'Einzelperson';
    }
  }
}
