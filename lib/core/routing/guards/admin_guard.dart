// =============================================================================
// ADMIN_GUARD.DART
// =============================================================================
// Guard und Widgets fuer Admin/Rollen-basierte Zugriffskontrolle
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/core/theme/app_colors.dart';
import '../../../shared/core/theme/app_text_styles.dart';
import '../../../shared/features/rbac/domain/entities/rbac.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

/// Admin Guard Provider
final adminGuardProvider = Provider<AdminGuard>((ref) {
  return AdminGuard(ref);
});

/// Admin Guard Klasse
class AdminGuard {
  AdminGuard(this._ref);

  final Ref _ref;

  /// Prueft ob User Admin-Zugriff hat
  bool hasAdminAccess() {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.user == null) return false;

    // TODO: Get actual role from user
    // For now, assume admin access for any authenticated user
    // In production, this would check the user's role in the company
    return true;
  }

  /// Prueft ob User eine bestimmte Rolle oder hoeher hat
  bool hasRole(UserRole minimumRole) {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.user == null) return false;

    // TODO: Get actual role from user
    // For now, return true for demo
    return true;
  }

  /// Prueft ob User eine bestimmte Permission hat
  bool hasPermission(Permission permission) {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.user == null) return false;

    // TODO: Get actual permissions from user role
    // For now, return true for demo
    return true;
  }

  /// Prueft Route und gibt ggf. Redirect zurueck
  String? checkRoute(String location) {
    // Pruefe ob Admin-Route
    if (location.startsWith('/admin')) {
      if (!hasAdminAccess()) {
        return '/';
      }
    }
    return null;
  }
}

/// Role Guard Widget - zeigt Content oder Access Denied
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.minimumRole,
    required this.child,
    this.fallback,
  });

  final UserRole minimumRole;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminGuard = ref.watch(adminGuardProvider);

    if (adminGuard.hasRole(minimumRole)) {
      return child;
    }

    return fallback ?? _AccessDenied(requiredRole: minimumRole);
  }
}

/// Permission Guard Widget
class PermissionGuard extends ConsumerWidget {
  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  final Permission permission;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminGuard = ref.watch(adminGuardProvider);

    if (adminGuard.hasPermission(permission)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}

/// Admin Guard Widget - zeigt Content nur fuer Admins
class AdminGuardWidget extends ConsumerWidget {
  const AdminGuardWidget({
    super.key,
    required this.child,
    this.fallback,
  });

  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminGuard = ref.watch(adminGuardProvider);

    if (adminGuard.hasAdminAccess()) {
      return child;
    }

    return fallback ?? const _NoAdminAccess();
  }
}

/// Access Denied Widget
class _AccessDenied extends StatelessWidget {
  const _AccessDenied({required this.requiredRole});

  final UserRole requiredRole;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Zugriff verweigert',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sie benoetigen mindestens die Rolle "${requiredRole.displayName}" um auf diesen Bereich zuzugreifen.',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

/// No Admin Access Widget
class _NoAdminAccess extends StatelessWidget {
  const _NoAdminAccess();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Admin-Bereich',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sie haben keinen Zugriff auf den Admin-Bereich. Kontaktieren Sie Ihren Administrator.',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conditional Button basierend auf Permission
class PermissionButton extends ConsumerWidget {
  const PermissionButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.child,
    this.disabledMessage,
  });

  final Permission permission;
  final VoidCallback onPressed;
  final Widget child;
  final String? disabledMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminGuard = ref.watch(adminGuardProvider);
    final hasPermission = adminGuard.hasPermission(permission);

    return Tooltip(
      message: hasPermission ? '' : (disabledMessage ?? 'Keine Berechtigung'),
      child: ElevatedButton(
        onPressed: hasPermission ? onPressed : null,
        child: child,
      ),
    );
  }
}

/// Icon Button mit Permission Check
class PermissionIconButton extends ConsumerWidget {
  const PermissionIconButton({
    super.key,
    required this.permission,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.disabledTooltip,
  });

  final Permission permission;
  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;
  final String? disabledTooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminGuard = ref.watch(adminGuardProvider);
    final hasPermission = adminGuard.hasPermission(permission);

    return IconButton(
      onPressed: hasPermission ? onPressed : null,
      icon: icon,
      tooltip: hasPermission
          ? tooltip
          : (disabledTooltip ?? 'Keine Berechtigung'),
    );
  }
}
