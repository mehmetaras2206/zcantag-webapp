// =============================================================================
// HOME_SCREEN.DART
// =============================================================================
// Dashboard / Home Screen fuer eingeloggte Benutzer
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZCANTAG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  context.push('/settings');
                  break;
                case 'subscription':
                  context.push('/subscription');
                  break;
                case 'admin':
                  context.push('/admin');
                  break;
                case 'logout':
                  // TODO: Implement logout
                  context.go('/login');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Einstellungen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'subscription',
                child: ListTile(
                  leading: Icon(Icons.star_outline),
                  title: Text('Abo & Preise'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'admin',
                child: ListTile(
                  leading: Icon(Icons.admin_panel_settings_outlined),
                  title: Text('Admin-Panel'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text('Abmelden', style: TextStyle(color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              'Willkommen zurueck!',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              'Verwalte deine digitalen Visitenkarten.',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.credit_card,
                    label: 'Karten',
                    value: '3',
                    onTap: () => context.push('/cards'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Icons.contacts,
                    label: 'Kontakte',
                    value: '127',
                    onTap: () => context.push('/contacts'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Quick Actions
            const Text(
              'Schnellaktionen',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 16),
            _QuickActionButton(
              icon: Icons.add,
              label: 'Neue Karte erstellen',
              onTap: () => context.push('/cards/new'),
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.qr_code_scanner,
              label: 'QR-Code scannen',
              onTap: () {
                // TODO: Implement QR scanner
              },
            ),
            const SizedBox(height: 12),
            _QuickActionButton(
              icon: Icons.share,
              label: 'Karte teilen',
              onTap: () => context.push('/cards'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/cards');
              break;
            case 2:
              context.push('/contacts');
              break;
            case 3:
              context.push('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Karten',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Kontakte',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Mehr',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: AppColors.primary, size: 28),
                  Text(
                    value,
                    style: AppTextStyles.statValue,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(label, style: AppTextStyles.bodyRegular),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
