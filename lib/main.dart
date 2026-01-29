import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/daily_activity_repository.dart';
import 'l10n/app_localizations.dart';
import 'providers/daily_activity_provider.dart';
import 'router/app_router.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  await Hive.initFlutter();
  final box = await Hive.openBox('daily_activity');
  final router = createAppRouter();
  runApp(
    ProviderScope(
      overrides: [
        dailyActivityRepositoryProvider.overrideWith(
          (ref) => DailyActivityRepository(box: box),
        ),
      ],
      child: SrpskiCardApp(router: router),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class SrpskiCardApp extends StatelessWidget {
  const SrpskiCardApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Srpski Card',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
