// =============================================================================
// WEB_STORAGE.DART
// =============================================================================
// Token- und User-Daten Speicherung fuer Web.
// Verwendet SharedPreferences (localStorage) statt SecureStorage.
//
// HINWEIS: Web hat kein sicheres Storage wie iOS Keychain oder Android
// EncryptedSharedPreferences. Tokens werden in localStorage gespeichert.
// Fuer sensible Daten sollte HttpOnly-Cookie-basierte Auth verwendet werden.
// =============================================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// Web-Storage Klasse fuer Token-Management
///
/// Ersetzt [SecureStorage] aus der Mobile-App.
/// Verwendet SharedPreferences (localStorage im Browser).
class WebStorage {
  WebStorage._();

  static SharedPreferences? _prefs;

  /// Initialisiert SharedPreferences (muss vor Verwendung aufgerufen werden)
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Sicherstellen dass _prefs initialisiert ist
  static Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ===========================================================================
  // ACCESS TOKEN
  // ===========================================================================

  /// Speichert den Access Token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConfig.accessTokenKey, token);
  }

  /// Liest den Access Token
  static Future<String?> getAccessToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConfig.accessTokenKey);
  }

  /// Loescht den Access Token
  static Future<void> deleteAccessToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConfig.accessTokenKey);
  }

  // ===========================================================================
  // REFRESH TOKEN
  // ===========================================================================

  /// Speichert den Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConfig.refreshTokenKey, token);
  }

  /// Liest den Refresh Token
  static Future<String?> getRefreshToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(AppConfig.refreshTokenKey);
  }

  /// Loescht den Refresh Token
  static Future<void> deleteRefreshToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConfig.refreshTokenKey);
  }

  // ===========================================================================
  // USER DATA
  // ===========================================================================

  /// Speichert User-Daten als JSON
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _getPrefs();
    await prefs.setString(AppConfig.userDataKey, jsonEncode(userData));
  }

  /// Liest User-Daten als Map
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(AppConfig.userDataKey);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Loescht User-Daten
  static Future<void> deleteUserData() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConfig.userDataKey);
  }

  // ===========================================================================
  // AUTH DATA (komplett)
  // ===========================================================================

  /// Speichert alle Auth-Daten (Tokens + User)
  static Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    Map<String, dynamic>? userData,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    if (userData != null) {
      await saveUserData(userData);
    }
  }

  /// Loescht alle Auth-Daten (Logout)
  static Future<void> clearAuthData() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserData();
  }

  /// Prueft ob User eingeloggt ist (Token vorhanden)
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ===========================================================================
  // GENERIC STORAGE
  // ===========================================================================

  /// Speichert einen String-Wert
  static Future<void> setString(String key, String value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, value);
  }

  /// Liest einen String-Wert
  static Future<String?> getString(String key) async {
    final prefs = await _getPrefs();
    return prefs.getString(key);
  }

  /// Speichert einen Bool-Wert
  static Future<void> setBool(String key, bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(key, value);
  }

  /// Liest einen Bool-Wert
  static Future<bool?> getBool(String key) async {
    final prefs = await _getPrefs();
    return prefs.getBool(key);
  }

  /// Loescht einen Wert
  static Future<void> remove(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  /// Loescht ALLE gespeicherten Daten
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
