// =============================================================================
// CAMPAIGNS_LIST_SCREEN.DART
// =============================================================================
// Uebersicht aller Push-Kampagnen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/push_campaigns/domain/entities/push_campaign.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/push_campaign_provider.dart';

class CampaignsListScreen extends ConsumerStatefulWidget {
  const CampaignsListScreen({super.key});

  @override
  ConsumerState<CampaignsListScreen> createState() =>
      _CampaignsListScreenState();
}

class _CampaignsListScreenState extends ConsumerState<CampaignsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // TODO: Company ID aus Auth laden
      ref.read(campaignsProvider.notifier).loadCampaigns(
            companyId: 'mock-company-id',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final campaignsState = ref.watch(campaignsProvider);
    final filterStatus = ref.watch(campaignFilterProvider);

    return AdminShell(
      currentRoute: '/admin/campaigns',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Push-Kampagnen', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Erstellen und verwalten Sie Ihre Push-Benachrichtigungen',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/admin/campaigns/new'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.backgroundDark,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Neue Kampagne'),
                ),
              ],
            ),
          ),

          // Weekly Usage Banner
          if (campaignsState is CampaignsLoaded &&
              campaignsState.weeklyUsage != null)
            _buildWeeklyUsageBanner(campaignsState.weeklyUsage!),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildFilterChips(filterStatus),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _buildContent(campaignsState),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyUsageBanner(WeeklyUsage usage) {
    final Color bannerColor;
    final String message;

    if (usage.isUnlimited) {
      bannerColor = AppColors.success;
      message = 'Unbegrenzte Kampagnen (Enterprise)';
    } else if (usage.isLimitReached) {
      bannerColor = AppColors.error;
      message =
          'Woechentliches Limit erreicht (${usage.campaignsSent}/${usage.campaignsLimit})';
    } else if (usage.usagePercentage > 0.8) {
      bannerColor = Colors.orange;
      message =
          '${usage.remaining} von ${usage.campaignsLimit} Kampagnen diese Woche uebrig';
    } else {
      bannerColor = AppColors.primary;
      message =
          '${usage.remaining} von ${usage.campaignsLimit} Kampagnen diese Woche uebrig';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            usage.isLimitReached ? Icons.warning : Icons.campaign,
            color: bannerColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: AppTextStyles.smallText.copyWith(
              color: bannerColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!usage.isUnlimited) ...[
            const Spacer(),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: usage.usagePercentage,
                backgroundColor: bannerColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(bannerColor),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips(CampaignStatus? filterStatus) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text('Alle'),
          selected: filterStatus == null,
          onSelected: (_) {
            ref.read(campaignFilterProvider.notifier).state = null;
            ref.read(campaignsProvider.notifier).filterByStatus(null);
          },
        ),
        ...CampaignStatus.values.where((s) => s != CampaignStatus.failed).map(
              (status) => FilterChip(
                label: Text(status.displayName),
                selected: filterStatus == status,
                onSelected: (_) {
                  ref.read(campaignFilterProvider.notifier).state = status;
                  ref.read(campaignsProvider.notifier).filterByStatus(status);
                },
              ),
            ),
      ],
    );
  }

  Widget _buildContent(CampaignsState state) {
    return switch (state) {
      CampaignsInitial() => const Center(child: CircularProgressIndicator()),
      CampaignsLoading() => const Center(child: CircularProgressIndicator()),
      CampaignsError(:final message) => _buildError(message),
      CampaignsLoaded() => _buildCampaignsList(state),
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
              ref.read(campaignsProvider.notifier).loadCampaigns();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList(CampaignsLoaded state) {
    final campaigns = state.filteredCampaigns;

    if (campaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: AppColors.textWhite.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Kampagnen vorhanden',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Erstellen Sie Ihre erste Push-Kampagne',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/campaigns/new'),
              icon: const Icon(Icons.add),
              label: const Text('Kampagne erstellen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        return _CampaignCard(
          campaign: campaign,
          onTap: () => context.go('/admin/campaigns/${campaign.id}'),
          onSend: campaign.canSend
              ? () => _sendCampaign(campaign.id)
              : null,
          onCancel: campaign.canCancel
              ? () => _cancelCampaign(campaign.id)
              : null,
          onDelete: campaign.canEdit
              ? () => _deleteCampaign(campaign.id)
              : null,
        );
      },
    );
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
      await ref.read(campaignsProvider.notifier).sendCampaign(campaignId);
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
      await ref.read(campaignsProvider.notifier).cancelCampaign(campaignId);
    }
  }

  Future<void> _deleteCampaign(String campaignId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kampagne loeschen?'),
        content: const Text(
            'Diese Aktion kann nicht rueckgaengig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Loeschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(campaignsProvider.notifier).deleteCampaign(campaignId);
    }
  }
}

/// Campaign Card Widget
class _CampaignCard extends StatelessWidget {
  const _CampaignCard({
    required this.campaign,
    required this.onTap,
    this.onSend,
    this.onCancel,
    this.onDelete,
  });

  final PushCampaign campaign;
  final VoidCallback onTap;
  final VoidCallback? onSend;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Campaign Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                ),
              ),

              const SizedBox(width: 16),

              // Campaign Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            campaign.title,
                            style: AppTextStyles.bodyRegular.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campaign.body,
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: AppColors.textWhite.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          campaign.targetAudience.description,
                          style: AppTextStyles.smallText.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                        if (campaign.scheduledAt != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppColors.textWhite.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(campaign.scheduledAt!),
                            style: AppTextStyles.smallText.copyWith(
                              color: AppColors.textWhite.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (campaign.isABTest) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'A/B',
                              style: AppTextStyles.smallText.copyWith(
                                color: Colors.purple,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'send':
                      onSend?.call();
                    case 'cancel':
                      onCancel?.call();
                    case 'delete':
                      onDelete?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (onSend != null)
                    const PopupMenuItem(
                      value: 'send',
                      child: Row(
                        children: [
                          Icon(Icons.send, size: 20),
                          SizedBox(width: 8),
                          Text('Senden'),
                        ],
                      ),
                    ),
                  if (onCancel != null)
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 20),
                          SizedBox(width: 8),
                          Text('Abbrechen'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Loeschen',
                              style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        campaign.status.displayName,
        style: AppTextStyles.smallText.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (campaign.status) {
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

  IconData _getStatusIcon() {
    switch (campaign.status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
