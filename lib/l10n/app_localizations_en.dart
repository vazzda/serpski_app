// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Srpski Card';

  @override
  String get appBarTitle => 'Srpski';

  @override
  String get groupWords => 'Words, infinitive';

  @override
  String get groupEndingsImEAti => '-ATI (IM|E)';

  @override
  String get groupEndingsImEEti => '-ETI (IM|E)';

  @override
  String get groupEndingsImEIti => '-ITI (IM|E)';

  @override
  String get groupEndingsAmAju => '-ATI (AM|AJU)';

  @override
  String get groupEndingsEmUGati => '-GATI (EM|U)';

  @override
  String get groupEndingsEmUHati => '-HATI (EM|U)';

  @override
  String get groupEndingsEmUKati => '-KATI (EM|U)';

  @override
  String get groupEndingsEmUAvati => '-AVATI (EM|U)';

  @override
  String get groupEndingsEmUIvati => '-IVATI (EM|U)';

  @override
  String get groupEndingsEmUOvati => '-OVATI (EM|U)';

  @override
  String get groupEndingsEmUCi => '-ĆI (EM|U)';

  @override
  String get groupEndingsEmEju => '-ETI (EM|EJU)';

  @override
  String get chooseMode => 'Choose mode';

  @override
  String get modeSerbianShown => 'Serbian shown (pick English)';

  @override
  String get modeEnglishShown => 'English shown (pick Serbian)';

  @override
  String get modeWrite => 'Write (type Serbian)';

  @override
  String get chooseQuestionsCount => 'How many questions?';

  @override
  String get questions5 => '5';

  @override
  String get questions10 => '10';

  @override
  String get questions20 => '20';

  @override
  String get questions50 => '50';

  @override
  String get start => 'Start';

  @override
  String get cancel => 'Cancel';

  @override
  String get next => 'Next';

  @override
  String get submit => 'Submit';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get resultTitle => 'Session result';

  @override
  String correctCount(int count) {
    return 'Correct: $count';
  }

  @override
  String wrongCount(int count) {
    return 'Wrong: $count';
  }

  @override
  String get reviewWrongTitle => 'Missed cards';

  @override
  String get reviewWrongSubtitle => 'Cards you got wrong (Serbian → English)';

  @override
  String get done => 'Done';

  @override
  String get backToGroups => 'Back to groups';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get loadError => 'Could not load groups. Please try again.';

  @override
  String get correctAnswerLabel => 'Correct answer:';

  @override
  String questionsLeft(int count) {
    return 'Left: $count';
  }

  @override
  String get exitSession => 'Exit session';

  @override
  String get exitSessionConfirm => 'Exit session? Your progress will be lost.';

  @override
  String get exit => 'Exit';
}
