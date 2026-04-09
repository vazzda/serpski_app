import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/vessel_themes.dart';

const _prefKey = 'app_theme';

/// Theme selection provider.
final themeProvider = StateProvider<AppTheme>((ref) {
  return AppTheme.theme01;
});

/// Load theme from SharedPreferences.
Future<AppTheme> loadAppTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(_prefKey);
  if (value != null) {
    return AppThemeExtension.fromString(value);
  }
  return AppTheme.theme01;
}

/// Save theme to SharedPreferences.
Future<void> saveAppTheme(AppTheme theme) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefKey, theme.name);
}
