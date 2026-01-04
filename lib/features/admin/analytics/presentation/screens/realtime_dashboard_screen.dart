// =============================================================================
// REALTIME_DASHBOARD_SCREEN.DART
// =============================================================================
// Enterprise Real-Time Analytics Dashboard
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/core/theme/app_colors.dart';
import '../../../../../shared/core/theme/app_text_styles.dart';
import '../../../presentation/layouts/admin_shell.dart';

/// Real-Time Dashboard State
class RealTimeState {
  const RealTimeState({
    required this.activeUsers,
    required this.pageViewsPerMinute,
    required this.recentEvents,
    required this.lastUpdated,
    this.trend = const [],
  });

  final int activeUsers;
  final int pageViewsPerMinute;
  final List<RecentEvent> recentEvents;
  final DateTime lastUpdated;
  final List<TrendPoint> trend;

  RealTimeState copyWith({
    int? activeUsers,
    int? pageViewsPerMinute,
    List<RecentEvent>? recentEvents,
    DateTime? lastUpdated,
    List<TrendPoint>? trend,
  }) {
    return RealTimeState(
      activeUsers: activeUsers ?? this.activeUsers,
      pageViewsPerMinute: pageViewsPerMinute ?? this.pageViewsPerMinute,
      recentEvents: recentEvents ?? this.recentEvents,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      trend: trend ?? this.trend,
    );
  }
}

class RecentEvent {
  const RecentEvent({
    required this.id,
    required this.type,
    required this.cardName,
    required this.location,
    required this.timestamp,
  });

  final String id;
  final EventType type;
  final String cardName;
  final String? location;
  final DateTime timestamp;
}

enum EventType {
  view('view', 'Aufruf', Icons.visibility, Colors.blue),
  contact('contact', 'Kontakt gespeichert', Icons.person_add, Colors.green),
  click('click', 'Klick', Icons.touch_app, Colors.orange),
  share('share', 'Geteilt', Icons.share, Colors.purple);

  const EventType(this.value, this.displayName, this.icon, this.color);
  final String value;
  final String displayName;
  final IconData icon;
  final Color color;
}

class TrendPoint {
  const TrendPoint({required this.minute, required this.value});
  final int minute;
  final int value;
}

/// Real-Time Dashboard Notifier
class RealTimeNotifier extends StateNotifier<RealTimeState> {
  RealTimeNotifier()
      : super(RealTimeState(
          activeUsers: 0,
          pageViewsPerMinute: 0,
          recentEvents: [],
          lastUpdated: DateTime.now(),
        ));

  Timer? _timer;

  void startUpdates(String companyId) {
    // Initial mock data
    _generateMockData();

    // Update every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _generateMockData();
    });
  }

  void _generateMockData() {
    // Simulate real-time data
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final activeUsers = 10 + (random % 50);
    final pageViews = 5 + (random % 30);

    // Generate trend data (last 10 minutes)
    final trend = List.generate(10, (i) {
      return TrendPoint(
        minute: i,
        value: 5 + ((random + i * 7) % 25),
      );
    });

    // Generate recent events
    final eventTypes = EventType.values;
    final cardNames = [
      'Max Mustermann',
      'Anna Schmidt',
      'Peter Mueller',
      'Lisa Weber',
      'Thomas Braun',
    ];
    final locations = ['Berlin', 'Hamburg', 'Muenchen', 'Koeln', 'Frankfurt'];

    final recentEvents = List.generate(10, (i) {
      return RecentEvent(
        id: 'event_$i',
        type: eventTypes[(random + i) % eventTypes.length],
        cardName: cardNames[(random + i) % cardNames.length],
        location: locations[(random + i) % locations.length],
        timestamp: DateTime.now().subtract(Duration(seconds: i * 30)),
      );
    });

    state = state.copyWith(
      activeUsers: activeUsers,
      pageViewsPerMinute: pageViews,
      recentEvents: recentEvents,
      lastUpdated: DateTime.now(),
      trend: trend,
    );
  }

  void stopUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopUpdates();
    super.dispose();
  }
}

final realTimeProvider =
    StateNotifierProvider<RealTimeNotifier, RealTimeState>((ref) {
  return RealTimeNotifier();
});

/// Real-Time Dashboard Screen
class RealTimeDashboardScreen extends ConsumerStatefulWidget {
  const RealTimeDashboardScreen({super.key});

  @override
  ConsumerState<RealTimeDashboardScreen> createState() =>
      _RealTimeDashboardScreenState();
}

class _RealTimeDashboardScreenState
    extends ConsumerState<RealTimeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(realTimeProvider.notifier).startUpdates('mock-company-id');
    });
  }

  @override
  void dispose() {
    ref.read(realTimeProvider.notifier).stopUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(realTimeProvider);

    return AdminShell(
      currentRoute: '/admin/analytics/realtime',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Echtzeit-Dashboard',
                                style: AppTextStyles.heading1),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
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
                        const SizedBox(height: 4),
                        Text(
                          'Live-Aktivitaet auf Ihren Visitenkarten',
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Last Updated
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.update, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Aktualisiert: ${_formatTime(state.lastUpdated)}',
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Live KPIs
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                return Row(
                  children: [
                    Expanded(
                      child: _buildLiveKpi(
                        icon: Icons.people,
                        title: 'Aktive Besucher',
                        value: state.activeUsers.toString(),
                        subtitle: 'jetzt gerade',
                        color: Colors.green,
                        isAnimated: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildLiveKpi(
                        icon: Icons.visibility,
                        title: 'Aufrufe/Min',
                        value: state.pageViewsPerMinute.toString(),
                        subtitle: 'letzte Minute',
                        color: Colors.blue,
                        isAnimated: true,
                      ),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLiveKpi(
                          icon: Icons.trending_up,
                          title: 'Trend',
                          value: _calculateTrend(state.trend),
                          subtitle: 'vs. vorherige 10 Min',
                          color: _getTrendColor(state.trend),
                          isAnimated: false,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Content Grid
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildLiveTrendChart(state)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildEventFeed(state)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildLiveTrendChart(state),
                    const SizedBox(height: 24),
                    _buildEventFeed(state),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            // Event Type Breakdown
            _buildEventBreakdown(state),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveKpi({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isAnimated,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              if (isAnimated)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading1.copyWith(
              fontSize: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodyRegular.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTrendChart(RealTimeState state) {
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
              Text('Live-Aktivitaet', style: AppTextStyles.heading3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE',
                      style: AppTextStyles.smallText.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Simple bar chart visualization
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: state.trend.map((point) {
                final maxValue =
                    state.trend.map((p) => p.value).reduce((a, b) => a > b ? a : b);
                final height = maxValue > 0 ? (point.value / maxValue) * 130 : 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height.toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.7),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${point.minute}m',
                          style: AppTextStyles.smallText.copyWith(
                            fontSize: 9,
                            color: AppColors.textWhite.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Aufrufe in den letzten 10 Minuten',
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventFeed(RealTimeState state) {
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
              Text('Live-Feed', style: AppTextStyles.heading3),
              Icon(
                Icons.rss_feed,
                color: AppColors.textWhite.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Event list
          ...state.recentEvents.take(8).map((event) => _buildEventItem(event)),
        ],
      ),
    );
  }

  Widget _buildEventItem(RecentEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: event.type.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              event.type.icon,
              color: event.type.color,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.cardName,
                  style: AppTextStyles.smallText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${event.type.displayName}${event.location != null ? ' aus ${event.location}' : ''}',
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(
            _formatTimeAgo(event.timestamp),
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventBreakdown(RealTimeState state) {
    // Count events by type
    final counts = <EventType, int>{};
    for (final event in state.recentEvents) {
      counts[event.type] = (counts[event.type] ?? 0) + 1;
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
          Text('Event-Verteilung', style: AppTextStyles.heading3),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: EventType.values.map((type) {
              final count = counts[type] ?? 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: type.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, color: type.color, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          count.toString(),
                          style: AppTextStyles.bodyRegular.copyWith(
                            fontWeight: FontWeight.bold,
                            color: type.color,
                          ),
                        ),
                        Text(
                          type.displayName,
                          style: AppTextStyles.smallText.copyWith(
                            fontSize: 11,
                            color: AppColors.textWhite.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    }
    return '${diff.inHours}h';
  }

  String _calculateTrend(List<TrendPoint> trend) {
    if (trend.length < 2) return '0%';
    final recent = trend.take(5).map((p) => p.value).reduce((a, b) => a + b);
    final older = trend.skip(5).map((p) => p.value).reduce((a, b) => a + b);
    if (older == 0) return '+100%';
    final change = ((recent - older) / older * 100).round();
    return change >= 0 ? '+$change%' : '$change%';
  }

  Color _getTrendColor(List<TrendPoint> trend) {
    if (trend.length < 2) return Colors.grey;
    final recent = trend.take(5).map((p) => p.value).reduce((a, b) => a + b);
    final older = trend.skip(5).map((p) => p.value).reduce((a, b) => a + b);
    return recent >= older ? Colors.green : Colors.red;
  }
}
