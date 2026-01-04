// =============================================================================
// CONVERSION_FUNNEL_SCREEN.DART
// =============================================================================
// Enterprise Feature: Conversion Funnel Visualization
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../../../shared/features/analytics/domain/entities/analytics.dart';

// =============================================================================
// STATE
// =============================================================================

class ConversionFunnelState {
  const ConversionFunnelState({
    this.funnel,
    this.isLoading = false,
    this.error,
    this.selectedPeriod = 'last_30_days',
    this.comparisonFunnel,
    this.showComparison = false,
  });

  final ConversionFunnel? funnel;
  final bool isLoading;
  final String? error;
  final String selectedPeriod;
  final ConversionFunnel? comparisonFunnel;
  final bool showComparison;

  ConversionFunnelState copyWith({
    ConversionFunnel? funnel,
    bool? isLoading,
    String? error,
    String? selectedPeriod,
    ConversionFunnel? comparisonFunnel,
    bool? showComparison,
  }) {
    return ConversionFunnelState(
      funnel: funnel ?? this.funnel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      comparisonFunnel: comparisonFunnel ?? this.comparisonFunnel,
      showComparison: showComparison ?? this.showComparison,
    );
  }
}

// =============================================================================
// NOTIFIER
// =============================================================================

class ConversionFunnelNotifier extends StateNotifier<ConversionFunnelState> {
  ConversionFunnelNotifier() : super(const ConversionFunnelState());

  void loadFunnel(String companyId) {
    state = state.copyWith(isLoading: true);

    // Mock data - in production, this would call the API
    Future.delayed(const Duration(milliseconds: 800), () {
      final funnel = ConversionFunnel(
        totalViews: 12500,
        profileViews: 8750,
        contactClicks: 4200,
        contactsSaved: 2100,
        followUps: 840,
      );

      final comparisonFunnel = ConversionFunnel(
        totalViews: 10200,
        profileViews: 6800,
        contactClicks: 3100,
        contactsSaved: 1550,
        followUps: 620,
      );

      state = state.copyWith(
        funnel: funnel,
        comparisonFunnel: comparisonFunnel,
        isLoading: false,
      );
    });
  }

  void setPeriod(String period) {
    state = state.copyWith(selectedPeriod: period, isLoading: true);
    // Reload with new period
    Future.delayed(const Duration(milliseconds: 500), () {
      state = state.copyWith(isLoading: false);
    });
  }

  void toggleComparison(bool show) {
    state = state.copyWith(showComparison: show);
  }
}

final conversionFunnelProvider =
    StateNotifierProvider<ConversionFunnelNotifier, ConversionFunnelState>(
  (ref) => ConversionFunnelNotifier(),
);

// =============================================================================
// SCREEN
// =============================================================================

class ConversionFunnelScreen extends ConsumerStatefulWidget {
  const ConversionFunnelScreen({super.key, required this.companyId});

  final String companyId;

  @override
  ConsumerState<ConversionFunnelScreen> createState() =>
      _ConversionFunnelScreenState();
}

class _ConversionFunnelScreenState
    extends ConsumerState<ConversionFunnelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversionFunnelProvider.notifier).loadFunnel(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversionFunnelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Row(
          children: [
            Text('Conversion Funnel', style: AppTextStyles.heading2),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ENTERPRISE',
                style: AppTextStyles.smallText.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Zeitraum-Auswahl
          PopupMenuButton<String>(
            initialValue: state.selectedPeriod,
            onSelected: (value) {
              ref.read(conversionFunnelProvider.notifier).setPeriod(value);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundDarker,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(_getPeriodLabel(state.selectedPeriod)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            itemBuilder: (context) => [
              _buildPeriodItem('last_7_days', 'Letzte 7 Tage'),
              _buildPeriodItem('last_30_days', 'Letzte 30 Tage'),
              _buildPeriodItem('last_90_days', 'Letzte 90 Tage'),
              _buildPeriodItem('this_year', 'Dieses Jahr'),
              _buildPeriodItem('all_time', 'Alle Zeit'),
            ],
          ),
          const SizedBox(width: 8),
          // Vergleichs-Toggle
          TextButton.icon(
            onPressed: () {
              ref
                  .read(conversionFunnelProvider.notifier)
                  .toggleComparison(!state.showComparison);
            },
            icon: Icon(
              state.showComparison ? Icons.compare : Icons.compare_outlined,
              color: state.showComparison ? AppColors.primary : Colors.white70,
            ),
            label: Text(
              'Vergleichen',
              style: TextStyle(
                color: state.showComparison ? AppColors.primary : Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.funnel == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Uebersicht KPIs
                      _buildKPIRow(state),
                      const SizedBox(height: 32),

                      // Hauptfunnel
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Funnel Visualisierung
                          Expanded(
                            flex: 2,
                            child: _buildFunnelVisualization(
                              state.funnel!,
                              state.showComparison
                                  ? state.comparisonFunnel
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Statistiken
                          Expanded(
                            child: _buildFunnelStats(
                              state.funnel!,
                              state.showComparison
                                  ? state.comparisonFunnel
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Drop-Off Analyse
                      _buildDropOffAnalysis(state.funnel!),

                      const SizedBox(height: 32),

                      // Optimierungsvorschlaege
                      _buildOptimizationSuggestions(state.funnel!),
                    ],
                  ),
                ),
    );
  }

  PopupMenuItem<String> _buildPeriodItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(label),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'last_7_days':
        return 'Letzte 7 Tage';
      case 'last_30_days':
        return 'Letzte 30 Tage';
      case 'last_90_days':
        return 'Letzte 90 Tage';
      case 'this_year':
        return 'Dieses Jahr';
      case 'all_time':
        return 'Alle Zeit';
      default:
        return period;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Funnel-Daten verfuegbar',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sobald Besucher mit Ihren Karten interagieren,\nwerden hier die Conversion-Daten angezeigt.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyRegular.copyWith(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIRow(ConversionFunnelState state) {
    final funnel = state.funnel!;
    return Row(
      children: [
        Expanded(
          child: _KPICard(
            title: 'Gesamt-Conversion',
            value: '${(funnel.overallConversionRate * 100).toStringAsFixed(1)}%',
            subtitle: '${funnel.contactsSaved} von ${funnel.totalViews}',
            icon: Icons.trending_up,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KPICard(
            title: 'Beste Stufe',
            value: '${(funnel.viewToProfileRate * 100).toStringAsFixed(1)}%',
            subtitle: 'Views → Profil',
            icon: Icons.star,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KPICard(
            title: 'Schwaechste Stufe',
            value: '${(_getWeakestRate(funnel) * 100).toStringAsFixed(1)}%',
            subtitle: _getWeakestStage(funnel),
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KPICard(
            title: 'Follow-Up Rate',
            value: '${(funnel.saveToFollowUpRate * 100).toStringAsFixed(1)}%',
            subtitle: '${funnel.followUps} Follow-Ups',
            icon: Icons.repeat,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  double _getWeakestRate(ConversionFunnel funnel) {
    final rates = [
      funnel.viewToProfileRate,
      funnel.profileToClickRate,
      funnel.clickToSaveRate,
      funnel.saveToFollowUpRate,
    ];
    return rates.reduce((a, b) => a < b ? a : b);
  }

  String _getWeakestStage(ConversionFunnel funnel) {
    final rates = {
      'Views → Profil': funnel.viewToProfileRate,
      'Profil → Klick': funnel.profileToClickRate,
      'Klick → Speichern': funnel.clickToSaveRate,
      'Speichern → Follow-Up': funnel.saveToFollowUpRate,
    };
    return rates.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }

  Widget _buildFunnelVisualization(
    ConversionFunnel funnel,
    ConversionFunnel? comparison,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Funnel Visualisierung', style: AppTextStyles.heading3),
          const SizedBox(height: 24),
          _FunnelStage(
            label: 'Karten-Aufrufe',
            value: funnel.totalViews,
            percentage: 100,
            comparisonValue: comparison?.totalViews,
            color: AppColors.primary,
            isFirst: true,
          ),
          _FunnelStage(
            label: 'Profil angesehen',
            value: funnel.profileViews,
            percentage: funnel.viewToProfileRate * 100,
            comparisonValue: comparison?.profileViews,
            comparisonPercentage:
                comparison != null ? comparison.viewToProfileRate * 100 : null,
            color: Colors.blue,
          ),
          _FunnelStage(
            label: 'Kontakt-Klicks',
            value: funnel.contactClicks,
            percentage: (funnel.contactClicks / funnel.totalViews) * 100,
            comparisonValue: comparison?.contactClicks,
            comparisonPercentage: comparison != null
                ? (comparison.contactClicks / comparison.totalViews) * 100
                : null,
            color: Colors.purple,
          ),
          _FunnelStage(
            label: 'Kontakt gespeichert',
            value: funnel.contactsSaved,
            percentage: (funnel.contactsSaved / funnel.totalViews) * 100,
            comparisonValue: comparison?.contactsSaved,
            comparisonPercentage: comparison != null
                ? (comparison.contactsSaved / comparison.totalViews) * 100
                : null,
            color: Colors.green,
          ),
          _FunnelStage(
            label: 'Follow-Up',
            value: funnel.followUps,
            percentage: (funnel.followUps / funnel.totalViews) * 100,
            comparisonValue: comparison?.followUps,
            comparisonPercentage: comparison != null
                ? (comparison.followUps / comparison.totalViews) * 100
                : null,
            color: Colors.orange,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelStats(
    ConversionFunnel funnel,
    ConversionFunnel? comparison,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stufenweise Conversion', style: AppTextStyles.heading3),
          const SizedBox(height: 24),
          _StepConversion(
            from: 'Aufrufe',
            to: 'Profil',
            rate: funnel.viewToProfileRate,
            comparisonRate: comparison?.viewToProfileRate,
          ),
          const SizedBox(height: 16),
          _StepConversion(
            from: 'Profil',
            to: 'Klicks',
            rate: funnel.profileToClickRate,
            comparisonRate: comparison?.profileToClickRate,
          ),
          const SizedBox(height: 16),
          _StepConversion(
            from: 'Klicks',
            to: 'Gespeichert',
            rate: funnel.clickToSaveRate,
            comparisonRate: comparison?.clickToSaveRate,
          ),
          const SizedBox(height: 16),
          _StepConversion(
            from: 'Gespeichert',
            to: 'Follow-Up',
            rate: funnel.saveToFollowUpRate,
            comparisonRate: comparison?.saveToFollowUpRate,
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gesamte Conversion',
                style: AppTextStyles.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(funnel.overallConversionRate * 100).toStringAsFixed(2)}%',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropOffAnalysis(ConversionFunnel funnel) {
    final dropOffs = [
      {
        'stage': 'Aufrufe → Profil',
        'lost': funnel.totalViews - funnel.profileViews,
        'rate': 1 - funnel.viewToProfileRate,
      },
      {
        'stage': 'Profil → Klicks',
        'lost': funnel.profileViews - funnel.contactClicks,
        'rate': 1 - funnel.profileToClickRate,
      },
      {
        'stage': 'Klicks → Gespeichert',
        'lost': funnel.contactClicks - funnel.contactsSaved,
        'rate': 1 - funnel.clickToSaveRate,
      },
      {
        'stage': 'Gespeichert → Follow-Up',
        'lost': funnel.contactsSaved - funnel.followUps,
        'rate': 1 - funnel.saveToFollowUpRate,
      },
    ];

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
            children: [
              const Icon(Icons.analytics, color: Colors.red),
              const SizedBox(width: 12),
              Text('Drop-Off Analyse', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 24),
          ...dropOffs.map((d) => _DropOffRow(
                stage: d['stage'] as String,
                lost: d['lost'] as int,
                rate: d['rate'] as double,
              )),
        ],
      ),
    );
  }

  Widget _buildOptimizationSuggestions(ConversionFunnel funnel) {
    final suggestions = <Map<String, dynamic>>[];

    if (funnel.viewToProfileRate < 0.7) {
      suggestions.add({
        'icon': Icons.visibility,
        'title': 'Profil-Vorschau verbessern',
        'description':
            'Nur ${(funnel.viewToProfileRate * 100).toStringAsFixed(0)}% der Besucher sehen das Profil an. Verbessern Sie die Vorschau und den ersten Eindruck.',
        'priority': 'Hoch',
      });
    }

    if (funnel.profileToClickRate < 0.5) {
      suggestions.add({
        'icon': Icons.touch_app,
        'title': 'Call-to-Actions staerken',
        'description':
            'Die Klickrate ist niedrig. Platzieren Sie Kontakt-Buttons prominenter und nutzen Sie auffaelligere Farben.',
        'priority': 'Mittel',
      });
    }

    if (funnel.clickToSaveRate < 0.5) {
      suggestions.add({
        'icon': Icons.save_alt,
        'title': 'Speichern erleichtern',
        'description':
            'Viele Klicks fuehren nicht zum Speichern. Bieten Sie One-Click-Save oder QR-Code-Download an.',
        'priority': 'Mittel',
      });
    }

    if (funnel.saveToFollowUpRate < 0.4) {
      suggestions.add({
        'icon': Icons.repeat,
        'title': 'Follow-Up Strategie entwickeln',
        'description':
            'Nur ${(funnel.saveToFollowUpRate * 100).toStringAsFixed(0)}% der Kontakte fuehren zu Follow-Ups. Implementieren Sie automatische Erinnerungen.',
        'priority': 'Niedrig',
      });
    }

    if (suggestions.isEmpty) {
      suggestions.add({
        'icon': Icons.check_circle,
        'title': 'Gute Performance!',
        'description':
            'Ihr Funnel performt gut. Behalten Sie die aktuelle Strategie bei und optimieren Sie weiterhin im Detail.',
        'priority': 'Info',
      });
    }

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
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Optimierungsvorschlaege', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 24),
          ...suggestions.map((s) => _SuggestionCard(
                icon: s['icon'] as IconData,
                title: s['title'] as String,
                description: s['description'] as String,
                priority: s['priority'] as String,
              )),
        ],
      ),
    );
  }
}

// =============================================================================
// WIDGETS
// =============================================================================

class _KPICard extends StatelessWidget {
  const _KPICard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodyRegular.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.smallText.copyWith(
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelStage extends StatelessWidget {
  const _FunnelStage({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    this.comparisonValue,
    this.comparisonPercentage,
    this.isFirst = false,
    this.isLast = false,
  });

  final String label;
  final int value;
  final double percentage;
  final Color color;
  final int? comparisonValue;
  final double? comparisonPercentage;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final widthFactor = percentage / 100;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: AppTextStyles.bodyRegular.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hauptbalken
                  Stack(
                    children: [
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDarker,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: widthFactor,
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                              style: AppTextStyles.smallText.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Vergleichsbalken
                  if (comparisonValue != null && comparisonPercentage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: FractionallySizedBox(
                        widthFactor: comparisonPercentage! / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyRegular.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }
}

class _StepConversion extends StatelessWidget {
  const _StepConversion({
    required this.from,
    required this.to,
    required this.rate,
    this.comparisonRate,
  });

  final String from;
  final String to;
  final double rate;
  final double? comparisonRate;

  @override
  Widget build(BuildContext context) {
    final percentage = (rate * 100).toStringAsFixed(1);
    final diff = comparisonRate != null ? rate - comparisonRate! : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(from, style: AppTextStyles.smallText),
                  const Icon(Icons.arrow_right, size: 16),
                  Text(to, style: AppTextStyles.smallText),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: rate,
                  backgroundColor: AppColors.backgroundDarker,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForRate(rate),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$percentage%',
              style: AppTextStyles.bodyRegular.copyWith(
                fontWeight: FontWeight.bold,
                color: _getColorForRate(rate),
              ),
            ),
            if (diff != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    diff >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: diff >= 0 ? Colors.green : Colors.red,
                  ),
                  Text(
                    '${(diff.abs() * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.smallText.copyWith(
                      color: diff >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Color _getColorForRate(double rate) {
    if (rate >= 0.7) return Colors.green;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

class _DropOffRow extends StatelessWidget {
  const _DropOffRow({
    required this.stage,
    required this.lost,
    required this.rate,
  });

  final String stage;
  final int lost;
  final double rate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(stage, style: AppTextStyles.bodyRegular),
          ),
          Expanded(
            child: Text(
              '-${lost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
              style: AppTextStyles.bodyRegular.copyWith(color: Colors.red),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            child: Text(
              '${(rate * 100).toStringAsFixed(1)}%',
              style: AppTextStyles.bodyRegular.copyWith(
                color: Colors.red.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rate,
                backgroundColor: AppColors.backgroundDarker,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.red.withValues(alpha: 0.6)),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
  });

  final IconData icon;
  final String title;
  final String description;
  final String priority;

  Color _getPriorityColor() {
    switch (priority) {
      case 'Hoch':
        return Colors.red;
      case 'Mittel':
        return Colors.orange;
      case 'Niedrig':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor().withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPriorityColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _getPriorityColor(), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyRegular.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priority,
                        style: AppTextStyles.smallText.copyWith(
                          color: _getPriorityColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTextStyles.smallText.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
