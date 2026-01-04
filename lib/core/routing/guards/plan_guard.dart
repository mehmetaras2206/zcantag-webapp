// =============================================================================
// PLAN_GUARD.DART
// =============================================================================
// Guard und Widgets fuer Plan-basierte Zugriffskontrolle
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/core/theme/app_colors.dart';
import '../../../shared/core/theme/app_text_styles.dart';
import '../../../shared/features/company/domain/entities/company.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

/// Feature Requirements fuer verschiedene Routen
enum RequiredFeature {
  webContacts(PlanType.basic, 'Web-Kontakte', 'Kontakte im Web verwalten'),
  analytics(PlanType.basic, 'Analytics', 'Statistiken und Auswertungen'),
  premiumAnalytics(
      PlanType.premium, 'Premium Analytics', 'Erweiterte Auswertungen'),
  enterpriseAnalytics(
      PlanType.enterprise, 'Enterprise Analytics', 'Vollstaendige Analytics'),
  pushCampaigns(
      PlanType.premium, 'Push-Kampagnen', 'Push-Benachrichtigungen senden'),
  abTest(PlanType.enterprise, 'A/B Tests', 'A/B Tests durchfuehren'),
  realTime(
      PlanType.enterprise, 'Echtzeit-Dashboard', 'Echtzeit-Daten anzeigen');

  const RequiredFeature(
      this.minimumPlan, this.displayName, this.description);
  final PlanType minimumPlan;
  final String displayName;
  final String description;

  bool isAvailableFor(PlanType userPlan) {
    final userIndex = PlanType.values.indexOf(userPlan);
    final requiredIndex = PlanType.values.indexOf(minimumPlan);
    return userIndex >= requiredIndex;
  }
}

/// Plan Guard Provider
final planGuardProvider = Provider<PlanGuard>((ref) {
  return PlanGuard(ref);
});

/// Plan Guard Klasse
class PlanGuard {
  PlanGuard(this._ref);

  final Ref _ref;

  /// Prueft ob User das Feature nutzen kann
  bool canAccess(RequiredFeature feature) {
    final authState = _ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.user == null) return false;

    // TODO: Get actual plan from user/company
    // For now, use free as default
    const userPlan = PlanType.free;
    return feature.isAvailableFor(userPlan);
  }

  /// Prueft Route und gibt ggf. Upgrade-Route zurueck
  String? checkRoute(String location, RequiredFeature? feature) {
    if (feature == null) return null;
    if (!canAccess(feature)) {
      return '/subscription?upgrade=${feature.name}';
    }
    return null;
  }
}

/// Feature Guard Widget - zeigt Content oder Upgrade-Prompt
class FeatureGuard extends ConsumerWidget {
  const FeatureGuard({
    super.key,
    required this.feature,
    required this.child,
    this.upgradePrompt,
  });

  final RequiredFeature feature;
  final Widget child;
  final Widget? upgradePrompt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planGuard = ref.watch(planGuardProvider);

    if (planGuard.canAccess(feature)) {
      return child;
    }

    return upgradePrompt ?? _DefaultUpgradePrompt(feature: feature);
  }
}

/// Default Upgrade Prompt Widget
class _DefaultUpgradePrompt extends StatelessWidget {
  const _DefaultUpgradePrompt({required this.feature});

  final RequiredFeature feature;

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
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              feature.displayName,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarker,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Verfuegbar ab ${feature.minimumPlan.displayName}',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.upgrade),
              label: const Text('Jetzt upgraden'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline Upgrade Hint (fuer kleinere Bereiche)
class UpgradeHint extends StatelessWidget {
  const UpgradeHint({
    super.key,
    required this.feature,
    this.compact = false,
  });

  final RequiredFeature feature;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return InkWell(
        onTap: () => context.go('/subscription'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                feature.minimumPlan.displayName,
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => context.go('/subscription'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.displayName,
                    style: AppTextStyles.smallText.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Verfuegbar ab ${feature.minimumPlan.displayName}',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Dialog fuer Feature-Upgrade
Future<bool?> showUpgradeDialog(
  BuildContext context,
  RequiredFeature feature,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.backgroundDark,
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(feature.displayName),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(feature.description),
          const SizedBox(height: 16),
          Text(
            'Diese Funktion ist ab dem ${feature.minimumPlan.displayName}-Plan verfuegbar.',
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Spaeter'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            context.go('/subscription');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.backgroundDark,
          ),
          child: const Text('Upgraden'),
        ),
      ],
    ),
  );
}
