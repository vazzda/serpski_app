import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Srpski Card'**
  String get appTitle;

  /// No description provided for @groupWords.
  ///
  /// In en, this message translates to:
  /// **'Words (infinitive ↔ English)'**
  String get groupWords;

  /// No description provided for @groupEndingsImEAti.
  ///
  /// In en, this message translates to:
  /// **'Endings: -ATI (IM|E)'**
  String get groupEndingsImEAti;

  /// No description provided for @groupEndingsImEEti.
  ///
  /// In en, this message translates to:
  /// **'Endings: -ETI (IM|E)'**
  String get groupEndingsImEEti;

  /// No description provided for @groupEndingsImEIti.
  ///
  /// In en, this message translates to:
  /// **'Endings: -ITI (IM|E)'**
  String get groupEndingsImEIti;

  /// No description provided for @groupEndingsAmAju.
  ///
  /// In en, this message translates to:
  /// **'Endings: -ATI (AM|AJU)'**
  String get groupEndingsAmAju;

  /// No description provided for @groupEndingsEmUGati.
  ///
  /// In en, this message translates to:
  /// **'Endings: -GATI (EM|U)'**
  String get groupEndingsEmUGati;

  /// No description provided for @groupEndingsEmUHati.
  ///
  /// In en, this message translates to:
  /// **'Endings: -HATI (EM|U)'**
  String get groupEndingsEmUHati;

  /// No description provided for @groupEndingsEmUKati.
  ///
  /// In en, this message translates to:
  /// **'Endings: -KATI (EM|U)'**
  String get groupEndingsEmUKati;

  /// No description provided for @groupEndingsEmUAvati.
  ///
  /// In en, this message translates to:
  /// **'Endings: -AVATI (EM|U)'**
  String get groupEndingsEmUAvati;

  /// No description provided for @groupEndingsEmUIvati.
  ///
  /// In en, this message translates to:
  /// **'Endings: -IVATI (EM|U)'**
  String get groupEndingsEmUIvati;

  /// No description provided for @groupEndingsEmUOvati.
  ///
  /// In en, this message translates to:
  /// **'Endings: -OVATI (EM|U)'**
  String get groupEndingsEmUOvati;

  /// No description provided for @groupEndingsEmUCi.
  ///
  /// In en, this message translates to:
  /// **'Endings: -ĆI (EM|U)'**
  String get groupEndingsEmUCi;

  /// No description provided for @groupEndingsEmEju.
  ///
  /// In en, this message translates to:
  /// **'Endings: -ETI (EM|EJU)'**
  String get groupEndingsEmEju;

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose mode'**
  String get chooseMode;

  /// No description provided for @modeSerbianShown.
  ///
  /// In en, this message translates to:
  /// **'Serbian shown (pick English)'**
  String get modeSerbianShown;

  /// No description provided for @modeEnglishShown.
  ///
  /// In en, this message translates to:
  /// **'English shown (pick Serbian)'**
  String get modeEnglishShown;

  /// No description provided for @modeWrite.
  ///
  /// In en, this message translates to:
  /// **'Write (type Serbian)'**
  String get modeWrite;

  /// No description provided for @chooseQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'How many questions?'**
  String get chooseQuestionsCount;

  /// No description provided for @questions5.
  ///
  /// In en, this message translates to:
  /// **'5'**
  String get questions5;

  /// No description provided for @questions10.
  ///
  /// In en, this message translates to:
  /// **'10'**
  String get questions10;

  /// No description provided for @questions20.
  ///
  /// In en, this message translates to:
  /// **'20'**
  String get questions20;

  /// No description provided for @questions50.
  ///
  /// In en, this message translates to:
  /// **'50'**
  String get questions50;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Session result'**
  String get resultTitle;

  /// No description provided for @correctCount.
  ///
  /// In en, this message translates to:
  /// **'Correct: {count}'**
  String correctCount(int count);

  /// No description provided for @wrongCount.
  ///
  /// In en, this message translates to:
  /// **'Wrong: {count}'**
  String wrongCount(int count);

  /// No description provided for @reviewWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed cards'**
  String get reviewWrongTitle;

  /// No description provided for @reviewWrongSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards you got wrong (Serbian → English)'**
  String get reviewWrongSubtitle;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @backToGroups.
  ///
  /// In en, this message translates to:
  /// **'Back to groups'**
  String get backToGroups;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load groups. Please try again.'**
  String get loadError;

  /// No description provided for @correctAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer:'**
  String get correctAnswerLabel;

  /// No description provided for @questionsLeft.
  ///
  /// In en, this message translates to:
  /// **'Left: {count}'**
  String questionsLeft(int count);

  /// No description provided for @exitSession.
  ///
  /// In en, this message translates to:
  /// **'Exit session'**
  String get exitSession;

  /// No description provided for @exitSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit session? Your progress will be lost.'**
  String get exitSessionConfirm;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
