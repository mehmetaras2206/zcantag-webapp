// =============================================================================
// ADMIN_SHELL.DART
// =============================================================================
// Shell-Layout fuer den Admin-Bereich mit Sidebar Navigation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  final Widget child;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Admin'),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          right: BorderSide(
            color: AppColors.textWhite.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.textWhite.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.backgroundDarker,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admin-Panel',
                    style: AppTextStyles.heading3,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: '/admin',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.business,
                  label: 'Unternehmen',
                  route: '/admin/company',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  label: 'Team',
                  route: '/admin/team',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics,
                  label: 'Analytics',
                  route: '/admin/analytics',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.campaign,
                  label: 'Push-Kampagnen',
                  route: '/admin/campaigns',
                ),
              ],
            ),
          ),

          // Footer - Zurueck zur App
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.textWhite.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: InkWell(
              onTap: () => context.go('/'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Zurueck zur App',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textWhite.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.backgroundDarker,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Admin-Panel',
                      style: AppTextStyles.heading3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(context, icon: Icons.dashboard, label: 'Dashboard', route: '/admin'),
                  _buildNavItem(context, icon: Icons.business, label: 'Unternehmen', route: '/admin/company'),
                  _buildNavItem(context, icon: Icons.people, label: 'Team', route: '/admin/team'),
                  _buildNavItem(context, icon: Icons.analytics, label: 'Analytics', route: '/admin/analytics'),
                  _buildNavItem(context, icon: Icons.campaign, label: 'Push-Kampagnen', route: '/admin/campaigns'),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.textWhite.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/');
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Zurueck zur App',
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isSelected = currentRoute == route ||
        (route != '/admin' && currentRoute.startsWith(route));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            // Schliesse Drawer falls offen
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
            context.go(route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textWhite.withValues(alpha: 0.7),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textWhite.withValues(alpha: 0.9),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
