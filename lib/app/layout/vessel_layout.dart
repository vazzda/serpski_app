// ---------------------------------------------------------------------------
// Layout constants — all numeric dimensions in one place for easy finetuning.
// Analogous to VesselFonts (typography) and VesselThemeData (colors/radii).
// ---------------------------------------------------------------------------

const double _contentPaddingS = 8.0;

abstract class VesselLayout {
  // ==========================================================================
  // GAP SIZES (consumed by VesselGap)
  // ==========================================================================
  static const double gapXxs = 2.0;
  static const double gapXs = 4.0;
  static const double gapS = 8.0;
  static const double gapM = 12.0;
  static const double gapL = 16.0;
  static const double gapXl = 24.0;
  static const double gapXxl = 48.0;

  // ==========================================================================
  // COMMON
  // ==========================================================================
  static const double screenPadding = 16.0;
  static const double listItemGap = 12.0;
  static const double listItemGapSmall = 8.0;

  // ==========================================================================
  // APPBAR
  // ==========================================================================
  static const double appBarHeight = 40.0;

  // ==========================================================================
  // NAVBAR
  // ==========================================================================
  static const double navbarHeight = 40.0;
  static const double navbarIconPadding = 8.0;

  // ==========================================================================
  // CHIP (shared across group list / agreement / vocab stats)
  // ==========================================================================
  static const double chipPaddingH = 6.0;
  static const double chipPaddingV = 4.0;
  static const double chipSpacing = 4.0;

  // ==========================================================================
  // VOCAB — screen list
  // ==========================================================================
  static const double vocabListPadding = 16.0;
  static const double vocabDailyCardBottomGap = 12.0;
  static const double vocabLevelCardBottomGap = 12.0;

  // Vocab — tile sizing
  static const double vocabTileHeight = 180.0;
  static const double vocabTileMinWidth = 120.0;
  static const double vocabTileGap = 12.0;
  static const double vocabTileIconSize = 40.0;
  static const double deckIconPadding = 8.0;
  static const double deckIconTopOffset = -2.0;

  // Vocab — daily activity card
  static const double vocabDailyCardTitleGap = 4.0;

  // Vocab — level card internal spacing
  static const double vocabLevelCardPadding = 16.0;
  static const double vocabHeaderToProgressGap = 8.0;
  static const double vocabProgressSpacingAfter = 18.0;
  static const double vocabDescSpacingAfter = 8.0;
  static const double vocabTilesToStatsGap = 16.0;

  // Vocab — tile rows (Positioned offsets)
  static const double vocabTileHeaderTop = 10.0;
  static const double vocabTileHeaderLeft = _contentPaddingS;
  static const double vocabTileHeaderRight = _contentPaddingS;
  static const double vocabTileHeaderGap = 10.0;
  static const double vocabTileHeaderRowGap = 2.0;
  static const double vocabTileNameTop = 76.0;
  static const double vocabTileNameLeft = _contentPaddingS;
  static const double vocabTileNameRight = _contentPaddingS;
  static const double vocabTileWordsTop = 104.0;
  static const double vocabTileWordsLeft = _contentPaddingS;
  static const double vocabTileWordsRight = _contentPaddingS;

  // Vocab — tile progress row internals
  static const double vocabTileProgressPercentGap = 4.0;
  static const double vocabTileProgressPercentWidth = 28.0;

  // Vocab — level progress bar + counter + percentage
  static const double vocabProgressPercentGap = 4.0;
  static const double vocabProgressWordsWidth = 30.0;
  static const double vocabProgressPercentWidth = 30.0;

  // ==========================================================================
  // SESSION
  // ==========================================================================
  static const double sessionScoreToCardGap = 16.0;

  // ==========================================================================
  // RESULT
  // ==========================================================================
  static const double resultEntryPaddingV = 12.0;
  static const double resultEntryPaddingH = 16.0;

  // ==========================================================================
  // LANGUAGE
  // ==========================================================================
  static const double langFlagWidth = 64.0;
  static const double langFlagHeight = 44.0;
  static const double langProgressLabelWidth = 72.0;
  static const double langProgressPercentWidth = 36.0;
  static const double langArrowZoneWidth = 36.0;
  static const double langBoxPaddingLeft = 12.0;
  static const double langBoxPaddingTop = 14.0;
  static const double langBoxPaddingRight = 12.0;
  static const double langBoxPaddingBottom = 8.0;

  // ==========================================================================
  // WRAP (tag/chip grids)
  // ==========================================================================
  static const double wrapSpacing = 8.0;
  static const double wrapRunSpacing = 8.0;
}
