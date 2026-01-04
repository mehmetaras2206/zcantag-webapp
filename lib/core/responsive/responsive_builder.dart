// =============================================================================
// RESPONSIVE_BUILDER.DART
// =============================================================================
// Builder Widgets fuer responsive Layouts
// =============================================================================

import 'package:flutter/material.dart';
import 'web_breakpoints.dart';

/// Responsive Builder Widget
///
/// Baut unterschiedliche Widgets basierend auf der Screen-Groesse.
/// Mindestens `mobile` muss angegeben werden.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wideDesktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? wideDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = DeviceTypeHelper.fromConstraints(constraints);

        switch (deviceType) {
          case DeviceType.wideDesktop:
            return wideDesktop ?? desktop ?? tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.mobile:
            return mobile;
        }
      },
    );
  }
}

/// Responsive Builder mit Callback-Funktion
///
/// Uebergibt ScreenSizeInfo an die Builder-Funktion.
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ScreenSizeInfo sizeInfo) builder;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = DeviceTypeHelper.fromConstraints(constraints);

        final sizeInfo = ScreenSizeInfo(
          deviceType: deviceType,
          screenWidth: screenSize.width,
          screenHeight: screenSize.height,
          localWidth: constraints.maxWidth,
          localHeight: constraints.maxHeight,
        );

        return builder(context, sizeInfo);
      },
    );
  }
}

/// Responsive Value - waehlt Wert basierend auf Screen-Groesse
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
  T? wideDesktop,
}) {
  final deviceType = context.deviceType;

  switch (deviceType) {
    case DeviceType.wideDesktop:
      return wideDesktop ?? desktop ?? tablet ?? mobile;
    case DeviceType.desktop:
      return desktop ?? tablet ?? mobile;
    case DeviceType.tablet:
      return tablet ?? mobile;
    case DeviceType.mobile:
      return mobile;
  }
}

/// Responsive Grid View
///
/// Baut ein Grid mit responsive Spaltenanzahl.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.wideDesktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? wideDesktopColumns;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, sizeInfo) {
        int columns;
        switch (sizeInfo.deviceType) {
          case DeviceType.wideDesktop:
            columns = wideDesktopColumns ??
                desktopColumns ??
                WebBreakpoints.wideDesktopColumns;
          case DeviceType.desktop:
            columns = desktopColumns ?? WebBreakpoints.desktopColumns;
          case DeviceType.tablet:
            columns = tabletColumns ?? WebBreakpoints.tabletColumns;
          case DeviceType.mobile:
            columns = mobileColumns ?? WebBreakpoints.mobileColumns;
        }

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: 1,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive Wrap
///
/// Wrap-Widget mit responsive Spacing.
class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
  });

  final List<Widget> children;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;

  @override
  Widget build(BuildContext context) {
    final spacing = responsiveValue<double>(
      context,
      mobile: mobileSpacing ?? 8,
      tablet: tabletSpacing ?? 12,
      desktop: desktopSpacing ?? 16,
    );

    return Wrap(
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: spacing,
      children: children,
    );
  }
}

/// Show Widget nur auf bestimmten Devices
class ShowOnDevice extends StatelessWidget {
  const ShowOnDevice({
    super.key,
    required this.child,
    this.showOnMobile = true,
    this.showOnTablet = true,
    this.showOnDesktop = true,
    this.showOnWideDesktop = true,
    this.replacement,
  });

  final Widget child;
  final bool showOnMobile;
  final bool showOnTablet;
  final bool showOnDesktop;
  final bool showOnWideDesktop;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;

    final shouldShow = switch (deviceType) {
      DeviceType.mobile => showOnMobile,
      DeviceType.tablet => showOnTablet,
      DeviceType.desktop => showOnDesktop,
      DeviceType.wideDesktop => showOnWideDesktop,
    };

    if (shouldShow) {
      return child;
    }

    return replacement ?? const SizedBox.shrink();
  }
}

/// Zeigt Widget nur auf Mobile
class MobileOnly extends StatelessWidget {
  const MobileOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  final Widget child;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    return ShowOnDevice(
      showOnMobile: true,
      showOnTablet: false,
      showOnDesktop: false,
      showOnWideDesktop: false,
      replacement: replacement,
      child: child,
    );
  }
}

/// Zeigt Widget nur auf Tablet
class TabletOnly extends StatelessWidget {
  const TabletOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  final Widget child;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    return ShowOnDevice(
      showOnMobile: false,
      showOnTablet: true,
      showOnDesktop: false,
      showOnWideDesktop: false,
      replacement: replacement,
      child: child,
    );
  }
}

/// Zeigt Widget nur auf Desktop
class DesktopOnly extends StatelessWidget {
  const DesktopOnly({
    super.key,
    required this.child,
    this.replacement,
  });

  final Widget child;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    return ShowOnDevice(
      showOnMobile: false,
      showOnTablet: false,
      showOnDesktop: true,
      showOnWideDesktop: true,
      replacement: replacement,
      child: child,
    );
  }
}

/// Zeigt Widget auf Tablet und groesser
class TabletAndUp extends StatelessWidget {
  const TabletAndUp({
    super.key,
    required this.child,
    this.replacement,
  });

  final Widget child;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    return ShowOnDevice(
      showOnMobile: false,
      showOnTablet: true,
      showOnDesktop: true,
      showOnWideDesktop: true,
      replacement: replacement,
      child: child,
    );
  }
}

/// Zeigt Widget auf Mobile und Tablet
class MobileAndTablet extends StatelessWidget {
  const MobileAndTablet({
    super.key,
    required this.child,
    this.replacement,
  });

  final Widget child;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) {
    return ShowOnDevice(
      showOnMobile: true,
      showOnTablet: true,
      showOnDesktop: false,
      showOnWideDesktop: false,
      replacement: replacement,
      child: child,
    );
  }
}
