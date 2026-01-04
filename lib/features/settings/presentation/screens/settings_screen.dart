// =============================================================================
// SETTINGS_SCREEN.DART
// =============================================================================
// User Settings Screen
// =============================================================================

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Settings Screen
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Notification Settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _weeklyReport = false;

  // Privacy Settings
  bool _publicProfile = true;
  bool _showContactCount = true;
  bool _allowAnalytics = true;

  // Appearance Settings
  String _language = 'de';
  String _theme = 'dark';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text('Einstellungen', style: AppTextStyles.heading2),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Speichern',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil-Sektion
            _buildSectionHeader('Profil', Icons.person),
            _SettingsCard(
              children: [
                _ProfileTile(
                  name: authState.user?.name ?? 'Benutzer',
                  email: authState.user?.email ?? '',
                  onEdit: () => _showEditProfileDialog(),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.key,
                  title: 'Passwort aendern',
                  subtitle: 'Sicherheit Ihres Kontos',
                  onTap: () => _showChangePasswordDialog(),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.security,
                  title: 'Zwei-Faktor-Authentifizierung',
                  subtitle: 'Zusaetzliche Sicherheit aktivieren',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Bald verfuegbar',
                      style: AppTextStyles.smallText.copyWith(
                        color: Colors.orange,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Benachrichtigungen
            _buildSectionHeader('Benachrichtigungen', Icons.notifications),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.phone_android,
                  title: 'Push-Benachrichtigungen',
                  subtitle: 'Neue Kontakte und Aktivitaeten',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                const Divider(),
                _SwitchTile(
                  icon: Icons.email,
                  title: 'E-Mail-Benachrichtigungen',
                  subtitle: 'Wichtige Updates per E-Mail',
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
                const Divider(),
                _SwitchTile(
                  icon: Icons.summarize,
                  title: 'Woechentlicher Bericht',
                  subtitle: 'Statistiken jeden Montag',
                  value: _weeklyReport,
                  onChanged: (v) => setState(() => _weeklyReport = v),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Datenschutz
            _buildSectionHeader('Datenschutz', Icons.privacy_tip),
            _SettingsCard(
              children: [
                _SwitchTile(
                  icon: Icons.public,
                  title: 'Oeffentliches Profil',
                  subtitle: 'Ihre Karte ist oeffentlich abrufbar',
                  value: _publicProfile,
                  onChanged: (v) => setState(() => _publicProfile = v),
                ),
                const Divider(),
                _SwitchTile(
                  icon: Icons.visibility,
                  title: 'Kontaktanzahl anzeigen',
                  subtitle: 'Kontakte auf Profilseite zeigen',
                  value: _showContactCount,
                  onChanged: (v) => setState(() => _showContactCount = v),
                ),
                const Divider(),
                _SwitchTile(
                  icon: Icons.analytics,
                  title: 'Analytics erlauben',
                  subtitle: 'Nutzungsstatistiken erfassen',
                  value: _allowAnalytics,
                  onChanged: (v) => setState(() => _allowAnalytics = v),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Darstellung
            _buildSectionHeader('Darstellung', Icons.palette),
            _SettingsCard(
              children: [
                _DropdownTile(
                  icon: Icons.language,
                  title: 'Sprache',
                  value: _language,
                  items: const [
                    DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'tr', child: Text('Tuerkce')),
                  ],
                  onChanged: (v) => setState(() => _language = v ?? 'de'),
                ),
                const Divider(),
                _DropdownTile(
                  icon: Icons.dark_mode,
                  title: 'Design',
                  value: _theme,
                  items: const [
                    DropdownMenuItem(value: 'dark', child: Text('Dunkel')),
                    DropdownMenuItem(value: 'light', child: Text('Hell')),
                    DropdownMenuItem(value: 'system', child: Text('System')),
                  ],
                  onChanged: (v) => setState(() => _theme = v ?? 'dark'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Abonnement
            _buildSectionHeader('Abonnement', Icons.card_membership),
            _SettingsCard(
              children: [
                _SubscriptionTile(
                  // TODO: Plan aus Company/Subscription-Daten laden
                  plan: 'free',
                  onUpgrade: () => context.push('/subscription'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Daten & Speicher
            _buildSectionHeader('Daten & Speicher', Icons.storage),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.download,
                  title: 'Daten exportieren',
                  subtitle: 'Alle Ihre Daten herunterladen',
                  onTap: () => _exportData(),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.delete_sweep,
                  title: 'Cache leeren',
                  subtitle: 'Temporaere Dateien loeschen',
                  onTap: () => _clearCache(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Support
            _buildSectionHeader('Support', Icons.help),
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Hilfe & FAQ',
                  subtitle: 'Haeufig gestellte Fragen',
                  onTap: () => _openHelp(),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.mail_outline,
                  title: 'Support kontaktieren',
                  subtitle: 'support@zcantag.de',
                  onTap: () => _contactSupport(),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Ueber ZCANTAG',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _showAboutDialog(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Abmelden
            Center(
              child: TextButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Abmelden',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Konto loeschen
            Center(
              child: TextButton(
                onPressed: () => _showDeleteAccountDialog(),
                child: Text(
                  'Konto loeschen',
                  style: AppTextStyles.smallText.copyWith(
                    color: Colors.red.withValues(alpha: 0.7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Einstellungen gespeichert'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Profil bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
                filled: true,
                fillColor: AppColors.backgroundDarker,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'E-Mail',
                filled: true,
                fillColor: AppColors.backgroundDarker,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil aktualisiert'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Speichern', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Passwort aendern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Aktuelles Passwort',
                filled: true,
                fillColor: AppColors.backgroundDarker,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Neues Passwort',
                filled: true,
                fillColor: AppColors.backgroundDarker,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Neues Passwort bestaetigen',
                filled: true,
                fillColor: AppColors.backgroundDarker,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passwort geaendert'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Aendern', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datenexport wird vorbereitet...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache geleert'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openHelp() {
    // TODO: Implement help page navigation
  }

  void _contactSupport() {
    // TODO: Implement support contact
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Z',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('ZCANTAG'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: AppTextStyles.bodyRegular,
            ),
            const SizedBox(height: 8),
            Text(
              'Digitale Visitenkarten fuer die moderne Welt.',
              style: AppTextStyles.smallText.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 ZCANTAG. Alle Rechte vorbehalten.',
              style: AppTextStyles.smallText.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schliessen'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Abmelden'),
        content: const Text('Moechten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Konto loeschen'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diese Aktion kann nicht rueckgaengig gemacht werden!',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              'Alle Ihre Daten werden unwiderruflich geloescht:',
              style: AppTextStyles.bodyRegular,
            ),
            const SizedBox(height: 8),
            Text('• Alle Visitenkarten', style: AppTextStyles.smallText),
            Text('• Alle Kontakte', style: AppTextStyles.smallText),
            Text('• Alle Analytics-Daten', style: AppTextStyles.smallText),
            Text('• Abonnement-Informationen', style: AppTextStyles.smallText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Konto loeschen'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS
// =============================================================================

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyRegular),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.smallText.copyWith(color: Colors.white54),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyRegular),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.smallText.copyWith(color: Colors.white54),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyRegular),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: AppColors.backgroundDarker,
        underline: const SizedBox(),
        style: AppTextStyles.bodyRegular,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  final String name;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(name, style: AppTextStyles.bodyRegular),
      subtitle: Text(
        email,
        style: AppTextStyles.smallText.copyWith(color: Colors.white54),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: AppColors.primary),
        onPressed: onEdit,
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({
    required this.plan,
    required this.onUpgrade,
  });

  final String plan;
  final VoidCallback onUpgrade;

  String _getPlanName() {
    switch (plan) {
      case 'free':
        return 'Free';
      case 'basic':
        return 'Basic';
      case 'premium':
        return 'Premium';
      case 'enterprise':
        return 'Enterprise';
      default:
        return 'Free';
    }
  }

  Color _getPlanColor() {
    switch (plan) {
      case 'free':
        return Colors.grey;
      case 'basic':
        return Colors.blue;
      case 'premium':
        return AppColors.primary;
      case 'enterprise':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getPlanColor().withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.star, color: _getPlanColor()),
      ),
      title: Row(
        children: [
          Text('Aktueller Plan: ', style: AppTextStyles.bodyRegular),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getPlanColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getPlanName(),
              style: AppTextStyles.smallText.copyWith(
                color: _getPlanColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        plan == 'enterprise'
            ? 'Sie haben den hoechsten Plan'
            : 'Upgraden fuer mehr Funktionen',
        style: AppTextStyles.smallText.copyWith(color: Colors.white54),
      ),
      trailing: plan != 'enterprise'
          ? ElevatedButton(
              onPressed: onUpgrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child:
                  const Text('Upgrade', style: TextStyle(color: Colors.black)),
            )
          : null,
    );
  }
}
