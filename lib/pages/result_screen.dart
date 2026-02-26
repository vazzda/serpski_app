import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../app/providers/groups_provider.dart';
import '../features/quiz/display_english.dart' show displayNativeForCard;
import '../features/quiz/services/quiz_session_service.dart';
import '../features/quiz/quiz_mode.dart';
import '../features/quiz/session_notifier.dart';
import '../features/quiz/session_state.dart';
import '../app/router/app_router.dart';
import '../app/theme/app_themes.dart';
import '../shared/ui/buttons/project_buttons.dart';
import '../shared/ui/card/project_card.dart';
import '../shared/ui/screen_layout/screen_layout_widget.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = AppThemes.of(context);
    final session = ref.watch(sessionProvider);

    if (session == null) {
      // Session ended - navigation should already be handled by Back/Again button
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ScreenLayoutWidget(
      title: l10n.resultTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProjectCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.correctCount(session.correctCount),
                    style: AppFontStyles.textContentHeader.copyWith(color: t.accentColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.wrongCount(session.wrongCount),
                    style: AppFontStyles.textContentHeader.copyWith(color: t.dangerColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AccentButton(
                    label: l10n.again,
                    onPressed: () {
                      final session = ref.read(sessionProvider);
                      if (session == null) return;

                      // Vocab sessions: restart from allCards
                      if (session.allCards != null) {
                        ref.read(sessionProvider.notifier).restartFromAllCards();
                        if (context.mounted) {
                          context.go(AppRoutes.session);
                        }
                        return;
                      }

                      // Agreement sessions
                      final groups = ref.read(groupsProvider).valueOrNull;
                      if (groups == null) return;
                      if (session.sessionType == SessionType.agreement) {
                        final adjId = session.adjectiveGroupId;
                        if (adjId == null) return;
                        try {
                          final adjGroup = groups.firstWhere(
                            (g) => g.id == adjId,
                          );
                          ref.read(sessionProvider.notifier).startAgreement(
                                adjectiveGroup: adjGroup,
                                allGroups: groups,
                                mode: session.mode,
                                questionCount: session.requestedCount,
                                originRoute: session.originRoute,
                              );
                          if (context.mounted) {
                            context.go(AppRoutes.session);
                          }
                        } catch (_) {}
                        return;
                      }

                      // Legacy tool sessions (conjugations)
                      try {
                        final group = groups.firstWhere(
                          (g) => g.id == session.groupId,
                        );
                        ref.read(sessionProvider.notifier).start(
                              group: group,
                              mode: session.mode,
                              questionCount: session.requestedCount,
                              originRoute: session.originRoute,
                            );
                        if (context.mounted) {
                          context.go(AppRoutes.session);
                        }
                      } catch (_) {}
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BaseButton(
                    label: l10n.back,
                    onPressed: () {
                      final originRoute =
                          ref.read(quizSessionServiceProvider).endSession();
                      if (context.mounted) {
                        context.go(originRoute);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (session.missedEntries.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                l10n.reviewWrongTitle,
                style: AppFontStyles.textContentHeader.copyWith(color: t.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.reviewWrongSubtitle,
                style: AppFontStyles.textBody.copyWith(color: t.textPrimary),
              ),
              const SizedBox(height: 12),
              ...session.missedEntries.map(
                (entry) => _MissedEntryTile(entry: entry, mode: session.mode),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MissedEntryTile extends StatelessWidget {
  const _MissedEntryTile({required this.entry, required this.mode});

  final MissedEntry entry;
  final QuizMode mode;

  @override
  Widget build(BuildContext context) {
    final t = AppThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final card = entry.card;

    final isWriteWithTyped = mode == QuizMode.write && entry.userTypedAnswer != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProjectCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: isWriteWithTyped
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.youWrote} ${entry.userTypedAnswer!.isEmpty ? l10n.emptyAnswer : entry.userTypedAnswer}',
                    style: AppFontStyles.textBodyLarge.copyWith(color: t.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.correctAnswerLabel} ${card.targetAnswer} → ${displayNativeForCard(card, l10n)}',
                    style: AppFontStyles.textBodyLargeAccented.copyWith(color: t.textPrimary),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      card.targetAnswer,
                      style: AppFontStyles.textBodyLargeAccented.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    ' → ',
                    style: AppFontStyles.textBodyLarge.copyWith(color: t.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      displayNativeForCard(card, l10n),
                      style: AppFontStyles.textBodyLarge.copyWith(color: t.textPrimary),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
