// =============================================================================
// APP_COLORS.DART
// =============================================================================
// Zentrale Farbdefinitionen fuer die ZCANTAG Web App.
// Kopiert von mobilapp fuer Code-Sharing.
// =============================================================================

import 'package:flutter/material.dart';

/// Zentrale Farbdefinitionen fuer die ZCANTAG App
class AppColors {
  AppColors._();

  // ===========================================================================
  // PRIMARY COLORS - Markenfarben
  // ===========================================================================

  /// ZCANTAG Hauptfarbe - Gelb (#FFDE00)
  static const Color primary = Color(0xFFFFDE00);

  /// Dunklere Variante der Primaerfarbe
  static const Color primaryDark = Color(0xFFE5C700);

  // ===========================================================================
  // BACKGROUND COLORS
  // ===========================================================================

  /// Dunkler Hintergrund fuer Cards und Header (#303030)
  static const Color backgroundDark = Color(0xFF303030);

  /// Noch dunklerer Hintergrund (#222222)
  static const Color backgroundDarker = Color(0xFF222222);

  /// Heller Hintergrund (Weiss)
  static const Color backgroundLight = Color(0xFFFFFFFF);

  /// Surface-Farbe fuer erhoegte Elemente
  static const Color surface = Color(0xFFFFFFFF);

  // ===========================================================================
  // TEXT COLORS
  // ===========================================================================

  /// Primaere Textfarbe - Schwarz
  static const Color textPrimary = Color(0xFF000000);

  /// Sekundaere Textfarbe - Dunkelgrau
  static const Color textSecondary = Color(0xFF636363);

  /// Tertiaere Textfarbe - Helleres Grau
  static const Color textTertiary = Color(0xFF8A8A8A);

  /// Hint-Textfarbe fuer Placeholder
  static const Color textHint = Color(0xFF6D6A6A);

  /// Textfarbe auf primaerm Hintergrund
  static const Color textOnPrimary = Color(0xFF000000);

  /// Weisse Textfarbe (fuer Dark Theme)
  static const Color textWhite = Color(0xFFFFFFFF);

  // ===========================================================================
  // BORDER COLORS
  // ===========================================================================

  /// Rahmenfarbe fuer Eingabefelder
  static const Color inputBorder = Color(0xFF6C6A6A);

  /// Trennlinienfarbe
  static const Color divider = Color(0xFF757171);

  // ===========================================================================
  // SOCIAL BUTTON COLORS
  // ===========================================================================

  static const Color socialButtonBackground = Color(0xFFFFFFFF);
  static const Color socialButtonShadow = Color(0x40000000);

  // ===========================================================================
  // STATUS COLORS
  // ===========================================================================

  /// Fehlerfarbe - Rot
  static const Color error = Color(0xFFE53935);

  /// Erfolgsfarbe - Gruen
  static const Color success = Color(0xFF43A047);

  /// Warnfarbe - Orange
  static const Color warning = Color(0xFFFFA726);

  // ===========================================================================
  // WEB-SPECIFIC COLORS (Admin Panel)
  // ===========================================================================

  /// Sidebar-Hintergrund
  static const Color sidebarBackground = Color(0xFF1E1E1E);

  /// Sidebar-Hover
  static const Color sidebarHover = Color(0xFF2D2D2D);

  /// Admin-Akzent (fuer Charts etc.)
  static const Color adminAccent = Color(0xFF4A90D9);

  /// Chart-Farben
  static const List<Color> chartColors = [
    Color(0xFFFFDE00), // Primary Yellow
    Color(0xFF4A90D9), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFE53935), // Red
    Color(0xFFFFA726), // Orange
    Color(0xFF9C27B0), // Purple
  ];
}
