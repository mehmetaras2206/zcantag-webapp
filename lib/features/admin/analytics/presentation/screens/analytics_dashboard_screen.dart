// =============================================================================
// ANALYTICS_DASHBOARD_SCREEN.DART
// =============================================================================
// Analytics Dashboard mit Statistiken und Charts
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/analytics/domain/entities/analytics.dart';
import '../../../presentation/layouts/admin_shell.dart';
import '../providers/analytics_provider.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // TODO: Company ID aus Auth laden
      ref.read(analyticsProvider.notifier).loadAnalytics('mock-company-id');
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);

    return AdminShell(
      currentRoute: '/admin/analytics',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analytics', style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(
                      'Uebersicht Ihrer Visitenkarten-Performance',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                // Date Range Selector
                if (analyticsState is AnalyticsLoaded)
                  _buildDateRangeSelector(analyticsState),
              ],
            ),

            const SizedBox(height: 32),

            // Content
            _buildContent(analyticsState),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(AnalyticsLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButton<DateRangePreset>(
        value: state.preset,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: DateRangePreset.values
            .where((p) => p != DateRangePreset.custom)
            .map((preset) => DropdownMenuItem(
                  value: preset,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(preset.displayName),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (preset) {
          if (preset != null) {
            ref.read(analyticsProvider.notifier).changeDateRange(
                  'mock-company-id',
                  preset,
                );
          }
        },
      ),
    );
  }

  Widget _buildContent(AnalyticsState state) {
    return switch (state) {
      AnalyticsInitial() => const Center(child: CircularProgressIndicator()),
      AnalyticsLoading() => const Center(child: CircularProgressIndicator()),
      AnalyticsError(:final message) => _buildError(message),
      AnalyticsLoaded(:final companyAnalytics) =>
        _buildDashboard(companyAnalytics),
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
                  .read(analyticsProvider.notifier)
                  .loadAnalytics('mock-company-id');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(CompanyAnalytics analytics) {
    return Column(
      children: [
        // KPI Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1200
                ? 4
                : constraints.maxWidth > 800
                    ? 2
                    : 1;

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildKpiCard(
                  icon: Icons.visibility,
                  title: 'Aufrufe',
                  value: _formatNumber(analytics.totalViews),
                  color: Colors.blue,
                ),
                _buildKpiCard(
                  icon: Icons.contacts,
                  title: 'Kontakte',
                  value: _formatNumber(analytics.totalContacts),
                  color: Colors.green,
                ),
                _buildKpiCard(
                  icon: Icons.touch_app,
                  title: 'Klicks',
                  value: _formatNumber(analytics.totalClicks),
                  color: Colors.orange,
                ),
                _buildKpiCard(
                  icon: Icons.trending_up,
                  title: 'Conversion',
                  value: '${(analytics.avgConversionRate * 100).toStringAsFixed(1)}%',
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Charts Row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildViewsTrendChart(analytics)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTopCardsSection(analytics)),
                ],
              );
            }
            return Column(
              children: [
                _buildViewsTrendChart(analytics),
                const SizedBox(height: 24),
                _buildTopCardsSection(analytics),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Cards Overview
        _buildCardsOverview(analytics),
      ],
    );
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading1.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.textWhite.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewsTrendChart(CompanyAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aufrufe im Zeitverlauf', style: AppTextStyles.heading3),
          const SizedBox(height: 24),

          // Placeholder Chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: AppColors.textWhite.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chart wird geladen...',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '(Syncfusion Charts in Phase 9)',
                    style: AppTextStyles.smallText.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.3),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCardsSection(CompanyAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Karten', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          if (analytics.topCards.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Noch keine Daten vorhanden',
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...analytics.topCards.take(5).map((card) => _buildTopCardItem(card)),
        ],
      ),
    );
  }

  Widget _buildTopCardItem(TopCard card) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(8),
            ),
            child: card.thumbnailUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      card.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.credit_card, size: 20),
                    ),
                  )
                : const Icon(Icons.credit_card, size: 20),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.cardName,
                  style: AppTextStyles.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${card.views} Views',
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Conversion Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(card.conversionRate * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsOverview(CompanyAnalytics analytics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Karten-Uebersicht', style: AppTextStyles.heading3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${analytics.activeCards} / ${analytics.totalCards} aktiv',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          LinearProgressIndicator(
            value: analytics.activeCardPercentage,
            backgroundColor: AppColors.backgroundDarker,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),

          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  label: 'Durchschn. Views/Karte',
                  value: analytics.totalCards > 0
                      ? (analytics.totalViews / analytics.totalCards)
                          .toStringAsFixed(0)
                      : '0',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStat(
                  label: 'Durchschn. Kontakte/Karte',
                  value: analytics.totalCards > 0
                      ? (analytics.totalContacts / analytics.totalCards)
                          .toStringAsFixed(1)
                      : '0',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.heading2,
        ),
        Text(
          label,
          style: AppTextStyles.smallText.copyWith(
            color: AppColors.textWhite.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
