// =============================================================================
// PRICING_SCREEN.DART
// =============================================================================
// Pricing & Abo-Vergleich Screen
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../../../../shared/features/subscription/domain/entities/plan.dart';
import '../../../../shared/features/company/domain/entities/company.dart';
import '../providers/subscription_provider.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // TODO: Lade aktuellen Plan aus Auth/Company
      ref.read(subscriptionProvider.notifier).loadSubscription(PlanType.free);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final billingInterval = ref.watch(billingIntervalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDarker,
      appBar: AppBar(
        title: const Text('Preise & Abos'),
        backgroundColor: AppColors.backgroundDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Text(
              'Waehlen Sie Ihren Plan',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Flexible Preise fuer jeden Bedarf',
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Billing Toggle
            _buildBillingToggle(billingInterval),

            const SizedBox(height: 32),

            // Plans
            _buildContent(subscriptionState, billingInterval),

            const SizedBox(height: 48),

            // FAQ Section
            _buildFaqSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle(BillingInterval interval) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'Monatlich',
            isSelected: interval == BillingInterval.monthly,
            onTap: () {
              ref.read(billingIntervalProvider.notifier).state =
                  BillingInterval.monthly;
            },
          ),
          _buildToggleButton(
            label: 'Jaehrlich',
            isSelected: interval == BillingInterval.yearly,
            onTap: () {
              ref.read(billingIntervalProvider.notifier).state =
                  BillingInterval.yearly;
            },
            badge: '-20%',
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyRegular.copyWith(
                color: isSelected
                    ? AppColors.backgroundDark
                    : AppColors.textWhite,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.backgroundDark.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.smallText.copyWith(
                    color: isSelected ? AppColors.backgroundDark : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      SubscriptionState state, BillingInterval billingInterval) {
    if (state is SubscriptionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SubscriptionError) {
      return Center(child: Text(state.message));
    }

    if (state is! SubscriptionLoaded) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final plans = state.availablePlans;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plans
                .map((plan) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _PlanCard(
                          plan: plan,
                          isCurrentPlan: plan.type == state.currentPlan.type,
                          billingInterval: billingInterval,
                          onSelect: () => _selectPlan(plan, billingInterval),
                        ),
                      ),
                    ))
                .toList(),
          );
        }

        return Column(
          children: plans
              .map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PlanCard(
                      plan: plan,
                      isCurrentPlan: plan.type == state.currentPlan.type,
                      billingInterval: billingInterval,
                      onSelect: () => _selectPlan(plan, billingInterval),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  void _selectPlan(Plan plan, BillingInterval interval) async {
    if (plan.isFree) return;

    final buyUrl = plan.getBuyUrl(interval);
    if (buyUrl != null) {
      final uri = Uri.parse(buyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildFaqSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Haeufig gestellte Fragen', style: AppTextStyles.heading2),
          const SizedBox(height: 24),
          _buildFaqItem(
            'Kann ich jederzeit kuendigen?',
            'Ja, Sie koennen Ihr Abonnement jederzeit kuendigen. Es laeuft dann bis zum Ende der aktuellen Abrechnungsperiode.',
          ),
          _buildFaqItem(
            'Was passiert mit meinen Daten beim Downgrade?',
            'Ihre Daten bleiben erhalten. Bei Ueberschreitung der Limits werden aeltere Eintraege archiviert und koennen durch ein Upgrade wieder freigeschaltet werden.',
          ),
          _buildFaqItem(
            'Gibt es eine Testphase?',
            'Der Free-Plan ist dauerhaft kostenlos nutzbar. So koennen Sie alle Grundfunktionen unbegrenzt testen.',
          ),
          _buildFaqItem(
            'Welche Zahlungsmethoden werden akzeptiert?',
            'Wir akzeptieren Kreditkarten (Visa, Mastercard), PayPal, SEPA-Lastschrift und Ueberweisung.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: AppTextStyles.smallText.copyWith(
              color: AppColors.textWhite.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

/// Plan Card Widget
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.billingInterval,
    required this.onSelect,
  });

  final Plan plan;
  final bool isCurrentPlan;
  final BillingInterval billingInterval;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final price = billingInterval == BillingInterval.monthly
        ? plan.monthlyPrice
        : plan.effectiveMonthlyPrice;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular
              ? AppColors.primary
              : isCurrentPlan
                  ? AppColors.success
                  : AppColors.textWhite.withValues(alpha: 0.1),
          width: plan.isPopular || isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Popular Badge
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Text(
                'BELIEBTESTE WAHL',
                style: AppTextStyles.smallText.copyWith(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Description
                Text(plan.name, style: AppTextStyles.heading2),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: AppTextStyles.smallText.copyWith(
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 24),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (plan.isFree)
                      Text('Kostenlos', style: AppTextStyles.heading1)
                    else ...[
                      Text(
                        '${price.toStringAsFixed(2)}€',
                        style: AppTextStyles.heading1,
                      ),
                      Text(
                        '/Monat',
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),

                if (billingInterval == BillingInterval.yearly && !plan.isFree)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${plan.yearlyPrice.toStringAsFixed(2)}€/Jahr (${plan.yearlyDiscount.toStringAsFixed(0)}% Rabatt)',
                      style: AppTextStyles.smallText.copyWith(
                        color: AppColors.success,
                        fontSize: 11,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isPopular
                          ? AppColors.primary
                          : plan.isFree
                              ? AppColors.backgroundDarker
                              : Colors.white,
                      foregroundColor: plan.isPopular
                          ? AppColors.backgroundDark
                          : plan.isFree
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: AppColors.success.withValues(alpha: 0.2),
                      disabledForegroundColor: AppColors.success,
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Aktueller Plan'
                          : plan.isFree
                              ? 'Jetzt starten'
                              : 'Jetzt upgraden',
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Features
                Text(
                  'Enthaltene Features',
                  style: AppTextStyles.smallText.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),

                ...plan.features.map((feature) => _buildFeatureRow(feature)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(PlanFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            feature.included ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: feature.included
                ? AppColors.success
                : AppColors.textWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.name,
              style: AppTextStyles.smallText.copyWith(
                color: feature.included
                    ? AppColors.textWhite
                    : AppColors.textWhite.withValues(alpha: 0.5),
              ),
            ),
          ),
          if (feature.included && feature.limit != null)
            Text(
              feature.limit!,
              style: AppTextStyles.smallText.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
