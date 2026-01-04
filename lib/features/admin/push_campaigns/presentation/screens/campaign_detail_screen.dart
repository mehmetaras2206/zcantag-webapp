// =============================================================================
// CAMPAIGN_DETAIL_SCREEN.DART
// =============================================================================
// Detail-Ansicht einer Push-Kampagne mit Analytics
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/push_campaigns/domain/entities/push_campaign.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/push_campaign_provider.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<CampaignDetailScreen> createState() =>
      _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(campaignDetailProvider.notifier).loadCampaign(widget.campaignId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(campaignDetailProvider);

    return AdminShell(
      currentRoute: '/admin/campaigns',
      child: _buildContent(detailState),
    );
  }

  Widget _buildContent(CampaignDetailState state) {
    return switch (state) {
      CampaignDetailInitial() =>
        const Center(child: CircularProgressIndicator()),
      CampaignDetailLoading() =>
        const Center(child: CircularProgressIndicator()),
      CampaignDetailError(:final message) => _buildError(message),
      CampaignDetailLoaded(:final campaign, :final analytics) =>
        _buildDetail(campaign, analytics),
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
          Text(message),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(campaignDetailProvider.notifier)
                  .loadCampaign(widget.campaignId);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(PushCampaign campaign, CampaignAnalytics? analytics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/admin/campaigns'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.title, style: AppTextStyles.heading1),
                    const SizedBox(height: 4),
                    _buildStatusBadge(campaign.status),
                  ],
                ),
              ),
              if (campaign.canEdit)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      context.go('/admin/campaigns/${campaign.id}/edit'),
                  tooltip: 'Bearbeiten',
                ),
              if (campaign.canSend)
                ElevatedButton.icon(
                  onPressed: () => _sendCampaign(campaign.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Senden'),
                ),
              if (campaign.canCancel) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _cancelCampaign(campaign.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Abbrechen'),
                ),
              ],
            ],
          ),

          const SizedBox(height: 32),

          // Content
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildCampaignInfo(campaign)),
                    const SizedBox(width: 24),
                    if (analytics != null)
                      Expanded(child: _buildAnalytics(analytics)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildCampaignInfo(campaign),
                  if (analytics != null) ...[
                    const SizedBox(height: 24),
                    _buildAnalytics(analytics),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(CampaignStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status.displayName,
            style: AppTextStyles.smallText.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignInfo(PushCampaign campaign) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kampagnen-Details', style: AppTextStyles.heading3),
          const SizedBox(height: 24),

          // Message Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: AppTextStyles.bodyRegular.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(campaign.body),
                if (campaign.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      campaign.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: AppColors.backgroundDarker,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Details
          _buildInfoRow('Zielgruppe', campaign.targetAudience.description),
          if (campaign.actionUrl != null)
            _buildInfoRow('Aktion-Link', campaign.actionUrl!),
          _buildInfoRow('Erstellt',
              '${campaign.createdAt.day}.${campaign.createdAt.month}.${campaign.createdAt.year}'),
          if (campaign.scheduledAt != null)
            _buildInfoRow('Geplant fuer',
                '${campaign.scheduledAt!.day}.${campaign.scheduledAt!.month}.${campaign.scheduledAt!.year} ${campaign.scheduledAt!.hour}:${campaign.scheduledAt!.minute.toString().padLeft(2, '0')}'),
          if (campaign.sentAt != null)
            _buildInfoRow('Gesendet',
                '${campaign.sentAt!.day}.${campaign.sentAt!.month}.${campaign.sentAt!.year} ${campaign.sentAt!.hour}:${campaign.sentAt!.minute.toString().padLeft(2, '0')}'),

          // A/B Test Info
          if (campaign.isABTest) ...[
            const SizedBox(height: 24),
            Text('A/B-Test Varianten', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            ...campaign.abTestVariants!.map((variant) => _buildVariantCard(variant)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantCard(ABTestVariant variant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarker,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              variant.variantId,
              style: AppTextStyles.smallText.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.title, style: AppTextStyles.smallText),
                Text(
                  '${variant.percentage}% der Empfaenger',
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(CampaignAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Analytics', style: AppTextStyles.heading3),
          const SizedBox(height: 24),

          // KPI Cards
          _buildKpiCard('Gesendet', analytics.totalSent.toString(),
              Icons.send, Colors.blue),
          const SizedBox(height: 12),
          _buildKpiCard(
              'Zugestellt',
              '${analytics.delivered} (${(analytics.deliveryRate * 100).toStringAsFixed(1)}%)',
              Icons.check_circle,
              AppColors.success),
          const SizedBox(height: 12),
          _buildKpiCard(
              'Geoeffnet',
              '${analytics.opened} (${(analytics.openRate * 100).toStringAsFixed(1)}%)',
              Icons.visibility,
              Colors.orange),
          const SizedBox(height: 12),
          _buildKpiCard(
              'Geklickt',
              '${analytics.clicked} (${(analytics.clickRate * 100).toStringAsFixed(1)}%)',
              Icons.touch_app,
              Colors.purple),

          if (analytics.failed > 0) ...[
            const SizedBox(height: 12),
            _buildKpiCard(
                'Fehlgeschlagen',
                '${analytics.failed} (${(analytics.failureRate * 100).toStringAsFixed(1)}%)',
                Icons.error,
                AppColors.error),
          ],

          // Conversion Funnel Visual
          const SizedBox(height: 24),
          Text('Conversion Funnel', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _buildFunnelVisualization(analytics),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: AppTextStyles.bodyRegular.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelVisualization(CampaignAnalytics analytics) {
    final maxValue = analytics.totalSent.toDouble();

    return Column(
      children: [
        _buildFunnelBar('Gesendet', analytics.totalSent, maxValue, Colors.blue),
        const SizedBox(height: 8),
        _buildFunnelBar(
            'Zugestellt', analytics.delivered, maxValue, Colors.green),
        const SizedBox(height: 8),
        _buildFunnelBar('Geoeffnet', analytics.opened, maxValue, Colors.orange),
        const SizedBox(height: 8),
        _buildFunnelBar('Geklickt', analytics.clicked, maxValue, Colors.purple),
      ],
    );
  }

  Widget _buildFunnelBar(
      String label, int value, double maxValue, Color color) {
    final percentage = maxValue > 0 ? value / maxValue : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value.toString(),
              style: AppTextStyles.smallText.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.backgroundDarker,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Colors.grey;
      case CampaignStatus.scheduled:
        return Colors.blue;
      case CampaignStatus.sending:
        return Colors.orange;
      case CampaignStatus.sent:
        return AppColors.success;
      case CampaignStatus.cancelled:
        return AppColors.error;
      case CampaignStatus.failed:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Icons.edit;
      case CampaignStatus.scheduled:
        return Icons.schedule;
      case CampaignStatus.sending:
        return Icons.send;
      case CampaignStatus.sent:
        return Icons.check_circle;
      case CampaignStatus.cancelled:
        return Icons.cancel;
      case CampaignStatus.failed:
        return Icons.error;
    }
  }

  Future<void> _sendCampaign(String campaignId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kampagne senden?'),
        content: const Text(
            'Die Kampagne wird an alle ausgewaehlten Empfaenger gesendet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Senden'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(campaignDetailProvider.notifier).sendCampaign(campaignId);
    }
  }

  Future<void> _cancelCampaign(String campaignId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kampagne abbrechen?'),
        content: const Text('Die geplante Kampagne wird abgebrochen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zurueck'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(campaignDetailProvider.notifier)
          .cancelCampaign(campaignId);
    }
  }
}
