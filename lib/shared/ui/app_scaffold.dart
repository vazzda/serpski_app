import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Scaffold with app bar using theme. No direct colors.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: leading,
        title: Text(title.toUpperCase()),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            color: AppTheme.borderBlack,
          ),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}
