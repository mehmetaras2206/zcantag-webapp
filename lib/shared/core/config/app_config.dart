// =============================================================================
// APP_CONFIG.DART (Web Version)
// =============================================================================
// Zentrale Konfigurationsdatei fuer die ZCANTAG Web-App.
// Angepasst fuer Web-Deployment auf Vercel.
// =============================================================================

/// Zentrale Konfigurationsklasse fuer API-Endpoints und Keys
class AppConfig {
  AppConfig._();

  // ===========================================================================
  // API CONFIGURATION
  // ===========================================================================

  /// Backend API Base URL
  /// Production: Railway
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zcantag-backend-production.up.railway.app',
  );

  /// API Version Prefix
  static const String apiVersion = '/api';

  /// Vollstaendige API-URL
  static String get apiUrl => '$apiBaseUrl$apiVersion';

  // ===========================================================================
  // SUPABASE CONFIGURATION (fuer OAuth)
  // ===========================================================================

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ranqfruslecwjncbcpzh.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // ===========================================================================
  // AUTH ENDPOINTS
  // ===========================================================================

  static String get authLogin => '$apiUrl/auth/login';
  static String get authRegister => '$apiUrl/auth/register';
  static String get authLogout => '$apiUrl/auth/logout';
  static String get authRefresh => '$apiUrl/auth/refresh';
  static String get authMe => '$apiUrl/auth/me';
  static String get authPasswordReset => '$apiUrl/auth/password-reset-request';
  static String get authOAuthProviders => '$apiUrl/auth/oauth/providers';
  static String get authOAuthCallback => '$apiUrl/auth/oauth/callback';
  static String authOAuthStart(String provider) => '$apiUrl/auth/oauth/$provider';
  static String get authOAuthExchange => '$apiUrl/auth/oauth/exchange';

  // ===========================================================================
  // CARDS ENDPOINTS
  // ===========================================================================

  static String get cardsAll => '$apiUrl/cards';
  static String get cardsPersonal => '$apiUrl/cards/personal';
  static String get cardsCompany => '$apiUrl/cards/company';
  static String cardById(String id) => '$apiUrl/cards/$id';
  static String get cardsCreate => '$apiUrl/cards';
  static String cardUpdate(String id) => '$apiUrl/cards/$id';
  static String cardDelete(String id) => '$apiUrl/cards/$id';
  static String cardPublic(String slug) => '$apiUrl/cards/public/$slug';
  static String cardShare(String id) => '$apiUrl/cards/$id/share';

  // ===========================================================================
  // CONTACTS ENDPOINTS
  // ===========================================================================

  static String get contactsAll => '$apiUrl/contacts';
  static String contactById(String id) => '$apiUrl/contacts/$id';
  static String get contactsCreate => '$apiUrl/contacts';
  static String contactUpdate(String id) => '$apiUrl/contacts/$id';
  static String contactDelete(String id) => '$apiUrl/contacts/$id';
  static String get contactsCount => '$apiUrl/contacts/count';

  // ===========================================================================
  // COMPANY ENDPOINTS (Admin Panel)
  // ===========================================================================

  static String companyById(String id) => '$apiUrl/companies/$id';
  static String companyUpdate(String id) => '$apiUrl/companies/$id';
  static String companyUploadLogo(String id) => '$apiUrl/companies/$id/logo';

  // ===========================================================================
  // RBAC ENDPOINTS (Admin Panel)
  // ===========================================================================

  static String rbacMembers(String companyId) => '$apiUrl/rbac/companies/$companyId/members';
  static String rbacAssignRole(String companyId) => '$apiUrl/rbac/companies/$companyId/assign-role';
  static String rbacUpdateRole(String companyId, String userId) =>
      '$apiUrl/rbac/companies/$companyId/users/$userId/role';
  static String rbacRemoveUser(String companyId, String userId) =>
      '$apiUrl/rbac/companies/$companyId/users/$userId';

  // ===========================================================================
  // TEAMS ENDPOINTS (Admin Panel)
  // ===========================================================================

  static String get teamsAll => '$apiUrl/teams';
  static String teamById(String id) => '$apiUrl/teams/$id';
  static String get teamsCreate => '$apiUrl/teams';
  static String teamUpdate(String id) => '$apiUrl/teams/$id';
  static String teamDelete(String id) => '$apiUrl/teams/$id';

  // ===========================================================================
  // ANALYTICS ENDPOINTS (Admin Panel)
  // ===========================================================================

  static String analyticsCard(String cardId) => '$apiUrl/analytics/cards/$cardId';
  static String analyticsCompany(String companyId) => '$apiUrl/analytics/companies/$companyId';
  static String analyticsConversionFunnel(String companyId) =>
      '$apiUrl/analytics/companies/$companyId/conversion-funnel';
  static String analyticsRealTime(String companyId) =>
      '$apiUrl/analytics/companies/$companyId/real-time';
  static String analyticsExport(String companyId) =>
      '$apiUrl/analytics/companies/$companyId/export';

  // ===========================================================================
  // PUSH CAMPAIGNS ENDPOINTS (Admin Panel)
  // ===========================================================================

  static String get pushCampaignsAll => '$apiUrl/push-campaigns';
  static String pushCampaignById(String id) => '$apiUrl/push-campaigns/$id';
  static String get pushCampaignsCreate => '$apiUrl/push-campaigns';
  static String pushCampaignSend(String id) => '$apiUrl/push-campaigns/$id/send';
  static String pushCampaignCancel(String id) => '$apiUrl/push-campaigns/$id/cancel';
  static String pushCampaignAnalytics(String id) => '$apiUrl/push-campaigns/$id/analytics';
  static String pushCampaignsWeeklyUsage(String companyId) =>
      '$apiUrl/push-campaigns/company/$companyId/weekly-usage';

  // ===========================================================================
  // PLANS ENDPOINTS
  // ===========================================================================

  static String get plansAll => '$apiUrl/plans';

  // ===========================================================================
  // TIMEOUTS
  // ===========================================================================

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // ===========================================================================
  // STORAGE KEYS (fuer Web Storage)
  // ===========================================================================

  static const String accessTokenKey = 'zcantag_access_token';
  static const String refreshTokenKey = 'zcantag_refresh_token';
  static const String userDataKey = 'zcantag_user_data';
}
