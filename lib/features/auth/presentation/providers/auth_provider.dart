// =============================================================================
// AUTH_PROVIDER.DART
// =============================================================================
// Riverpod Provider fuer Auth-State
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/features/auth/data/repositories/auth_repository.dart';
import '../../../../shared/features/auth/domain/entities/user.dart';

/// Provider fuer das AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provider fuer den aktuellen Auth-State
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// Provider fuer den aktuellen User (nullable)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

/// Provider der prueft ob User eingeloggt ist
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(AuthState.initial()) {
    // Beim Start pruefen ob Session existiert
    _checkAuthStatus();
  }

  final AuthRepository _repository;

  /// Prueft beim App-Start ob eine gueltige Session existiert
  Future<void> _checkAuthStatus() async {
    state = AuthState.loading();

    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Login mit Email und Passwort
  Future<String?> login(String email, String password) async {
    state = AuthState.loading();

    final result = await _repository.login(email, password);

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
      return null; // Kein Fehler
    } else {
      state = AuthState.unauthenticated();
      return result.error ?? 'Login fehlgeschlagen';
    }
  }

  /// Registrierung
  Future<String?> register(
    String email,
    String password,
    String name, {
    bool isBusinessAccount = false,
  }) async {
    state = AuthState.loading();

    final result = await _repository.register(
      email,
      password,
      name,
      isBusinessAccount: isBusinessAccount,
    );

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
      return null;
    } else {
      state = AuthState.unauthenticated();
      return result.error ?? 'Registrierung fehlgeschlagen';
    }
  }

  /// Passwort-Reset anfordern
  Future<void> requestPasswordReset(String email) async {
    await _repository.requestPasswordReset(email);
  }

  /// Logout
  Future<void> logout() async {
    await _repository.logout();
    state = AuthState.unauthenticated();
  }

  /// Token aktualisieren
  Future<bool> refreshToken() async {
    return await _repository.refreshToken();
  }

  /// Session neu laden
  Future<void> refreshSession() async {
    final user = await _repository.getCurrentUser();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Verfuegbare OAuth-Provider abrufen
  Future<List<String>> getOAuthProviders() async {
    return await _repository.getOAuthProviders();
  }

  /// OAuth-URL fuer einen Provider abrufen
  Future<String?> getOAuthUrl(String provider, String redirectUri) async {
    return await _repository.getOAuthUrl(provider, redirectUri);
  }

  /// OAuth-Callback verarbeiten
  Future<String?> handleOAuthCallback(String code, String provider) async {
    state = AuthState.loading();

    final result = await _repository.handleOAuthCallback(code, provider);

    if (result.isSuccess && result.user != null) {
      state = AuthState.authenticated(result.user!);
      return null;
    } else {
      state = AuthState.unauthenticated();
      return result.error ?? 'OAuth-Anmeldung fehlgeschlagen';
    }
  }
}

/// Auth State
class AuthState {
  AuthState._({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
  });

  final User? user;
  final bool isLoading;
  final bool isAuthenticated;

  factory AuthState.initial() {
    return AuthState._();
  }

  factory AuthState.loading() {
    return AuthState._(isLoading: true);
  }

  factory AuthState.authenticated(User user) {
    return AuthState._(user: user, isAuthenticated: true);
  }

  factory AuthState.unauthenticated() {
    return AuthState._(isAuthenticated: false);
  }
}
