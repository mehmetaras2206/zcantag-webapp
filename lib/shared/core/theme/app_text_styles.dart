// =============================================================================
// APP_TEXT_STYLES.DART
// =============================================================================
// Zentrale TextStyle-Definitionen fuer die ZCANTAG Web App.
// Kopiert von mobilapp mit Anpassungen fuer Web.
// =============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Zentrale TextStyle-Definitionen
class AppTextStyles {
  AppTextStyles._();

  // ===========================================================================
  // FONT FAMILIES
  // ===========================================================================

  static const String fontFamily = 'Outfit';
  static const String fontFamilyAfacad = 'Afacad';
  static const String fontFamilyABeeZee = 'ABeeZee';

  // ===========================================================================
  // HEADINGS
  // ===========================================================================

  /// Hauptueberschrift (24px, Bold)
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Sekundaere Ueberschrift (20px, SemiBold)
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Tertiaere Ueberschrift (18px, SemiBold)
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ===========================================================================
  // BUTTON TEXT
  // ===========================================================================

  /// Standard Button-Textstil (20px)
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: AppColors.textOnPrimary,
  );

  static const TextStyle buttonText = button;

  // ===========================================================================
  // INPUT TEXT
  // ===========================================================================

  /// Eingabefeld-Textstil (15px)
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Placeholder/Hint-Textstil
  static const TextStyle inputHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // ===========================================================================
  // BODY TEXT
  // ===========================================================================

  /// Regulaerer Fliesstext (13px)
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  /// Fetter Fliesstext (13px, Bold)
  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // ===========================================================================
  // SMALL TEXT & LINKS
  // ===========================================================================

  /// Link-Textstil (13px)
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Kleiner Text (12px)
  static const TextStyle smallText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.divider,
  );

  // ===========================================================================
  // CARD TEXT (Visitenkarten)
  // ===========================================================================

  static const TextStyle cardCompanyName = TextStyle(
    fontFamily: fontFamilyAfacad,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle cardPersonName = TextStyle(
    fontFamily: fontFamilyAfacad,
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle cardCompanyNameSmall = TextStyle(
    fontFamily: fontFamilyAfacad,
    fontSize: 21,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle cardPersonNameSmall = TextStyle(
    fontFamily: fontFamilyAfacad,
    fontSize: 19,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  // ===========================================================================
  // NAVIGATION TEXT
  // ===========================================================================

  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamilyABeeZee,
    fontSize: 7,
    fontWeight: FontWeight.normal,
  );

  // ===========================================================================
  // WEB-SPECIFIC STYLES (Admin Panel, Data Tables)
  // ===========================================================================

  /// Admin-Sidebar Menuepunkt (14px)
  static const TextStyle sidebarItem = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  /// Admin-Sidebar Menuepunkt aktiv
  static const TextStyle sidebarItemActive = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// Tabellen-Header (14px, SemiBold)
  static const TextStyle tableHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Tabellen-Zelle (14px)
  static const TextStyle tableCell = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  /// Dashboard-Statistik (32px, Bold)
  static const TextStyle statValue = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Dashboard-Statistik Label (14px)
  static const TextStyle statLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
