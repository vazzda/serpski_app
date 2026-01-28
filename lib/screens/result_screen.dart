import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/card_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/groups_provider.dart';
import '../quiz/session_notifier.dart';
import '../router/app_router.dart';
import '../shared/ui/app_button.dart';
import '../shared/ui/app_card.dart';
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
            if (session.missedCards.isNotEmpty) ...[
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
              ...session.missedCards.map((card) => _MissedCardTile(card: card)),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: l10n.backToGroups,
              onPressed: () {
                ref.read(sessionProvider.notifier).endSession();
                ref.read(selectedGroupProvider.notifier).state = null;
                context.go(AppRoutes.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MissedCardTile extends StatelessWidget {
  const _MissedCardTile({required this.card});

  final CardModel card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
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
                card.english,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
