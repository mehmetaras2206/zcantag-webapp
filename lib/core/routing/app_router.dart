// =============================================================================
// APP_ROUTER.DART
// =============================================================================
// GoRouter Konfiguration fuer Web Navigation
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth Screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/oauth_callback_screen.dart';

// Home Screen
import '../../features/home/presentation/screens/home_screen.dart';

// Cards Screens
import '../../features/cards/presentation/screens/my_cards_screen.dart';
import '../../features/cards/presentation/screens/card_editor_screen.dart';
import '../../features/cards/presentation/screens/share_card_screen.dart';

// Public Card Screen
import '../../features/public_card/presentation/screens/public_card_screen.dart';

// Contacts Screens
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/contacts/presentation/screens/contact_detail_screen.dart';

// Admin Screens
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/company/presentation/screens/company_profile_screen.dart';
import '../../features/admin/rbac/presentation/screens/team_list_screen.dart';
import '../../features/admin/rbac/presentation/screens/invite_member_screen.dart';
import '../../features/admin/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/admin/push_campaigns/presentation/screens/campaigns_list_screen.dart';
import '../../features/admin/push_campaigns/presentation/screens/campaign_editor_screen.dart';
import '../../features/admin/push_campaigns/presentation/screens/campaign_detail_screen.dart';
import '../../features/subscription/presentation/screens/pricing_screen.dart';

// Guards
import 'guards/auth_guard.dart';

/// Router Provider fuer Riverpod
final routerProvider = Provider<GoRouter>((ref) {
  final authGuard = ref.watch(authGuardProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: authGuard,
    redirect: (context, state) {
      return authGuard.redirect(state.matchedLocation);
    },
    routes: [
      // =======================================================================
      // PUBLIC ROUTES (kein Auth erforderlich)
      // =======================================================================
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // OAuth Callback
      GoRoute(
        path: '/auth/callback',
        name: 'oauth-callback',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          final provider = state.uri.queryParameters['provider'];
          final error = state.uri.queryParameters['error'];
          return OAuthCallbackScreen(
            code: code,
            provider: provider,
            error: error,
          );
        },
      ),

      // Public Card View (ohne Login)
      GoRoute(
        path: '/card/:slug',
        name: 'public-card',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return PublicCardScreen(slug: slug);
        },
      ),

      // =======================================================================
      // USER ROUTES (Auth erforderlich)
      // =======================================================================
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Cards
          GoRoute(
            path: 'cards',
            name: 'cards',
            builder: (context, state) => const MyCardsScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'cards-new',
                builder: (context, state) => const CardEditorScreen(),
              ),
              GoRoute(
                path: ':id/edit',
                name: 'cards-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CardEditorScreen(cardId: id);
                },
              ),
              GoRoute(
                path: ':id/share',
                name: 'cards-share',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ShareCardScreen(cardId: id);
                },
              ),
            ],
          ),

          // Contacts
          GoRoute(
            path: 'contacts',
            name: 'contacts',
            builder: (context, state) => const ContactsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'contact-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ContactDetailScreen(contactId: id);
                },
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Einstellungen'),
          ),

          // Subscription
          GoRoute(
            path: 'subscription',
            name: 'subscription',
            builder: (context, state) => const PricingScreen(),
          ),
        ],
      ),

      // =======================================================================
      // ADMIN ROUTES (Admin-Rolle erforderlich)
      // =======================================================================
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          // Company Profile
          GoRoute(
            path: 'company',
            name: 'admin-company',
            builder: (context, state) => const CompanyProfileScreen(),
          ),

          // Team Management
          GoRoute(
            path: 'team',
            name: 'admin-team',
            builder: (context, state) => const TeamListScreen(),
            routes: [
              GoRoute(
                path: 'invite',
                name: 'admin-team-invite',
                builder: (context, state) => const InviteMemberScreen(),
              ),
            ],
          ),

          // Analytics
          GoRoute(
            path: 'analytics',
            name: 'admin-analytics',
            builder: (context, state) => const AnalyticsDashboardScreen(),
          ),

          // Push Campaigns
          GoRoute(
            path: 'campaigns',
            name: 'admin-campaigns',
            builder: (context, state) => const CampaignsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'admin-campaigns-new',
                builder: (context, state) => const CampaignEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'admin-campaign-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CampaignDetailScreen(campaignId: id);
                },
              ),
              GoRoute(
                path: ':id/edit',
                name: 'admin-campaign-edit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CampaignEditorScreen(campaignId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

/// Placeholder Screen fuer noch nicht implementierte Routes
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Diese Seite wird noch implementiert...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error Screen fuer ungueltige Routes
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fehler')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Seite nicht gefunden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}
