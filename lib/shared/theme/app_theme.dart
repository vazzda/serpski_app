import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme for the app. All colors and text styles come from here.
/// Do not use raw colors or fonts in feature code.
class AppTheme {
  AppTheme._();

  /// Mild yellow for scaffold/app background. Change here to tweak app-wide bg.
  static const Color scaffoldBackground = Color.fromARGB(255, 251, 236, 93);

  /// Black 2px border for cards, list tiles, app bar bottom.
  static const Color borderBlack = Color(0xFF000000);

  static ColorScheme get _lightColorScheme => ColorScheme.fromSeed(
    seedColor: Colors.black,
    brightness: Brightness.light,
    primary: Colors.black87,
    onPrimary: Colors.white,
    secondary: Colors.black87,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black87,
    error: const Color(0xFFC62828),
    onError: Colors.white,
  );

  static TextTheme get _baseTextTheme => TextTheme(
    headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: const TextStyle(fontSize: 16),
    bodyMedium: const TextStyle(fontSize: 14),
    labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  );

  /// Default app text: Roboto Mono.
  static TextTheme get _textTheme =>
      GoogleFonts.robotoMonoTextTheme(_baseTextTheme);

  /// Header (AppBar title): Big Shoulders Display, +8px vs titleLarge. Display title in uppercase at use site.
  static TextStyle get headerTextStyle =>
      GoogleFonts.bigShouldersDisplay(
        textStyle: _baseTextTheme.titleLarge,
      ).copyWith(
        color: _lightColorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 28,
      );

  static ThemeData get light {
    final textTheme = _textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scaffoldBackground,
        foregroundColor: _lightColorScheme.onSurface,
        elevation: 0,
        titleTextStyle: headerTextStyle,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderBlack, width: 2),
        ),
        color: _lightColorScheme.surface,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderBlack, width: 2),
        ),
      ),
    );
  }
}
