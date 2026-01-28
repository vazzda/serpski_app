import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../data/models/group_model.dart';
import '../quiz/quiz_mode.dart';
import '../quiz/session_notifier.dart';
import '../providers/groups_provider.dart';
import '../router/app_router.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_scaffold.dart';

String _groupLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'groupWords':
      return l10n.groupWords;
    case 'groupEndingsImEAti':
      return l10n.groupEndingsImEAti;
    case 'groupEndingsImEEti':
      return l10n.groupEndingsImEEti;
    case 'groupEndingsImEIti':
      return l10n.groupEndingsImEIti;
    case 'groupEndingsAmAju':
      return l10n.groupEndingsAmAju;
    case 'groupEndingsEmUGati':
      return l10n.groupEndingsEmUGati;
    case 'groupEndingsEmUHati':
      return l10n.groupEndingsEmUHati;
    case 'groupEndingsEmUKati':
      return l10n.groupEndingsEmUKati;
    case 'groupEndingsEmUAvati':
      return l10n.groupEndingsEmUAvati;
    case 'groupEndingsEmUIvati':
      return l10n.groupEndingsEmUIvati;
    case 'groupEndingsEmUOvati':
      return l10n.groupEndingsEmUOvati;
    case 'groupEndingsEmUCi':
      return l10n.groupEndingsEmUCi;
    case 'groupEndingsEmEju':
      return l10n.groupEndingsEmEju;
    default:
      return labelKey;
  }
}

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncGroups = ref.watch(groupsProvider);

    return AppScaffold(
      title: l10n.appBarTitle,
      child: asyncGroups.when(
        data: (groups) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            final label = _groupLabel(l10n, group.labelKey);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () => _onGroupTap(context, ref, group, l10n),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(l10n.loadError),
        ),
      ),
    );
  }

  Future<void> _onGroupTap(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    AppLocalizations l10n,
  ) async {
    ref.read(selectedGroupProvider.notifier).state = group;

    final mode = await _showModeBottomSheet(context, l10n);
    if (mode == null || !context.mounted) return;

    final count = await _showCountBottomSheet(context, l10n);
    if (count == null || !context.mounted) return;

    ref.read(sessionProvider.notifier).start(
          group: group,
          mode: mode,
          questionCount: count,
        );
    if (context.mounted) context.go(AppRoutes.session);
  }
}

Future<QuizMode?> _showModeBottomSheet(
  BuildContext context,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final noBorderListTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  return showModalBottomSheet<QuizMode>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Theme(
          data: theme.copyWith(listTileTheme: noBorderListTileTheme),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n.chooseMode,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ListTile(
                title: Text(l10n.modeSerbianShown),
                onTap: () => Navigator.of(context).pop(QuizMode.serbianShown),
              ),
              ListTile(
                title: Text(l10n.modeEnglishShown),
                onTap: () => Navigator.of(context).pop(QuizMode.englishShown),
              ),
              ListTile(
                title: Text(l10n.modeWrite),
                onTap: () => Navigator.of(context).pop(QuizMode.write),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<int?> _showCountBottomSheet(
  BuildContext context,
  AppLocalizations l10n,
) {
  final theme = Theme.of(context);
  final noBorderListTileTheme = ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  final counts = [5, 10, 20, 50];
  final labels = [l10n.questions5, l10n.questions10, l10n.questions20, l10n.questions50];
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Theme(
          data: theme.copyWith(listTileTheme: noBorderListTileTheme),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n.chooseQuestionsCount,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              ...List.generate(4, (i) {
                return ListTile(
                  title: Text(labels[i]),
                  onTap: () => Navigator.of(context).pop(counts[i]),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
