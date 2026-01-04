// =============================================================================
// WEB_BREAKPOINTS.DART
// =============================================================================
// Responsive Breakpoints fuer Web-Layouts
// =============================================================================

import 'package:flutter/widgets.dart';

/// Web Breakpoints
class WebBreakpoints {
  WebBreakpoints._();

  // Breakpoint Values
  static const double mobileMax = 599;
  static const double tabletMin = 600;
  static const double tabletMax = 899;
  static const double desktopMin = 900;
  static const double wideDesktopMin = 1200;

  // Sidebar Widths
  static const double sidebarCollapsed = 72;
  static const double sidebarExpanded = 280;

  // Content Widths
  static const double maxContentWidth = 1400;
  static const double maxFormWidth = 600;
  static const double maxCardWidth = 400;

  // Grid Columns
  static const int mobileColumns = 1;
  static const int tabletColumns = 2;
  static const int desktopColumns = 3;
  static const int wideDesktopColumns = 4;

  // Padding
  static const double mobilePadding = 16;
  static const double tabletPadding = 24;
  static const double desktopPadding = 32;
}

/// Device Type Enum
enum DeviceType {
  mobile,
  tablet,
  desktop,
  wideDesktop;

  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop || this == DeviceType.wideDesktop;
  bool get isWideDesktop => this == DeviceType.wideDesktop;

  /// Gibt die Anzahl der Grid-Spalten zurueck
  int get gridColumns {
    switch (this) {
      case DeviceType.mobile:
        return WebBreakpoints.mobileColumns;
      case DeviceType.tablet:
        return WebBreakpoints.tabletColumns;
      case DeviceType.desktop:
        return WebBreakpoints.desktopColumns;
      case DeviceType.wideDesktop:
        return WebBreakpoints.wideDesktopColumns;
    }
  }

  /// Gibt das Standard-Padding zurueck
  double get padding {
    switch (this) {
      case DeviceType.mobile:
        return WebBreakpoints.mobilePadding;
      case DeviceType.tablet:
        return WebBreakpoints.tabletPadding;
      case DeviceType.desktop:
      case DeviceType.wideDesktop:
        return WebBreakpoints.desktopPadding;
    }
  }
}

/// Extension fuer einfachen Zugriff auf DeviceType
extension BuildContextDeviceType on BuildContext {
  /// Ermittelt den Device-Typ basierend auf der Screen-Breite
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    return DeviceTypeHelper.fromWidth(width);
  }

  /// Shortcut: Ist Mobile?
  bool get isMobile => deviceType.isMobile;

  /// Shortcut: Ist Tablet?
  bool get isTablet => deviceType.isTablet;

  /// Shortcut: Ist Desktop?
  bool get isDesktop => deviceType.isDesktop;

  /// Shortcut: Ist Wide Desktop?
  bool get isWideDesktop => deviceType.isWideDesktop;

  /// Shortcut: Screen-Breite
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Shortcut: Screen-Hoehe
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Helper Klasse fuer DeviceType Ermittlung
class DeviceTypeHelper {
  DeviceTypeHelper._();

  /// Ermittelt DeviceType anhand der Breite
  static DeviceType fromWidth(double width) {
    if (width >= WebBreakpoints.wideDesktopMin) {
      return DeviceType.wideDesktop;
    } else if (width >= WebBreakpoints.desktopMin) {
      return DeviceType.desktop;
    } else if (width >= WebBreakpoints.tabletMin) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }

  /// Ermittelt DeviceType aus BoxConstraints
  static DeviceType fromConstraints(BoxConstraints constraints) {
    return fromWidth(constraints.maxWidth);
  }
}

/// Screen Size Info Klasse
class ScreenSizeInfo {
  const ScreenSizeInfo({
    required this.deviceType,
    required this.screenWidth,
    required this.screenHeight,
    required this.localWidth,
    required this.localHeight,
  });

  final DeviceType deviceType;
  final double screenWidth;
  final double screenHeight;
  final double localWidth;
  final double localHeight;

  bool get isMobile => deviceType.isMobile;
  bool get isTablet => deviceType.isTablet;
  bool get isDesktop => deviceType.isDesktop;
  bool get isWideDesktop => deviceType.isWideDesktop;
  int get gridColumns => deviceType.gridColumns;
  double get padding => deviceType.padding;
}
