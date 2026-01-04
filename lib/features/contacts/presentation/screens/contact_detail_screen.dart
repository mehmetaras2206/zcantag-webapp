// =============================================================================
// CONTACT_DETAIL_SCREEN.DART
// =============================================================================
// Detailansicht eines Kontakts mit Aktionen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../../shared/features/contacts/domain/entities/contact.dart';
import '../providers/contacts_provider.dart';

class ContactDetailScreen extends ConsumerWidget {
  const ContactDetailScreen({
    super.key,
    required this.contactId,
  });

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactState = ref.watch(singleContactProvider(contactId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/contacts'),
        ),
        actions: [
          if (contactState is SingleContactLoaded) ...[
            IconButton(
              icon: Icon(
                contactState.contact.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    contactState.contact.isFavorite ? AppColors.error : null,
              ),
              onPressed: () {
                ref.read(contactsProvider.notifier).toggleFavorite(contactId);
                ref.invalidate(singleContactProvider(contactId));
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Loeschen'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _buildBody(context, contactState),
    );
  }

  Widget _buildBody(BuildContext context, SingleContactState state) {
    return switch (state) {
      SingleContactInitial() =>
        const Center(child: CircularProgressIndicator()),
      SingleContactLoading() =>
        const Center(child: CircularProgressIndicator()),
      SingleContactError(:final message) => _buildError(context, message),
      SingleContactLoaded(:final contact) => _buildContent(context, contact),
    };
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Fehler', style: AppTextStyles.heading2),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/contacts'),
            child: const Text('Zurueck zur Liste'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Contact contact) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(contact),

                const SizedBox(height: 32),

                // Quick Actions
                _buildQuickActions(context, contact),

                const SizedBox(height: 32),

                // Kontaktdaten
                if (contact.hasContactInfo) ...[
                  _buildSection(
                    title: 'Kontakt',
                    children: [
                      if (contact.email != null)
                        _buildInfoTile(
                          icon: Icons.email_outlined,
                          title: 'E-Mail',
                          value: contact.email!,
                          onTap: () => _launchUrl('mailto:${contact.email}'),
                        ),
                      if (contact.phone != null)
                        _buildInfoTile(
                          icon: Icons.phone_outlined,
                          title: 'Telefon',
                          value: contact.phone!,
                          onTap: () => _launchUrl('tel:${contact.phone}'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Berufliche Daten
                if (contact.company != null || contact.title != null) ...[
                  _buildSection(
                    title: 'Beruflich',
                    children: [
                      if (contact.title != null)
                        _buildInfoTile(
                          icon: Icons.work_outline,
                          title: 'Position',
                          value: contact.title!,
                        ),
                      if (contact.company != null)
                        _buildInfoTile(
                          icon: Icons.business_outlined,
                          title: 'Unternehmen',
                          value: contact.company!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (contact.hasTags) ...[
                  _buildSection(
                    title: 'Tags',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: contact.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            labelStyle: AppTextStyles.smallText.copyWith(
                              color: AppColors.primary,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Notizen
                if (contact.notes != null && contact.notes!.isNotEmpty) ...[
                  _buildSection(
                    title: 'Notizen',
                    children: [
                      Text(
                        contact.notes!,
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Metadata
                _buildSection(
                  title: 'Information',
                  children: [
                    _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Erstellt am',
                      value: _formatDate(contact.createdAt),
                    ),
                    if (contact.updatedAt != null)
                      _buildInfoTile(
                        icon: Icons.update_outlined,
                        title: 'Aktualisiert am',
                        value: _formatDate(contact.updatedAt!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Contact contact) {
    return Center(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                contact.initials,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.backgroundDarker,
                  fontSize: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            contact.displayName,
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),

          // Subtitle
          if (contact.title != null || contact.company != null) ...[
            const SizedBox(height: 4),
            Text(
              [contact.title, contact.company].whereType<String>().join(' - '),
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Favorit Badge
          if (contact.isFavorite) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: AppColors.error, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Favorit',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Contact contact) {
    final actions = <Widget>[];

    if (contact.phone != null) {
      actions.add(_QuickActionButton(
        icon: Icons.phone,
        label: 'Anrufen',
        onTap: () => _launchUrl('tel:${contact.phone}'),
      ));
    }

    if (contact.email != null) {
      actions.add(_QuickActionButton(
        icon: Icons.email,
        label: 'E-Mail',
        onTap: () => _launchUrl('mailto:${contact.email}'),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions
          .map((action) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: action,
              ))
          .toList(),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textWhite.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(value, style: AppTextStyles.bodyRegular),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textWhite.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'delete') {
      _showDeleteDialog(context, ref);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontakt loeschen?'),
        content: const Text(
          'Dieser Kontakt wird unwiderruflich geloescht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(contactsProvider.notifier)
                  .deleteContact(contactId);

              if (success && context.mounted) {
                context.go('/contacts');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button
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
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
