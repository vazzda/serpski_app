# Rename: Concept → Term, Session → Round

## Context
Two entity names are too abstract and don't match how a language learner thinks about them.
- **Concept** (language-agnostic vocabulary unit) → **Term** — natural dictionary nomenclature, covers words and phrases
- **Session** (quiz run over a deck) → **Round** — short, game-like, clear start/end

This is a mechanical rename across code, JSON data, DB schema, l10n, and file names. No logic changes.

## DB Migration Note
Current `_onUpgrade` is prototyping mode: drops all tables, recreates. Bumping `databaseVersion` from 5 → 6 wipes local data. No complex ALTER TABLE needed.

---

## Phase 1 — JSON Data Files

| File | Change |
|------|--------|
| `assets/data/dictionary.json` | Top-level key `"concepts"` → `"terms"` |
| `assets/data/levels.json` | Inside each deck object: `"concepts": [...]` → `"terms": [...]` |

## Phase 2 — File Renames (7 files)

| Old | New |
|-----|-----|
| `lib/entities/language/concept.dart` | `lib/entities/language/term.dart` |
| `lib/features/quiz/session_state.dart` | `lib/features/quiz/round_state.dart` |
| `lib/features/quiz/session_notifier.dart` | `lib/features/quiz/round_notifier.dart` |
| `lib/features/quiz/services/quiz_session_service.dart` | `lib/features/quiz/services/quiz_round_service.dart` |
| `lib/features/quiz/agreement_session_builder.dart` | `lib/features/quiz/agreement_round_builder.dart` |
| `lib/shared/repositories/models/session_record.dart` | `lib/shared/repositories/models/round_record.dart` |
| `lib/pages/session_screen.dart` | `lib/pages/round_screen.dart` |

## Phase 3 — Entity & Model Layer

### 3a. `lib/entities/language/term.dart` (was concept.dart)
- `class Concept` → `class Term`
- `Concept.fromJson` → `Term.fromJson`

### 3b. `lib/entities/language/dictionary.dart`
- Import: `concept.dart` → `term.dart`
- `Map<String, Concept> concepts` → `Map<String, Term> terms`
- `Set<String> get conceptIds` → `Set<String> get termIds`
- `fromJson`: parse `json['terms']` instead of `json['concepts']`

### 3c. `lib/entities/deck/vocab_deck_model.dart`
- `List<String> conceptIds` → `List<String> termIds`
- `fromJson`: read `json['terms']` instead of `json['concepts']`

### 3d. `lib/entities/card/vocab_card.dart`
- `String conceptId` → `String termId`
- `String get wordId => termId;` (wordId stays — it's a progress-tracking alias)
- Update super calls in `SimpleVocabCard`, `PairVocabCard`

### 3e. `lib/entities/language/language_pack.dart`
- `int totalConcepts` → `int totalTerms`
- `int get missingCount` → uses `totalTerms`
- `bool get isComplete` → uses `totalTerms`
- `missingConcepts(Set<String> allConceptIds)` → `missingTerms(Set<String> allTermIds)`

### 3f. `lib/shared/repositories/models/round_record.dart` (was session_record.dart)
- `class SessionRecord` → `class RoundRecord`
- `SessionRecord.fromMap` → `RoundRecord.fromMap`

### 3g. `lib/shared/repositories/models/deck_progress.dart`
- `List<SessionRecord> recentSessions` → `List<RoundRecord> recentRounds`
- `DateTime? lastSessionDate` → `DateTime? lastRoundDate`
- Update `copyWith`, `toMap`, `fromMap` — all serialization keys: `'recentSessions'` → `'recentRounds'`, `'lastSessionDate'` → `'lastRoundDate'`

## Phase 4 — DB Schema & Repository Layer

### 4a. `lib/shared/repositories/db_schema.dart`
- `tableSessionRecords = 'session_records'` → `tableRoundRecords = 'round_records'`
- `colLastSessionDate = 'last_session_date'` → `colLastRoundDate = 'last_round_date'`
- `colConceptsTouchedIds = 'concepts_touched_ids'` → `colTermsTouchedIds = 'terms_touched_ids'`

### 4b. `lib/app/providers/database_provider.dart`
- DDL references: use new `DbSchema` constants (automatic via constants)
- Bump `databaseVersion` 5 → 6 in `lib/shared/lib/constants.dart`

### 4c. `lib/shared/repositories/language_stats_repository.dart`
- `getConceptsTouched()` → `getTermsTouched()`
- `addConceptsTouched()` → `addTermsTouched()`
- Column refs: `colTermsTouchedIds`

### 4d. `lib/shared/repositories/deck_progress_repository.dart`
- `recordSession()` → `recordRound()`
- `_insertSessionRecord()` → `_insertRoundRecord()`
- `_getRecentSessions()` → `_getRecentRounds()`
- All `SessionRecord` → `RoundRecord`
- All `colLastSessionDate` → `colLastRoundDate`
- All `tableSessionRecords` → `tableRoundRecords`
- `sessionScore` param → `roundScore`

### 4e. `lib/shared/repositories/daily_activity_repository.dart`
- `addSession()` → `addRound()`

### 4f. `lib/shared/repositories/dictionary_repository.dart`
- `conceptsJson` variable → `termsJson`
- `'concepts':` merge key → `'terms':`
- `dictionary.concepts.length` → `dictionary.terms.length`
- Comment update

## Phase 5 — Quiz Feature Layer

### 5a. `lib/features/quiz/round_state.dart` (was session_state.dart)
- `enum SessionType` → `enum RoundType`
- `class SessionState` → `class RoundState`
- `sessionType` → `roundType`
- `totalDeckConcepts` → `totalDeckTerms`
- `sessionConceptCount` → `roundTermCount`
- `sessionWordIds` → `roundWordIds`
- Update `copyWith` params

### 5b. `lib/features/quiz/round_notifier.dart` (was session_notifier.dart)
- `class SessionNotifier` → `class RoundNotifier`
- `StateNotifier<SessionState?>` → `StateNotifier<RoundState?>`
- `SessionState(...)` → `RoundState(...)`
- `SessionType.*` → `RoundType.*`
- `endSession()` → `endRound()`
- `sessionProvider` → `roundProvider`
- All field refs updated

### 5c. `lib/features/quiz/services/quiz_round_service.dart` (was quiz_session_service.dart)
- `class QuizSessionService` → `class QuizRoundService`
- `persistSession()` → `persistRound()`
- `endSession()` → `endRound()`
- `lastSessionContributed` → `lastRoundContributed`
- `_persistTestSession()` → `_persistTestRound()`
- `_persistTrainingSession()` → `_persistTrainingRound()`
- `sessionProvider` → `roundProvider`
- `quizSessionServiceProvider` → `quizRoundServiceProvider`
- `sessionScore` → `roundScore`
- `session.totalDeckConcepts` → `round.totalDeckTerms`
- `session.sessionConceptCount` → `round.roundTermCount`

### 5d. `lib/features/quiz/agreement_round_builder.dart` (was agreement_session_builder.dart)
- `sessionGender` → `roundGender`
- Comments

## Phase 6 — Provider Layer

### 6a. `lib/app/providers/deck_progress_provider.dart`
- `recordSession()` → `recordRound()`
- `sessionScore` → `roundScore`

### 6b. `lib/app/providers/daily_activity_provider.dart`
- Comment: "session" → "round"

### 6c. `lib/app/providers/all_languages_progress_provider.dart`
- Comments: "session" → "round"

### 6d. `lib/app/providers/groups_provider.dart`
- Comments: "session" → "round"

## Phase 7 — Screens & UI

### 7a. `lib/pages/round_screen.dart` (was session_screen.dart)
- `class SessionScreen` → `class RoundScreen`
- `_SessionScreenState` → `_RoundScreenState`
- All `session` variables → `round`
- All `sessionProvider` → `roundProvider`
- `quizSessionServiceProvider` → `quizRoundServiceProvider`
- `SessionState` → `RoundState`, `SessionType` → `RoundType`
- `AppRoutes.session` → `AppRoutes.round`
- Update imports

### 7b. `lib/pages/result_screen.dart`
- All `session` variables → `round`
- All provider/type/route refs updated
- Import updates

### 7c. `lib/pages/vocab_deck_list_screen.dart`
- `recentSessions` → `recentRounds`
- `lastSessionDate` → `lastRoundDate`
- `sessionProvider` → `roundProvider`
- `AppRoutes.session` → `AppRoutes.round`
- `deck.conceptIds` → `deck.termIds`
- `withSessions` → `withRounds`

### 7d. `lib/pages/group_list_screen.dart`
- Same pattern: sessions → rounds, provider/route refs

### 7e. `lib/pages/agreement_group_list_screen.dart`
- Same pattern

### 7f. `lib/pages/language_screen.dart`
- `l10n.language_conceptsCount` → `l10n.language_termsCount`
- `p.totalConcepts` → `p.totalTerms`

## Phase 8 — Layout, Validator & Utils

### 8a. `lib/app/layout/vessel_layout.dart`
- Comment `// SESSION` → `// ROUND`
- `sessionScoreToCardGap` → `roundScoreToCardGap`

### 8b. `lib/shared/validators/config_validator.dart`
- All `concept*` variables → `term*`
- `data['concepts']` → `data['terms']`
- `json['concepts']` → `json['terms']`
- Error message strings: "concept" → "term"

### 8c. `lib/shared/lib/progress_constants.dart`
- Comments only

### 8d. `lib/shared/lib/progress_calculator.dart`
- `recentSessions` → `recentRounds`
- Loop variable `session` → `round`
- `session.date`, `session.score` → `round.date`, `round.score`

## Phase 9 — Router

### 9a. `lib/app/router/app_router.dart`
- `static const String session = '/session'` → `static const String round = '/round'`
- `SessionScreen()` → `RoundScreen()`
- Import update

## Phase 10 — Localization

### 10a. `lib/l10n/app_en.arb` (source of truth)

| Old Key | New Key | Old Value | New Value |
|---------|---------|-----------|-----------|
| `vocab_conceptsCount` | `vocab_termsCount` | `"...1 concept...concepts..."` | `"...1 term...terms..."` |
| `chooseQuestionsCount` | (keep) | `"How many concepts?"` | `"How many terms?"` |
| `language_conceptsMissing` | `language_termsMissing` | `"{count} missing"` | (keep value) |
| `language_conceptsCount` | `language_termsCount` | `"{done}/{total} concepts"` | `"{done}/{total} terms"` |
| `agreementSessionGender` | `agreementRoundGender` | (keep value) | (keep value) |
| `exitSession` | `exitRound` | `"Exit session"` | `"Exit round"` |
| `exitSessionConfirm` | `exitRoundConfirm` | `"Exit session?..."` | `"Exit round?..."` |
| `resultTitle` | (keep) | `"Session result"` | `"Round result"` |

### 10b. Regenerate: `flutter gen-l10n`
Generated files `app_localizations.dart` and `app_localizations_en.dart` will update automatically.

### 10c. Update all l10n call sites in screens
- `l10n.vocab_conceptsCount` → `l10n.vocab_termsCount`
- `l10n.language_conceptsCount` → `l10n.language_termsCount`
- `l10n.language_conceptsMissing` → `l10n.language_termsMissing`
- `l10n.agreementSessionGender` → `l10n.agreementRoundGender`
- `l10n.exitSession` → `l10n.exitRound`
- `l10n.exitSessionConfirm` → `l10n.exitRoundConfirm`

## Phase 11 — Language Reset Service

### 11a. `lib/features/language/services/language_reset_service.dart`
- Comment: `session_records` → `round_records`

## Phase 12 — Scripts & Docs

### 12a. `scripts/migrate_dictionary.py`
- `generate_concept_id()` → `generate_term_id()`
- `concepts = OrderedDict()` → `terms = OrderedDict()`
- `existing_concept_ids` → `existing_term_ids`
- `serbian_to_concepts` → `serbian_to_terms`
- `aspect_pair_concepts` → `aspect_pair_terms`
- `group_concept_ids` → `group_term_ids`
- `concept_id` local var → `term_id`
- Output JSON: `"concepts": {...}` → `"terms": {...}`
- Group output: `"concepts": group_concept_ids` → `"terms": group_term_ids`
- All print/comment strings: "concept" → "term"

### 12b. `docs/config_validation_plan.md`
- All references to `concepts`, `conceptIds`, `concept_id` → `terms`, `termIds`, `term_id`
- All references to `session_records` → `round_records`
- All references to `last_session_date` → `last_round_date`
- All references to `concepts_touched_ids` → `terms_touched_ids`
- Error message examples: "concept" → "term"

## Verification
1. `flutter gen-l10n` — regenerates l10n without errors
2. `flutter analyze` — zero errors, zero warnings from the rename
3. Full build check
