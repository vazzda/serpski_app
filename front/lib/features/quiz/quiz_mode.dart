/// Quiz mode: what is shown and how user answers.
enum QuizMode {
  /// Card shows target language; user picks native from 4 options.
  targetShown,

  /// Card shows native language; user picks target from 4 options.
  nativeShown,

  /// Card shows native language; user types target.
  write,
}
