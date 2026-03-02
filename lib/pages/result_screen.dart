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
import '../app/theme/vessel_themes.dart';
import '../shared/ui/buttons/vessel_buttons.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/gap/vessel_gap.dart';
import '../shared/ui/note/vessel_note.dart';
import '../app/layout/vessel_layout.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final session = ref.watch(sessionProvider);

    if (session == null) {
      // Session ended - navigation should already be handled by Back/Again button
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return VesselScaffold(
      title: l10n.resultTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(VesselLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VesselCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.correctCount(session.correctCount),
                    style: VesselFonts.textContentHeader.copyWith(color: t.accentColor),
                  ),
                  const VesselGap.s(),
                  Text(
                    l10n.wrongCount(session.wrongCount),
                    style: VesselFonts.textContentHeader.copyWith(color: t.dangerColor),
                  ),
                ],
              ),
            ),
            const VesselGap.xl(),
            Row(
              children: [
                Expanded(
                  child: VesselAccentButton(
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
                          (g) => g.id == session.deckId,
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
                const VesselGap.hm(),
                Expanded(
                  child: VesselButton(
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
            if (!ref.read(quizSessionServiceProvider).lastSessionContributed) ...[
              const VesselGap.l(),
              VesselNote(text: l10n.result_techWork),
            ],
            if (session.missedEntries.isNotEmpty) ...[
              const VesselGap.xl(),
              Text(
                l10n.reviewWrongTitle,
                style: VesselFonts.textContentHeader.copyWith(color: t.textPrimary),
              ),
              const VesselGap.xs(),
              Text(
                l10n.reviewWrongSubtitle,
                style: VesselFonts.textBody.copyWith(color: t.textPrimary),
              ),
              const VesselGap.m(),
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
    final t = VesselThemes.of(context);
    final l10n = AppLocalizations.of(context)!;
    final card = entry.card;

    final isWriteWithTyped = mode == QuizMode.write && entry.userTypedAnswer != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: VesselLayout.listItemGapSmall),
      child: VesselCard(
        padding: const EdgeInsets.symmetric(vertical: VesselLayout.resultEntryPaddingV, horizontal: VesselLayout.resultEntryPaddingH),
        child: isWriteWithTyped
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.youWrote} ${entry.userTypedAnswer!.isEmpty ? l10n.emptyAnswer : entry.userTypedAnswer}',
                    style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
                  ),
                  const VesselGap.xs(),
                  Text(
                    '${l10n.correctAnswerLabel} ${card.targetAnswer} → ${displayNativeForCard(card, l10n)}',
                    style: VesselFonts.textBodyLargeAccented.copyWith(color: t.textPrimary),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      card.targetAnswer,
                      style: VesselFonts.textBodyLargeAccented.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    ' → ',
                    style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      displayNativeForCard(card, l10n),
                      style: VesselFonts.textBodyLarge.copyWith(color: t.textPrimary),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
