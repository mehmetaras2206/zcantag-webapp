// =============================================================================
// SHARE_CARD_SCREEN.DART
// =============================================================================
// Screen zum Teilen einer Visitenkarte via Link, QR-Code oder E-Mail
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../providers/cards_provider.dart';

class ShareCardScreen extends ConsumerStatefulWidget {
  const ShareCardScreen({
    super.key,
    required this.cardId,
  });

  final String cardId;

  @override
  ConsumerState<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends ConsumerState<ShareCardScreen> {
  final _emailController = TextEditingController();
  bool _isSharing = false;
  String? _shareUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateShareLink();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _generateShareLink() async {
    setState(() {
      _isSharing = true;
      _errorMessage = null;
    });

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.shareCard(widget.cardId);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        setState(() {
          _shareUrl = result.data!.shareUrl;
          _isSharing = false;
        });
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Fehler beim Generieren des Links';
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _shareViaEmail() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte E-Mail-Adresse eingeben')),
      );
      return;
    }

    setState(() {
      _isSharing = true;
      _errorMessage = null;
    });

    final repository = ref.read(cardRepositoryProvider);
    final result = await repository.shareCard(
      widget.cardId,
      email: _emailController.text.trim(),
    );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Karte an ${_emailController.text} gesendet'),
            backgroundColor: AppColors.success,
          ),
        );
        _emailController.clear();
      } else {
        setState(() => _errorMessage = result.error);
      }
      setState(() => _isSharing = false);
    }
  }

  void _copyToClipboard() {
    if (_shareUrl == null) return;

    Clipboard.setData(ClipboardData(text: _shareUrl!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link in Zwischenablage kopiert'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(singleCardProvider(widget.cardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karte teilen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cards'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Preview Header
                if (cardState is SingleCardLoaded) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDarker,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              cardState.card.displayName.substring(0, 1),
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.backgroundDarker,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardState.card.displayName,
                                style: AppTextStyles.heading3,
                              ),
                              if (cardState.card.title != null)
                                Text(
                                  cardState.card.title!,
                                  style: AppTextStyles.bodyRegular.copyWith(
                                    color: AppColors.textWhite.withValues(alpha: 0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_errorMessage!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // QR Code Section
                _buildSection(
                  title: 'QR-Code',
                  icon: Icons.qr_code,
                  child: _isSharing || _shareUrl == null
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: _shareUrl!,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // Link Section
                _buildSection(
                  title: 'Link kopieren',
                  icon: Icons.link,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDarker,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _shareUrl ?? 'Wird generiert...',
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: _shareUrl != null ? _copyToClipboard : null,
                        icon: const Icon(Icons.copy),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.backgroundDarker,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Email Section
                _buildSection(
                  title: 'Per E-Mail teilen',
                  icon: Icons.email_outlined,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-Mail-Adresse',
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: 'empfaenger@beispiel.de',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _shareViaEmail,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          label: const Text('Senden'),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Der Link ist dauerhaft gueltig. Empfaenger koennen Ihre Kontaktdaten speichern und Sie werden als neuer Kontakt hinzugefuegt.',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
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
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.heading3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
