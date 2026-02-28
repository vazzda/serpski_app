// ---------------------------------------------------------------------------
// Layout constants — all numeric dimensions in one place for easy finetuning
// ---------------------------------------------------------------------------

abstract class VocabLayout {
  // Screen list
  static const double listPadding = 16.0;
  static const double dailyCardBottomGap = 12.0;
  static const double levelCardBottomGap = 12.0;

  // Daily activity card
  static const double dailyCardTitleGap = 4.0;

  // Level card internal spacing
  static const double levelCardPadding = 16.0;
  static const double headerToProgressGap = 8.0;
  static const double progressSpacingAfter = 18.0;
  static const double descSpacingAfter = 8.0;
  static const double tilesToStatsGap = 16.0;

  // Tile rows — Positioned offsets
  static const double tileNameTop = 8.0;
  static const double tileNameLeft = 8.0;
  static const double tileNameRight = 8.0;
  static const double tileWordsTop = 34.0;
  static const double tileWordsLeft = 8.0;
  static const double tileWordsRight = 8.0;
  static const double tileProgressBottom = 4.0;
  static const double tileProgressLeft = 8.0;
  static const double tileProgressRight = 8.0;
  static const double tileCounterBottom = 22.0;
  static const double tileCounterLeft = 8.0;
  static const double tileCounterRight = 8.0;

  // Tile progress row internals
  static const double tileProgressPercentGap = 4.0;
  static const double tileProgressPercentWidth = 28.0;

  // Level progress bar + counter + percentage
  static const double progressPercentGap = 4.0;
  static const double progressWordsWidth = 30.0;
  static const double progressPercentWidth = 30.0;

  // Stats row chips
  static const double chipPaddingH = 6.0;
  static const double chipPaddingV = 4.0;
  static const double chipSpacing = 4.0;
}
