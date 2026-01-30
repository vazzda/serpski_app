import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../screens/agreement_group_list_screen.dart';
import '../screens/group_list_screen.dart';
import '../screens/result_screen.dart';
import '../screens/session_screen.dart';
import '../shared/theme/app_theme.dart';

/// Route names/paths.
class AppRoutes {
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String conjugations = '/conjugations';
  static const String agreement = '/agreement';
  static const String session = '/session';
  static const String result = '/result';
}

/// Custom page with slide transition and scaffold background color.
/// Forward: slides in from right. Back: slides out to right.
Page<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: Container(
      color: AppTheme.scaffoldBackground,
      child: child,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide in from right (forward) / slide out to right (back)
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final slideTween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeInOut),
      );
      // Subtle fade (0.5 to 1.0 for less dramatic effect)
      final fadeTween = Tween(begin: 0.5, end: 1.0).chain(
        CurveTween(curve: Curves.easeIn),
      );
      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
  );
}

/// GoRouter config. Session and result read from Riverpod.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _buildPage(
          const GroupListScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.vocabulary,
        pageBuilder: (context, state) => _buildPage(
          const ChildGroupListScreen(parent: ParentCategory.vocabulary),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.conjugations,
        pageBuilder: (context, state) => _buildPage(
          const ChildGroupListScreen(parent: ParentCategory.conjugations),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.agreement,
        pageBuilder: (context, state) => _buildPage(
          const AgreementGroupListScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.session,
        pageBuilder: (context, state) => _buildPage(
          const SessionScreen(),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.result,
        pageBuilder: (context, state) => _buildPage(
          const ResultScreen(),
          state,
        ),
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      final message = state.error != null ? '${state.error}' : (l10n?.pageNotFound ?? '');
      return Scaffold(
        body: Center(
          child: Text(message),
        ),
      );
    },
  );
}
