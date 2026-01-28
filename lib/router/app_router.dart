import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../screens/group_list_screen.dart';
import '../screens/result_screen.dart';
import '../screens/session_screen.dart';

/// Route names/paths.
class AppRoutes {
  static const String home = '/';
  static const String session = '/session';
  static const String result = '/result';
}

/// GoRouter config. Session and result read from Riverpod.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const GroupListScreen(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => const ResultScreen(),
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
