import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/card_model.dart';
import '../data/models/group_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/groups_provider.dart';
import '../quiz/display_english.dart';
import '../quiz/quiz_mode.dart';
import '../quiz/quiz_options.dart';
import '../quiz/quiz_utils.dart';
import '../quiz/session_finalize.dart';
import '../quiz/session_notifier.dart';
import '../quiz/session_state.dart';
import '../router/app_router.dart';
import '../shared/ui/app_button.dart';
import '../utils/group_label.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_scaffold.dart';
import '../shared/ui/app_text_field.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  final _writeController = TextEditingController();
  final _random = Random();
  bool _hasFinalized = false;
  /// When non-null, user just answered wrong; show this correct answer and Next.
  String? _wrongFeedback;
  /// Display form of correct answer (Ti/Vi expanded in English). Shown in UI.
  String? _wrongFeedbackDisplay;
  /// In Write mode, what the user typed when they got it wrong (for result screen).
  String? _wrongUserTypedAnswer;
  /// Text to show as "the answer you gave" in wrong-feedback block (all modes).
  String? _wrongUserAnswerDisplay;

  @override
  void dispose() {
    _writeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);
    final asyncGroups = ref.watch(groupsProvider);

    ref.listen<SessionState?>(sessionProvider, (prev, next) {
      if (next != null && next.isFinished && !_hasFinalized) {
        _hasFinalized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await persistSessionToDailyActivity(ref);
          if (mounted) context.go(AppRoutes.result);
        });
      }
    });

    if (session == null) {
      // Session ended - navigation should already be handled by exit button
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (session.isFinished) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = session.currentCard!;
    GroupModel? group;
    final groupsList = asyncGroups.valueOrNull;
    final lookupId = session.sessionType == SessionType.agreement
        ? session.adjectiveGroupId
        : session.groupId;
    if (lookupId != null && groupsList != null) {
      try {
        group = groupsList.firstWhere((g) => g.id == lookupId);
      } catch (_) {
        group = null;
      }
    }

    final bool needGroupForContent = session.sessionType != SessionType.agreement;
    if (needGroupForContent && group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final title = group != null
        ? groupLabel(l10n, group.labelKey)
        : (session.sessionType == SessionType.agreement
            ? l10n.parentAgreement
            : '');
    final allCardsForOptions = session.sessionType == SessionType.agreement
        ? session.queue
        : (group!.cards);
    final promptText = _buildPromptText(card, session.mode, l10n);
    final correctAnswer = session.mode == QuizMode.serbianShown
        ? card.english
        : card.serbianAnswer;

    return AppScaffold(
      title: title,
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.exitSession,
          onPressed: () => _showExitConfirm(context, ref, l10n),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.correctCount(session.correctCount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  l10n.questionsLeft(session.queue.length),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Center(
                child: Text(
                  promptText,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_wrongFeedback != null) ...[
              Text(
                l10n.wrong,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${session.mode == QuizMode.write ? l10n.youWrote : l10n.youPicked} ${(_wrongUserAnswerDisplay ?? '').isEmpty ? l10n.emptyAnswer : _wrongUserAnswerDisplay}',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.correctAnswerLabel} ${_wrongFeedbackDisplay ?? _wrongFeedback}',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.next,
                onPressed: () => _onNextAfterWrong(ref),
              ),
            ] else if (session.mode == QuizMode.write) ...[
              Text(
                l10n.yourAnswer,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _writeController,
                onSubmitted: (_) => _submitWrite(context, ref),
                autofocus: true,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.submit,
                onPressed: () => _submitWrite(context, ref),
              ),
            ] else ...[
              ..._buildOptions(
                context,
                session.mode,
                card,
                correctAnswer,
                allCardsForOptions,
                ref,
                l10n,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExitConfirm(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final sessionContext = context;
    final theme = Theme.of(context);
    // Capture origin route and scroll offset before showing dialog (in case session is modified)
    final session = ref.read(sessionProvider);
    final originRoute = session?.originRoute ?? AppRoutes.home;
    final scrollOffset = session?.originScrollOffset ?? 0.0;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.exitSession,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(l10n.exitSessionConfirm, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      ref.read(scrollOffsetToRestoreProvider.notifier).state = scrollOffset;
                      ref.read(sessionProvider.notifier).endSession();
                      ref.read(selectedGroupProvider.notifier).state = null;
                      if (sessionContext.mounted) {
                        sessionContext.go(originRoute);
                      }
                    },
                    child: Text(l10n.exit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNextAfterWrong(WidgetRef ref) {
    ref.read(sessionProvider.notifier).answerWrong(userTypedAnswer: _wrongUserTypedAnswer);
    setState(() {
      _wrongFeedback = null;
      _wrongFeedbackDisplay = null;
      _wrongUserTypedAnswer = null;
      _wrongUserAnswerDisplay = null;
    });
  }

  String _buildPromptText(CardModel card, QuizMode mode, AppLocalizations l10n) {
    if (card is EndingCard) {
      return mode == QuizMode.serbianShown
          ? '${card.pronoun} ${card.serbian}'
          : displayEnglishForCard(card, l10n);
    }
    return mode == QuizMode.serbianShown ? card.serbian : card.english;
  }

  List<Widget> _buildOptions(
    BuildContext context,
    QuizMode mode,
    CardModel correctCard,
    String correctAnswer,
    List<CardModel> allCards,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    if (mode == QuizMode.serbianShown) {
      final optionCards = buildMultipleChoiceOptionCards(
        correctCard: correctCard,
        allCards: allCards,
        random: _random,
      );
      return optionCards
          .map(
            (optionCard) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => _onOptionSelectedSerbianShown(context, ref, correctCard, optionCard, l10n),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: theme.colorScheme.onSurface,
                    width: 2,
                  ),
                ),
                child: Text(displayEnglishForCard(optionCard, l10n)),
              ),
            ),
          )
          .toList();
    }
    final options = buildMultipleChoiceOptions(
      mode: mode,
      correctAnswer: correctAnswer,
      allCards: allCards,
      random: _random,
    );
    return options
        .map(
          (opt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => _onOptionSelectedEnglishShown(context, ref, correctAnswer, opt, l10n),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(
                  color: theme.colorScheme.onSurface,
                  width: 2,
                ),
              ),
              child: Text(opt),
            ),
          ),
        )
        .toList();
  }

  void _onOptionSelectedSerbianShown(
    BuildContext context,
    WidgetRef ref,
    CardModel correctCard,
    CardModel chosenCard,
    AppLocalizations l10n,
  ) {
    if (identical(chosenCard, correctCard)) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      setState(() {
        _wrongFeedback = correctCard.english;
        _wrongFeedbackDisplay = displayEnglishForCard(correctCard, l10n);
        _wrongUserTypedAnswer = null;
        _wrongUserAnswerDisplay = displayEnglishForCard(chosenCard, l10n);
      });
    }
  }

  void _onOptionSelectedEnglishShown(
    BuildContext context,
    WidgetRef ref,
    String correctAnswer,
    String chosen,
    AppLocalizations l10n,
  ) {
    if (chosen == correctAnswer) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      setState(() {
        _wrongFeedback = correctAnswer;
        _wrongFeedbackDisplay = correctAnswer;
        _wrongUserTypedAnswer = null;
        _wrongUserAnswerDisplay = chosen;
      });
    }
  }

  void _submitWrite(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionProvider);
    if (session == null || session.currentCard == null) return;
    final card = session.currentCard!;
    final correctAnswer = session.mode == QuizMode.serbianShown
        ? card.english
        : card.serbianAnswer;
    final raw = _writeController.text.trim();
    final normalized = normalizeForComparison(raw);
    final expected = normalizeForComparison(correctAnswer);
    if (normalized == expected) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      final l10n = AppLocalizations.of(context)!;
      final display = session.mode == QuizMode.serbianShown
          ? displayEnglishForCard(card, l10n)
          : correctAnswer;
      setState(() {
        _wrongFeedback = correctAnswer;
        _wrongFeedbackDisplay = display;
        _wrongUserTypedAnswer = raw;
        _wrongUserAnswerDisplay = raw;
      });
    }
    _writeController.clear();
  }
}
