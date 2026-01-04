// =============================================================================
// AUTH_GUARD.DART
// =============================================================================
// Route Guard fuer Auth-geschuetzte Seiten
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

/// Listenable fuer GoRouter Redirect
class AuthGuard extends ChangeNotifier {
  AuthGuard(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref _ref;

  /// Prueft ob Redirect noetig ist
  String? redirect(String location) {
    final authState = _ref.read(authStateProvider);

    // Waehrend Loading nicht redirecten
    if (authState.isLoading) return null;

    // Public Routes die keinen Auth brauchen
    const publicRoutes = ['/login', '/register', '/forgot-password'];
    final isPublicRoute = publicRoutes.contains(location) ||
        location.startsWith('/card/');

    if (authState.isAuthenticated) {
      // Eingeloggt + auf Auth-Seite -> redirect zu Home
      if (isPublicRoute) return '/';
      return null;
    } else {
      // Nicht eingeloggt + auf geschuetzter Seite -> redirect zu Login
      if (!isPublicRoute) return '/login';
      return null;
    }
  }
}

/// Provider fuer AuthGuard
final authGuardProvider = Provider<AuthGuard>((ref) {
  return AuthGuard(ref);
});
