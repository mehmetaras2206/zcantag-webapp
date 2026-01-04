// =============================================================================
// AUTH_REPOSITORY.DART
// =============================================================================
// Repository fuer Auth-Operationen (Login, Register, Token-Refresh)
// =============================================================================

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/web_storage.dart';
import '../../domain/entities/user.dart';
import '../dtos/auth_dtos.dart';

/// Abstrakte Auth Repository Schnittstelle
abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String email, String password, String name,
      {bool isBusinessAccount = false});
  Future<void> requestPasswordReset(String email);
  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<bool> refreshToken();
  Future<List<String>> getOAuthProviders();
  Future<String?> getOAuthUrl(String provider, String redirectUri);
  Future<AuthResult> handleOAuthCallback(String code, String provider);
}

/// Implementierung des Auth Repository
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authLogin,
        body: LoginRequestDto(email: email, password: password).toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final authResponse = AuthResponseDto.fromJson(data);

        // Token speichern
        await WebStorage.saveAccessToken(authResponse.accessToken);
        await WebStorage.saveRefreshToken(authResponse.refreshToken);
        _apiClient.setAccessToken(authResponse.accessToken);

        // User konvertieren und zurueckgeben
        final user = _mapUserDtoToEntity(authResponse.user);
        return AuthResult.success(user);
      } else if (response.statusCode == 401) {
        return AuthResult.failure('Ungueltige E-Mail oder Passwort');
      } else {
        return AuthResult.failure(
            response.errorMessage ?? 'Ein Fehler ist aufgetreten');
      }
    } catch (e) {
      return AuthResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<AuthResult> register(
    String email,
    String password,
    String name, {
    bool isBusinessAccount = false,
  }) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authRegister,
        body: RegisterRequestDto(
          email: email,
          password: password,
          name: name,
          isBusinessAccount: isBusinessAccount,
        ).toJson(),
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final authResponse = AuthResponseDto.fromJson(data);

        // Token speichern
        await WebStorage.saveAccessToken(authResponse.accessToken);
        await WebStorage.saveRefreshToken(authResponse.refreshToken);
        _apiClient.setAccessToken(authResponse.accessToken);

        // User konvertieren und zurueckgeben
        final user = _mapUserDtoToEntity(authResponse.user);
        return AuthResult.success(user);
      } else if (response.statusCode == 409) {
        return AuthResult.failure('E-Mail bereits registriert');
      } else {
        return AuthResult.failure(
            response.errorMessage ?? 'Registrierung fehlgeschlagen');
      }
    } catch (e) {
      return AuthResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.post(
        AppConfig.authPasswordReset,
        body: PasswordResetRequestDto(email: email).toJson(),
      );
      // Immer erfolgreich (Security: verraten nicht ob Email existiert)
    } catch (e) {
      // Fehler ignorieren, um nicht zu verraten ob Email existiert
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await WebStorage.getAccessToken();
      if (token == null) return null;

      _apiClient.setAccessToken(token);
      final response = await _apiClient.get(AppConfig.authMe);

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final userDto = UserDto.fromJson(data);
        return _mapUserDtoToEntity(userDto);
      } else {
        // Token ungueltig, entfernen
        await WebStorage.clearAll();
        _apiClient.setAccessToken(null);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Server-seitig Logout (optional)
      await _apiClient.post(AppConfig.authLogout, body: {});
    } catch (_) {
      // Ignorieren - lokaler Logout ist wichtig
    } finally {
      // Lokale Daten immer loeschen
      await WebStorage.clearAll();
      _apiClient.setAccessToken(null);
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await WebStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiClient.post(
        AppConfig.authRefresh,
        body: {'refresh_token': refreshToken},
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newToken = data['access_token'] as String?;
        if (newToken != null) {
          await WebStorage.saveAccessToken(newToken);
          _apiClient.setAccessToken(newToken);
          if (data['refresh_token'] != null) {
            await WebStorage.saveRefreshToken(data['refresh_token'] as String);
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  User _mapUserDtoToEntity(UserDto dto) {
    return User(
      id: dto.id,
      email: dto.email,
      name: dto.name,
      role: UserRole.fromString(dto.role),
      companyId: dto.companyId,
      isActive: dto.isActive,
      emailVerified: dto.emailVerified,
      createdAt: dto.createdAt,
    );
  }

  @override
  Future<List<String>> getOAuthProviders() async {
    try {
      final response = await _apiClient.get(AppConfig.authOAuthProviders);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final providers = data['providers'] as List<dynamic>?;
        return providers?.map((e) => e.toString()).toList() ?? [];
      }
      return ['google', 'apple']; // Fallback defaults
    } catch (e) {
      return ['google', 'apple']; // Fallback defaults
    }
  }

  @override
  Future<String?> getOAuthUrl(String provider, String redirectUri) async {
    try {
      final response = await _apiClient.get(
        '${AppConfig.authOAuthStart(provider)}?redirect_uri=$redirectUri',
      );
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthResult> handleOAuthCallback(String code, String provider) async {
    try {
      final response = await _apiClient.post(
        AppConfig.authOAuthExchange,
        body: {
          'code': code,
          'provider': provider,
        },
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final authResponse = AuthResponseDto.fromJson(data);

        // Token speichern
        await WebStorage.saveAccessToken(authResponse.accessToken);
        await WebStorage.saveRefreshToken(authResponse.refreshToken);
        _apiClient.setAccessToken(authResponse.accessToken);

        // User konvertieren und zurueckgeben
        final user = _mapUserDtoToEntity(authResponse.user);
        return AuthResult.success(user);
      } else {
        return AuthResult.failure(
            response.errorMessage ?? 'OAuth-Anmeldung fehlgeschlagen');
      }
    } catch (e) {
      return AuthResult.failure('Verbindungsfehler: ${e.toString()}');
    }
  }
}

/// Result-Klasse fuer Auth-Operationen
class AuthResult {
  const AuthResult._({
    this.user,
    this.error,
    required this.isSuccess,
  });

  final User? user;
  final String? error;
  final bool isSuccess;

  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(error: error, isSuccess: false);
  }
}
