import 'package:flutter/material.dart';

import '../../../app/layout/vessel_layout.dart';
import '../../../app/theme/vessel_themes.dart';
import '../bottom_navbar/vessel_navbar.dart';

/// Screen scaffold with themed app bar. No direct colors.
class VesselScaffold extends StatelessWidget {
  const VesselScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
    this.showBottomNav = false,
    this.onSettingsDisabledTap,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBottomNav;
  final VoidCallback? onSettingsDisabledTap;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    return Scaffold(
      backgroundColor: t.scaffoldBackground,
      appBar: AppBar(
        toolbarHeight: VesselLayout.appBarHeight,
        leading: leading,
        title: Text(title.toUpperCase()),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(t.appBarBorderWidth),
          child: Container(
            height: t.appBarBorderWidth,
            color: t.appBarBorderColor,
          ),
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? VesselNavBar(onSettingsDisabledTap: onSettingsDisabledTap)
          : null,
      body: SafeArea(child: child),
    );
  }
}
