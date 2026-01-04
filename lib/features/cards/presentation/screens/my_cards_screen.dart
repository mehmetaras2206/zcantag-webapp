// =============================================================================
// MY_CARDS_SCREEN.DART
// =============================================================================
// Uebersicht aller Karten des aktuellen Users
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../../shared/features/cards/domain/entities/card.dart' as domain;
import '../providers/cards_provider.dart';

class MyCardsScreen extends ConsumerStatefulWidget {
  const MyCardsScreen({super.key});

  @override
  ConsumerState<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends ConsumerState<MyCardsScreen> {
  @override
  void initState() {
    super.initState();
    // Karten beim Start laden
    Future.microtask(() {
      ref.read(cardsProvider.notifier).loadMyCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardsState = ref.watch(cardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Karten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(cardsProvider.notifier).refresh(),
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/cards/new'),
        icon: const Icon(Icons.add),
        label: const Text('Neue Karte'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.backgroundDarker,
      ),
      body: _buildBody(cardsState),
    );
  }

  Widget _buildBody(CardsState state) {
    return switch (state) {
      CardsInitial() => const Center(child: CircularProgressIndicator()),
      CardsLoading() => const Center(child: CircularProgressIndicator()),
      CardsError(:final message) => _buildError(message),
      CardsLoaded(:final cards) => _buildCardsList(cards),
    };
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Fehler beim Laden',
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(cardsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList(List<domain.Card> cards) {
    if (cards.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(cardsProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) => _CardTile(card: cards[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_outlined,
            size: 80,
            color: AppColors.textWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Keine Karten vorhanden',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Erstellen Sie Ihre erste digitale Visitenkarte',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/cards/new'),
            icon: const Icon(Icons.add),
            label: const Text('Karte erstellen'),
          ),
        ],
      ),
    );
  }
}

/// Karten-Kachel Widget
class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final domain.Card card;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/cards/${card.id}/edit'),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getPrimaryColor(),
                _getPrimaryColor().withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Hintergrund-Muster
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.credit_card,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              // Inhalt
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kartentyp-Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        card.cardType.displayName,
                        style: AppTextStyles.smallText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Name
                    Text(
                      card.displayName,
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.title != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.title!,
                        style: AppTextStyles.bodyRegular.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Aktionen
                    Row(
                      children: [
                        if (card.slug != null) ...[
                          Icon(
                            Icons.link,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            card.slug!,
                            style: AppTextStyles.smallText.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                        const Spacer(),
                        _ActionButton(
                          icon: Icons.share,
                          onTap: () => context.push('/cards/${card.id}/share'),
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.edit,
                          onTap: () => context.go('/cards/${card.id}/edit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status-Indikator
              if (!card.isActive)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Inaktiv',
                      style: AppTextStyles.smallText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPrimaryColor() {
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
}

/// Kleine Aktions-Button
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
