// =============================================================================
// CONTACTS_SCREEN.DART
// =============================================================================
// Kontaktliste mit Suche, Filter und Plan-Restriktionen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../../shared/features/contacts/domain/entities/contact.dart';
import '../providers/contacts_provider.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(contactsProvider.notifier).loadContacts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsProvider);

    // Plan-Check: Free User zeigt App-Download Prompt
    if (contactsState is ContactsLoaded && contactsState.stats.planType == 'free') {
      return _buildFreeUserPrompt(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Kontakte suchen...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  ref.read(contactsProvider.notifier).search(value);
                },
              )
            : const Text('Kontakte'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  ref.read(contactsProvider.notifier).search('');
                }
              });
            },
          ),
          if (contactsState is ContactsLoaded) ...[
            IconButton(
              icon: Icon(
                contactsState.favoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    contactsState.favoritesOnly ? AppColors.error : null,
              ),
              onPressed: () {
                ref.read(contactsProvider.notifier).toggleFavoritesFilter();
              },
              tooltip: 'Favoriten',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(contactsProvider.notifier).refresh(),
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: _buildBody(contactsState),
    );
  }

  Widget _buildBody(ContactsState state) {
    return switch (state) {
      ContactsInitial() => const Center(child: CircularProgressIndicator()),
      ContactsLoading() => const Center(child: CircularProgressIndicator()),
      ContactsError(:final message) => _buildError(message),
      ContactsLoaded(:final contacts, :final stats) =>
        _buildContactsList(contacts, stats),
    };
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Fehler beim Laden', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(contactsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(List<Contact> contacts, ContactStats stats) {
    return Column(
      children: [
        // Stats Header
        _buildStatsHeader(stats),

        // Liste
        Expanded(
          child: contacts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(contactsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return _ContactTile(
                        contact: contact,
                        onTap: () => context.push('/contacts/${contact.id}'),
                        onFavoriteToggle: () {
                          ref
                              .read(contactsProvider.notifier)
                              .toggleFavorite(contact.id);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(ContactStats stats) {
    final warningLevel = stats.warningLevel;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warningLevel == ContactWarningLevel.critical
              ? AppColors.error
              : warningLevel == ContactWarningLevel.warning
                  ? Colors.orange
                  : AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: AppColors.primary),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.totalContacts} von ${stats.maxContacts} Kontakten',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 4),
                    if (stats.remaining != null && stats.remaining! > 0)
                      Text(
                        '${stats.remaining} verfuegbar',
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.7),
                        ),
                      ),
                    if (stats.limitReached)
                      Text(
                        'Limit erreicht - Upgrade erforderlich',
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                  ],
                ),
              ),

              // Progress
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: stats.usagePercent,
                      backgroundColor: AppColors.backgroundDarker,
                      color: warningLevel == ContactWarningLevel.critical
                          ? AppColors.error
                          : warningLevel == ContactWarningLevel.warning
                              ? Colors.orange
                              : AppColors.primary,
                      strokeWidth: 6,
                    ),
                    Text(
                      '${(stats.usagePercent * 100).round()}%',
                      style: AppTextStyles.smallText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Eingefrorene Kontakte Banner
          if (stats.frozenContacts > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.ac_unit, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${stats.frozenContacts} eingefrorene Kontakte',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Upgraden Sie, um auf alle Kontakte zuzugreifen',
                          style: AppTextStyles.smallText.copyWith(
                            color: Colors.blue.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/subscription'),
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.textWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text('Keine Kontakte', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            'Teilen Sie Ihre Visitenkarte, um Kontakte zu sammeln',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/cards'),
            icon: const Icon(Icons.credit_card),
            label: const Text('Zu meinen Karten'),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeUserPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kontakte')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.phone_android,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Kontakte in der App verwalten',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Im Free-Plan sind Kontakte nur in der mobilen App verfuegbar. '
                'Laden Sie die ZCANTAG App herunter oder upgraden Sie Ihren Plan.',
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Download Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DownloadButton(
                    icon: Icons.android,
                    label: 'Google Play',
                    onTap: () => _openStore('android'),
                  ),
                  const SizedBox(width: 16),
                  _DownloadButton(
                    icon: Icons.apple,
                    label: 'App Store',
                    onTap: () => _openStore('ios'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'oder',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Upgrade Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/subscription'),
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Plan upgraden'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(String platform) async {
    final url = platform == 'android'
        ? 'https://play.google.com/store/apps/details?id=de.zcantag.app'
        : 'https://apps.apple.com/app/zcantag/id123456789';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Kontakt-Listenelement
class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final isFrozen = contact.isFrozen;

    return Opacity(
      opacity: isFrozen ? 0.5 : 1.0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: isFrozen ? Colors.grey : AppColors.primary,
              child: Text(
                contact.initials,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.backgroundDarker,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isFrozen)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.ac_unit,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.displayName,
                style: AppTextStyles.bodyRegular.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isFrozen ? Colors.grey : null,
                ),
              ),
            ),
            if (isFrozen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Eingefroren',
                  style: AppTextStyles.smallText.copyWith(
                    color: Colors.blue,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: contact.company != null || contact.title != null
            ? Text(
                [contact.title, contact.company].whereType<String>().join(' - '),
                style: AppTextStyles.smallText.copyWith(
                  color: isFrozen
                      ? Colors.grey.withValues(alpha: 0.7)
                      : AppColors.textWhite.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tags
            if (contact.hasTags && !isFrozen)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${contact.tags.length}',
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Favorit (nur fuer nicht eingefrorene)
            if (!isFrozen)
              IconButton(
                icon: Icon(
                  contact.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: contact.isFavorite ? AppColors.error : null,
                ),
                onPressed: onFavoriteToggle,
              )
            else
              const Icon(Icons.lock, color: Colors.grey, size: 20),
          ],
        ),
        onTap: isFrozen ? () => _showFrozenDialog(context) : onTap,
      ),
    );
  }

  void _showFrozenDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.ac_unit, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text('Eingefrorener Kontakt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dieser Kontakt wurde eingefroren, da Ihr Kontakt-Limit erreicht wurde.',
              style: AppTextStyles.bodyRegular,
            ),
            const SizedBox(height: 16),
            Text(
              'Um auf diesen Kontakt zugreifen zu koennen:',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _FrozenInfoItem(
              icon: Icons.upgrade,
              text: 'Upgraden Sie Ihren Plan',
            ),
            _FrozenInfoItem(
              icon: Icons.delete_outline,
              text: 'Loeschen Sie andere Kontakte',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schliessen'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription');
            },
            icon: const Icon(Icons.upgrade, color: Colors.black),
            label: const Text('Upgrade', style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FrozenInfoItem extends StatelessWidget {
  const _FrozenInfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.smallText),
        ],
      ),
    );
  }
}

/// Download Button
class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
