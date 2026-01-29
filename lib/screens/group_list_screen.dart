import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../data/daily_activity_repository.dart';
import '../data/models/group_model.dart';
import '../quiz/quiz_mode.dart';
import '../quiz/session_notifier.dart';
import '../providers/daily_activity_provider.dart';
import '../providers/groups_provider.dart';
import '../router/app_router.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_scaffold.dart';
import '../utils/group_label.dart';

enum ParentCategory { vocabulary, conjugations }

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.l10n,
    required this.theme,
    required this.onTap,
  });

  final GroupModel group;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = groupLabel(l10n, group.labelKey);
    final count = wordCount(group);
    final preview = groupPreviewText(group);
    final countText = preview.isNotEmpty
        ? l10n.wordsCountWithPreview(count, preview)
        : l10n.wordsCount(count);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  countText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final asyncStats = ref.watch(dailyActivityProvider);

    return AppScaffold(
      title: l10n.appBarTitle,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => context.push(AppRoutes.vocabulary),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.parentVocabulary,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => context.push(AppRoutes.conjugations),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.parentConjugations,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _DailyActivityWidget(
                asyncStats: asyncStats,
                l10n: l10n,
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyActivityWidget extends StatelessWidget {
  const _DailyActivityWidget({
    required this.asyncStats,
    required this.l10n,
    required this.theme,
  });

  final AsyncValue<DailyActivityStats> asyncStats;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final headerStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return AppCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dailyActivityTitle,
              style: headerStyle,
            ),
            const SizedBox(height: 4),
            asyncStats.when(
              data: (stats) {
                final isEmpty = stats.correct == 0 &&
                    stats.wrong == 0 &&
                    stats.wordsTouched == 0;
                return Text(
                  isEmpty
                      ? l10n.dailyActivityEmpty
                      : '${l10n.correctCount(stats.correct)} · ${l10n.wrongCount(stats.wrong)} · ${l10n.wordsCount(stats.wordsTouched)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle,
                );
              },
              loading: () => Text(
                l10n.dailyActivityEmpty,
                style: bodyStyle,
              ),
              // ignore: unnecessary_underscores
              error: (_, __) => Text(
                l10n.dailyActivityEmpty,
                style: bodyStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildGroupListScreen extends ConsumerWidget {
  const ChildGroupListScreen({super.key, required this.parent});

  final ParentCategory parent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncGroups = ref.watch(groupsProvider);
    final title = parent == ParentCategory.vocabulary
        ? l10n.parentVocabulary
        : l10n.parentConjugations;
    final filterType = parent == ParentCategory.vocabulary
        ? GroupType.words
        : GroupType.endings;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: AppScaffold(
        title: title,
        leading: BackButton(
          onPressed: () => context.go(AppRoutes.home),
        ),
        child: asyncGroups.when(
          data: (groups) {
            final childGroups = groups.where((g) => g.type == filterType).toList();
            final theme = Theme.of(context);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: childGroups.length,
              itemBuilder: (context, index) {
                final group = childGroups[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GroupTile(
                    group: group,
                    l10n: l10n,
                    theme: theme,
                    onTap: () => _onGroupTap(context, ref, group, l10n),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Text(l10n.loadError),
          ),
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
