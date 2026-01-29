import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/groups_provider.dart';
import '../quiz/display_english.dart';
import '../quiz/quiz_mode.dart';
import '../quiz/session_notifier.dart';
import '../quiz/session_state.dart';
import '../router/app_router.dart';
import '../shared/ui/app_button.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_outlined_button.dart';
import '../shared/ui/app_scaffold.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);

    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AppScaffold(
      title: l10n.resultTitle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.correctCount(session.correctCount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.wrongCount(session.wrongCount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
            if (session.missedEntries.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.reviewWrongTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.reviewWrongSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...session.missedEntries.map(
                (entry) => _MissedEntryTile(entry: entry, mode: session.mode),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l10n.again,
                    onPressed: () {
                      final session = ref.read(sessionProvider);
                      if (session == null) return;
                      final groups = ref.read(groupsProvider).valueOrNull;
                      if (groups == null) return;
                      try {
                        final group = groups.firstWhere(
                          (g) => g.id == session.groupId,
                        );
                        ref.read(sessionProvider.notifier).start(
                              group: group,
                              mode: session.mode,
                              questionCount: session.requestedCount,
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
                  child: AppOutlinedButton(
                    label: l10n.back,
                    onPressed: () {
                      ref.read(sessionProvider.notifier).endSession();
                      ref.read(selectedGroupProvider.notifier).state = null;
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final card = entry.card;

    final isWriteWithTyped = mode == QuizMode.write && entry.userTypedAnswer != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: isWriteWithTyped
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.youWrote} ${entry.userTypedAnswer!.isEmpty ? l10n.emptyAnswer : entry.userTypedAnswer}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.correctAnswerLabel} ${card.serbianAnswer} → ${displayEnglishForCard(card, l10n)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      card.serbianAnswer,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    ' → ',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Expanded(
                    child: Text(
                      displayEnglishForCard(card, l10n),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
