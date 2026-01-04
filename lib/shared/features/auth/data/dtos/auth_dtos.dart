// =============================================================================
// AUTH_DTOS.DART
// =============================================================================
// Data Transfer Objects fuer Auth-Operationen
// =============================================================================

/// DTO fuer Login-Request
class LoginRequestDto {
  const LoginRequestDto({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// DTO fuer Register-Request
class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.name,
    this.isBusinessAccount = false,
  });

  final String email;
  final String password;
  final String name;
  final bool isBusinessAccount;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'is_business_account': isBusinessAccount,
      };
}

/// DTO fuer Password-Reset-Request
class PasswordResetRequestDto {
  const PasswordResetRequestDto({
    required this.email,
  });

  final String email;

  Map<String, dynamic> toJson() => {
        'email': email,
      };
}

/// DTO fuer Auth-Response (Login/Register)
class AuthResponseDto {
  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserDto user;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// DTO fuer User-Daten
class UserDto {
  const UserDto({
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
  final String role;
  final String? companyId;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String? ?? 'individual',
      companyId: json['company_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      emailVerified: json['email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'company_id': companyId,
        'is_active': isActive,
        'email_verified': emailVerified,
        'created_at': createdAt.toIso8601String(),
      };
}
