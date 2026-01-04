// =============================================================================
// ADMIN_DASHBOARD_SCREEN.DART
// =============================================================================
// Uebersicht fuer den Admin-Bereich
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../layouts/admin_shell.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminShell(
      currentRoute: '/admin',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('Dashboard', style: AppTextStyles.heading1),
            const SizedBox(height: 8),
            Text(
              'Willkommen im Admin-Bereich',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      icon: Icons.credit_card,
                      title: 'Aktive Karten',
                      value: '12',
                      trend: '+3 diese Woche',
                      trendPositive: true,
                    ),
                    _buildStatCard(
                      icon: Icons.people,
                      title: 'Team-Mitglieder',
                      value: '5',
                      trend: '2 offen',
                      trendPositive: false,
                    ),
                    _buildStatCard(
                      icon: Icons.visibility,
                      title: 'Kartenaufrufe',
                      value: '1.2K',
                      trend: '+18% MTM',
                      trendPositive: true,
                    ),
                    _buildStatCard(
                      icon: Icons.contacts,
                      title: 'Neue Kontakte',
                      value: '89',
                      trend: '+12 diese Woche',
                      trendPositive: true,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Quick Actions
            Text('Schnellzugriff', style: AppTextStyles.heading2),
            const SizedBox(height: 16),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _QuickActionCard(
                  icon: Icons.business,
                  label: 'Unternehmensprofil',
                  onTap: () => context.go('/admin/company'),
                ),
                _QuickActionCard(
                  icon: Icons.person_add,
                  label: 'Mitarbeiter einladen',
                  onTap: () => context.go('/admin/team/invite'),
                ),
                _QuickActionCard(
                  icon: Icons.analytics,
                  label: 'Analytics ansehen',
                  onTap: () => context.go('/admin/analytics'),
                ),
                _QuickActionCard(
                  icon: Icons.campaign,
                  label: 'Kampagne erstellen',
                  onTap: () => context.go('/admin/campaigns/new'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activity (Placeholder)
            Text('Letzte Aktivitaeten', style: AppTextStyles.heading2),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildActivityItem(
                    icon: Icons.person_add,
                    title: 'Max Mustermann eingeladen',
                    subtitle: 'vor 2 Stunden',
                  ),
                  const Divider(height: 24),
                  _buildActivityItem(
                    icon: Icons.credit_card,
                    title: 'Neue Karte erstellt',
                    subtitle: 'Marketing-Team Karte',
                  ),
                  const Divider(height: 24),
                  _buildActivityItem(
                    icon: Icons.campaign,
                    title: 'Kampagne gesendet',
                    subtitle: 'Newsletter Januar - 234 Empfaenger',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool trendPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (trendPositive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.smallText.copyWith(
                    color: trendPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.heading1),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyRegular),
              Text(
                subtitle,
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Quick Action Card
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundDark,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.smallText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
