import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme for the app. All colors and text styles come from here.
/// Do not use raw colors or fonts in feature code. Modify colors here only.
class AppTheme {
  AppTheme._();

  /// Mild yellow for scaffold/app background. Change here to tweak app-wide bg.
  static const Color scaffoldBackground = Color(0xFFEEDC82);

  /// Black 2px border for cards, list tiles, app bar bottom.
  static const Color borderBlack = Color(0xFF000000);

  /// Outline for text fields, outlined buttons, dividers. Change here to tweak.
  static const Color outline = Color(0xFF000000);
  /// Lighter outline (e.g. disabled, subtle borders). Change here to tweak.
  static const Color outlineVariant = Color(0xFF757575);

  /// Primary (buttons, links). Change here to tweak primary actions.
  static const Color primary = Colors.black;
  static const Color onPrimary = Colors.white;

  /// Secondary (e.g. secondary buttons).
  static const Color secondary = Colors.black;
  static const Color onSecondary = Colors.white;

  /// Surface (cards, dialogs, inputs).
  static const Color surface = Colors.white;

  /// Main text and icons on surface.
  static const Color onSurface = Colors.black;

  /// Muted/secondary text on surface (e.g. "Today" body, list subtitles).
  static const Color onSurfaceVariant = Colors.black;

  /// Error (wrong answers, destructive).
  static const Color error = Color(0xFFC62828);
  static const Color onError = Colors.white;

  /// Primary container (e.g. selected choice chip background).
  static const Color primaryContainer = Color(0xFFE0E0E0);
  static const Color onPrimaryContainer = Colors.black87;

  // ─────────────────────────────────────────────────────────────────────────
  // Test badge colors (for date labels based on how old the test is)
  // ─────────────────────────────────────────────────────────────────────────

  /// Badge background color.
  static const Color testBadgeBackground = Colors.black;

  /// Badge percentage text color.
  static const Color testBadgePercentage = Colors.white;

  /// Badge date text: recent (within 2 weeks).
  static const Color testBadgeDateRecent = Color(0xFF9E9E9E);

  /// Badge date text: stale (2 weeks to 1 month).
  static const Color testBadgeDateStale = Colors.white;

  /// Badge date text: old (over 1 month).
  static const Color testBadgeDateOld = Color(0xFFC62828);

  static ColorScheme get _lightColorScheme =>
      ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onError,
      ).copyWith(
        onSurfaceVariant: onSurfaceVariant,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        outline: outline,
        outlineVariant: outlineVariant,
      );

  static TextTheme get _baseTextTheme => TextTheme(
    headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: const TextStyle(fontSize: 16),
    bodyMedium: const TextStyle(fontSize: 14),
    bodySmall: const TextStyle(fontSize: 12),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
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
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _lightColorScheme.primary,
        circularTrackColor: outlineVariant,
      ),
      iconTheme: IconThemeData(
        color: _lightColorScheme.onSurface,
      ),
    );
  }
}
