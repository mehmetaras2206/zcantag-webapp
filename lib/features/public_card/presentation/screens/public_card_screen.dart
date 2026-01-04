// =============================================================================
// PUBLIC_CARD_SCREEN.DART
// =============================================================================
// Oeffentliche Ansicht einer geteilten Visitenkarte (ohne Login erforderlich)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../../shared/features/cards/domain/entities/card.dart' as domain;
import '../../../../shared/features/cards/domain/entities/social_links.dart';
import '../../../cards/presentation/providers/cards_provider.dart';

class PublicCardScreen extends ConsumerWidget {
  const PublicCardScreen({
    super.key,
    required this.slug,
  });

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardState = ref.watch(publicCardProvider(slug));

    return Scaffold(
      body: _buildBody(context, cardState),
    );
  }

  Widget _buildBody(BuildContext context, SingleCardState state) {
    return switch (state) {
      SingleCardInitial() => const Center(child: CircularProgressIndicator()),
      SingleCardLoading() => const Center(child: CircularProgressIndicator()),
      SingleCardError(:final message) => _buildError(context, message),
      SingleCardLoaded(:final card) => _buildCard(context, card),
    };
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 80,
            color: AppColors.textWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Karte nicht gefunden',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, domain.Card card) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Header mit Profilbild
                _buildHeader(card),

                const SizedBox(height: 32),

                // Kontakt-Aktionen
                _buildQuickActions(context, card),

                const SizedBox(height: 24),

                // Kontaktdaten
                if (_hasContactInfo(card)) ...[
                  _buildContactSection(context, card),
                  const SizedBox(height: 24),
                ],

                // Adresse
                if (card.fullAddress != null) ...[
                  _buildAddressSection(context, card),
                  const SizedBox(height: 24),
                ],

                // Social Media
                if (card.socialLinks.isNotEmpty) ...[
                  _buildSocialSection(context, card),
                  const SizedBox(height: 24),
                ],

                // Kontakt speichern Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveContact(context, card),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Kontakt speichern'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered by ',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      'ZCANTAG',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(domain.Card card) {
    return Column(
      children: [
        // Profilbild
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: _getPrimaryColor(card),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getPrimaryColor(card).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: card.profileImageUrl != null
              ? ClipOval(
                  child: Image.network(
                    card.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(card),
                  ),
                )
              : _buildInitials(card),
        ),
        const SizedBox(height: 24),

        // Name
        Text(
          card.displayName,
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),

        // Titel / Position
        if (card.title != null) ...[
          const SizedBox(height: 4),
          Text(
            card.title!,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // Unternehmen
        if (card.companyName != null) ...[
          const SizedBox(height: 4),
          Text(
            card.companyName!,
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildInitials(domain.Card card) {
    final initials = card.displayName
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.heading1.copyWith(
          color: AppColors.backgroundDarker,
          fontSize: 40,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, domain.Card card) {
    final actions = <Widget>[];

    if (card.phone != null) {
      actions.add(_QuickActionButton(
        icon: Icons.phone,
        label: 'Anrufen',
        onTap: () => _launchUrl('tel:${card.phone}'),
      ));
    }

    if (card.email != null) {
      actions.add(_QuickActionButton(
        icon: Icons.email,
        label: 'E-Mail',
        onTap: () => _launchUrl('mailto:${card.email}'),
      ));
    }

    if (card.website != null) {
      actions.add(_QuickActionButton(
        icon: Icons.language,
        label: 'Website',
        onTap: () => _launchUrl(card.website!),
      ));
    }

    if (card.fullAddress != null) {
      actions.add(_QuickActionButton(
        icon: Icons.location_on,
        label: 'Karte',
        onTap: () => _openMaps(card.fullAddress!),
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

  bool _hasContactInfo(domain.Card card) {
    return card.email != null || card.phone != null || card.mobile != null;
  }

  Widget _buildContactSection(BuildContext context, domain.Card card) {
    return _buildSection(
      title: 'Kontakt',
      children: [
        if (card.email != null)
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'E-Mail',
            value: card.email!,
            onTap: () => _launchUrl('mailto:${card.email}'),
          ),
        if (card.phone != null)
          _buildInfoTile(
            icon: Icons.phone_outlined,
            title: 'Telefon',
            value: card.phone!,
            onTap: () => _launchUrl('tel:${card.phone}'),
          ),
        if (card.mobile != null)
          _buildInfoTile(
            icon: Icons.smartphone_outlined,
            title: 'Mobil',
            value: card.mobile!,
            onTap: () => _launchUrl('tel:${card.mobile}'),
          ),
        if (card.website != null)
          _buildInfoTile(
            icon: Icons.language_outlined,
            title: 'Website',
            value: card.website!,
            onTap: () => _launchUrl(card.website!),
          ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context, domain.Card card) {
    return _buildSection(
      title: 'Adresse',
      children: [
        _buildInfoTile(
          icon: Icons.location_on_outlined,
          title: 'Standort',
          value: card.fullAddress!,
          onTap: () => _openMaps(card.fullAddress!),
        ),
      ],
    );
  }

  Widget _buildSocialSection(BuildContext context, domain.Card card) {
    return _buildSection(
      title: 'Social Media',
      children: card.socialLinks.links.map((link) {
        return _buildInfoTile(
          icon: _getSocialIcon(link.platform),
          title: link.platform.displayName,
          value: link.url,
          onTap: () => _launchUrl(link.url),
        );
      }).toList(),
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
                  Text(
                    value,
                    style: AppTextStyles.bodyRegular,
                  ),
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

  Color _getPrimaryColor(domain.Card card) {
    if (card.brandColorPrimary != null) {
      try {
        final colorValue = int.parse(
          card.brandColorPrimary!.replaceFirst('#', 'FF'),
          radix: 16,
        );
        return Color(colorValue);
      } catch (_) {}
    }
    return AppColors.primary;
  }

  IconData _getSocialIcon(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.linkedin:
        return Icons.work;
      case SocialPlatform.instagram:
        return Icons.camera_alt;
      case SocialPlatform.facebook:
        return Icons.facebook;
      case SocialPlatform.twitter:
        return Icons.alternate_email;
      case SocialPlatform.xing:
        return Icons.work_outline;
      case SocialPlatform.youtube:
        return Icons.play_circle;
      case SocialPlatform.tiktok:
        return Icons.music_note;
      case SocialPlatform.website:
        return Icons.language;
      case SocialPlatform.github:
        return Icons.code;
      case SocialPlatform.whatsapp:
        return Icons.chat;
      case SocialPlatform.telegram:
        return Icons.send;
      case SocialPlatform.other:
        return Icons.link;
    }
  }

  Future<void> _launchUrl(String url) async {
    var uri = Uri.tryParse(url);
    if (uri == null) return;

    // Fuege https:// hinzu wenn kein Schema vorhanden
    if (!uri.hasScheme && !url.startsWith('mailto:') && !url.startsWith('tel:')) {
      uri = Uri.parse('https://$url');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    await _launchUrl(mapsUrl);
  }

  void _saveContact(BuildContext context, domain.Card card) {
    // TODO: vCard generieren und Download anbieten
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kontakt wird gespeichert...'),
        backgroundColor: AppColors.success,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
