import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/card_model.dart';
import '../data/models/group_model.dart';
import '../l10n/app_localizations.dart';
import '../quiz/quiz_mode.dart';
import '../quiz/quiz_options.dart';
import '../quiz/quiz_utils.dart';
import '../quiz/session_notifier.dart';
import '../providers/groups_provider.dart';
import '../router/app_router.dart';
import '../shared/ui/app_button.dart';
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
  /// When non-null, user just answered wrong; show this correct answer and Next.
  String? _wrongFeedback;

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

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (session.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.result);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final card = session.currentCard!;
    GroupModel? group;
    final groupsList = asyncGroups.valueOrNull;
    if (groupsList != null) {
      try {
        group = groupsList.firstWhere((g) => g.id == session.groupId);
      } catch (_) {
        group = null;
      }
    }

    if (group == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final promptText = _buildPromptText(card, session.mode);
    final correctAnswer = session.mode == QuizMode.serbianShown
        ? card.english
        : card.serbianAnswer;

    final theme = Theme.of(context);

    return AppScaffold(
      title: l10n.appTitle,
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
                '${l10n.correctAnswerLabel} $_wrongFeedback',
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
                onSubmitted: (_) => _submitWrite(ref),
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: l10n.submit,
                onPressed: () => _submitWrite(ref),
              ),
            ] else ...[
              ..._buildOptions(
                session.mode,
                correctAnswer,
                group.cards,
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
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitSession),
        content: Text(l10n.exitSessionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(sessionProvider.notifier).endSession();
              ref.read(selectedGroupProvider.notifier).state = null;
              if (sessionContext.mounted) {
                sessionContext.go(AppRoutes.home);
              }
            },
            child: Text(l10n.exit),
          ),
        ],
      ),
    );
  }

  void _onNextAfterWrong(WidgetRef ref) {
    ref.read(sessionProvider.notifier).answerWrong();
    setState(() => _wrongFeedback = null);
  }

  String _buildPromptText(CardModel card, QuizMode mode) {
    if (card is EndingCard) {
      return mode == QuizMode.serbianShown
          ? '${card.pronoun} ${card.serbian}'
          : card.english;
    }
    return mode == QuizMode.serbianShown ? card.serbian : card.english;
  }

  List<Widget> _buildOptions(
    QuizMode mode,
    String correctAnswer,
    List<CardModel> allCards,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
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
              onPressed: () => _onOptionSelected(ref, correctAnswer, opt),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(opt),
            ),
          ),
        )
        .toList();
  }

  void _onOptionSelected(WidgetRef ref, String correctAnswer, String chosen) {
    if (chosen == correctAnswer) {
      ref.read(sessionProvider.notifier).answerCorrect();
    } else {
      setState(() => _wrongFeedback = correctAnswer);
    }
  }

  void _submitWrite(WidgetRef ref) {
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
      setState(() => _wrongFeedback = correctAnswer);
    }
    _writeController.clear();
  }
}
