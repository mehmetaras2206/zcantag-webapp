// =============================================================================
// RESPONSIVE_LAYOUT.DART
// =============================================================================
// Layout Utilities fuer responsive Web-Layouts
// =============================================================================

import 'package:flutter/material.dart';
import 'web_breakpoints.dart';
import 'responsive_builder.dart';

/// Responsive Scaffold mit Navigation
///
/// Zeigt unterschiedliche Navigation basierend auf Screen-Groesse:
/// - Mobile: Bottom Navigation oder Drawer
/// - Tablet: Drawer Navigation
/// - Desktop: Permanente Sidebar
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.mobileNavigation,
    this.tabletDrawer,
    this.desktopSidebar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? mobileNavigation;
  final Widget? tabletDrawer;
  final Widget? desktopSidebar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: mobileNavigation,
        drawer: tabletDrawer,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
      tablet: Scaffold(
        appBar: appBar,
        body: body,
        drawer: tabletDrawer,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
      desktop: Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            if (desktopSidebar != null) desktopSidebar!,
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}

/// Responsive Container mit Max-Width
///
/// Zentriert Content und begrenzt die maximale Breite.
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.all(responsiveValue(
          context,
          mobile: WebBreakpoints.mobilePadding,
          tablet: WebBreakpoints.tabletPadding,
          desktop: WebBreakpoints.desktopPadding,
        ));

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? WebBreakpoints.maxContentWidth,
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// Responsive Split View
///
/// Zeigt auf Desktop zwei Panels nebeneinander, auf Mobile/Tablet gestapelt.
class ResponsiveSplitView extends StatelessWidget {
  const ResponsiveSplitView({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.dividerWidth = 1,
    this.dividerColor,
    this.showLeftOnMobile = true,
  });

  final Widget leftPanel;
  final Widget rightPanel;
  final int leftFlex;
  final int rightFlex;
  final double dividerWidth;
  final Color? dividerColor;
  final bool showLeftOnMobile;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: showLeftOnMobile ? leftPanel : rightPanel,
      desktop: Row(
        children: [
          Expanded(flex: leftFlex, child: leftPanel),
          VerticalDivider(
            width: dividerWidth,
            color: dividerColor ?? Theme.of(context).dividerColor,
          ),
          Expanded(flex: rightFlex, child: rightPanel),
        ],
      ),
    );
  }
}

/// Responsive Master-Detail Layout
///
/// Typisches Layout fuer Listen mit Detail-Ansicht.
class ResponsiveMasterDetail extends StatelessWidget {
  const ResponsiveMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 400,
    this.showDetailOnMobile = false,
    this.emptyDetail,
  });

  final Widget master;
  final Widget? detail;
  final double masterWidth;
  final bool showDetailOnMobile;
  final Widget? emptyDetail;

  @override
  Widget build(BuildContext context) {
    final effectiveDetail = detail ??
        emptyDetail ??
        const Center(
          child: Text('Waehlen Sie einen Eintrag aus der Liste'),
        );

    return ResponsiveBuilder(
      mobile: showDetailOnMobile && detail != null ? detail! : master,
      desktop: Row(
        children: [
          SizedBox(
            width: masterWidth,
            child: master,
          ),
          const VerticalDivider(width: 1),
          Expanded(child: effectiveDetail),
        ],
      ),
    );
  }
}

/// Responsive Padding Widget
///
/// Wendet unterschiedliches Padding basierend auf Screen-Groesse an.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  @override
  Widget build(BuildContext context) {
    final padding = responsiveValue<EdgeInsets>(
      context,
      mobile: mobilePadding ?? const EdgeInsets.all(16),
      tablet: tabletPadding ?? const EdgeInsets.all(24),
      desktop: desktopPadding ?? const EdgeInsets.all(32),
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive Card Grid
///
/// Zeigt Cards in einem responsive Grid.
class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.wideDesktopColumns = 4,
    this.spacing = 16,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics,
    this.padding,
  });

  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final int wideDesktopColumns;
  final double spacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final columns = responsiveValue<int>(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      wideDesktop: wideDesktopColumns,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive Row/Column
///
/// Zeigt Kinder als Row auf Desktop, als Column auf Mobile.
class ResponsiveRowColumn extends StatelessWidget {
  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
    this.rowSpacing = 16,
    this.columnSpacing = 16,
    this.useRowOnTablet = false,
  });

  final List<Widget> children;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;
  final double rowSpacing;
  final double columnSpacing;
  final bool useRowOnTablet;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(
        mainAxisAlignment: columnMainAxisAlignment,
        crossAxisAlignment: columnCrossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: _addSpacing(children, columnSpacing, Axis.vertical),
      ),
      tablet: useRowOnTablet
          ? Row(
              mainAxisAlignment: rowMainAxisAlignment,
              crossAxisAlignment: rowCrossAxisAlignment,
              children: _addSpacing(children, rowSpacing, Axis.horizontal),
            )
          : Column(
              mainAxisAlignment: columnMainAxisAlignment,
              crossAxisAlignment: columnCrossAxisAlignment,
              mainAxisSize: MainAxisSize.min,
              children: _addSpacing(children, columnSpacing, Axis.vertical),
            ),
      desktop: Row(
        mainAxisAlignment: rowMainAxisAlignment,
        crossAxisAlignment: rowCrossAxisAlignment,
        children: _addSpacing(children, rowSpacing, Axis.horizontal),
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing, Axis axis) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(
          axis == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }
    return result;
  }
}

/// Responsive Text Size
///
/// Passt Text-Groesse basierend auf Screen-Groesse an.
class ResponsiveText extends StatelessWidget {
  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final fontSize = responsiveValue<double?>(
      context,
      mobile: mobileFontSize,
      tablet: tabletFontSize,
      desktop: desktopFontSize,
    );

    return Text(
      text,
      style: fontSize != null
          ? (style ?? const TextStyle()).copyWith(fontSize: fontSize)
          : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive SizedBox
///
/// SizedBox mit responsive Groesse.
class ResponsiveSizedBox extends StatelessWidget {
  const ResponsiveSizedBox({
    super.key,
    this.mobileWidth,
    this.mobileHeight,
    this.tabletWidth,
    this.tabletHeight,
    this.desktopWidth,
    this.desktopHeight,
    this.child,
  });

  final double? mobileWidth;
  final double? mobileHeight;
  final double? tabletWidth;
  final double? tabletHeight;
  final double? desktopWidth;
  final double? desktopHeight;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final width = responsiveValue<double?>(
      context,
      mobile: mobileWidth,
      tablet: tabletWidth,
      desktop: desktopWidth,
    );

    final height = responsiveValue<double?>(
      context,
      mobile: mobileHeight,
      tablet: tabletHeight,
      desktop: desktopHeight,
    );

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }
}
