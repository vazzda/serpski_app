import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../data/daily_activity_repository.dart';
import '../data/models/group_model.dart';
import '../data/test_result_repository.dart';
import '../quiz/session_notifier.dart';
import '../providers/daily_activity_provider.dart';
import '../providers/groups_provider.dart';
import '../providers/test_result_provider.dart';
import '../router/app_router.dart';
import '../shared/theme/app_theme.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_scaffold.dart';
import '../shared/ui/quiz_bottom_sheets.dart';
import '../utils/group_label.dart';

enum ParentCategory { vocabulary, conjugations }

/// Returns relative date string and appropriate color for test badge.
({String text, Color color}) formatRelativeDate(
  DateTime date,
  AppLocalizations l10n,
) {
  final now = DateTime.now();
  final diff = now.difference(date);
  final days = diff.inDays;

  String text;
  Color color;

  if (days == 0) {
    text = l10n.relativeDateToday;
  } else if (days == 1) {
    text = l10n.relativeDateYesterday;
  } else if (days < 30) {
    text = l10n.relativeDateDays(days);
  } else if (days < 365) {
    final months = (days / 30).floor();
    text = l10n.relativeDateMonths(months);
  } else {
    final years = (days / 365).floor();
    text = l10n.relativeDateYears(years);
  }

  // Color based on age
  if (days <= 14) {
    color = AppTheme.testBadgeDateRecent;
  } else if (days <= 30) {
    color = AppTheme.testBadgeDateStale;
  } else {
    color = AppTheme.testBadgeDateOld;
  }

  return (text: text, color: color);
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.l10n,
    required this.theme,
    required this.onTap,
    this.testResult,
  });

  final GroupModel group;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onTap;
  final TestResult? testResult;

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
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label, style: theme.textTheme.titleMedium),
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
                    // Space reserved for badge (no arrow on session tiles)
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              // Test badge (if test was done)
              if (testResult != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _TestBadge(testResult: testResult!, l10n: l10n),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TestBadge extends StatelessWidget {
  const _TestBadge({required this.testResult, required this.l10n});

  final TestResult testResult;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateInfo = formatRelativeDate(testResult.date, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppTheme.testBadgeBackground,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${testResult.percentage}%',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.testBadgePercentage,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            dateInfo.text,
            style: TextStyle(color: dateInfo.color, fontSize: 9),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => context.push(AppRoutes.agreement),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.parentAgreement,
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
            Text(l10n.dailyActivityTitle, style: headerStyle),
            const SizedBox(height: 4),
            asyncStats.when(
              data: (stats) {
                final isEmpty =
                    stats.correct == 0 &&
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
              loading: () => Text(l10n.dailyActivityEmpty, style: bodyStyle),
              // ignore: unnecessary_underscores
              error: (_, __) => Text(l10n.dailyActivityEmpty, style: bodyStyle),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildGroupListScreen extends ConsumerStatefulWidget {
  const ChildGroupListScreen({super.key, required this.parent});

  final ParentCategory parent;

  @override
  ConsumerState<ChildGroupListScreen> createState() =>
      _ChildGroupListScreenState();
}

class _ChildGroupListScreenState extends ConsumerState<ChildGroupListScreen> {
  final _scrollController = ScrollController();
  double? _pendingScrollOffset;
  bool _scrollRestored = false;

  @override
  void initState() {
    super.initState();
    // Capture scroll offset to restore on init
    _pendingScrollOffset = ref.read(scrollOffsetToRestoreProvider);
    if (_pendingScrollOffset != null) {
      // Clear provider after widget tree is done building
      Future(() {
        if (mounted) {
          ref.read(scrollOffsetToRestoreProvider.notifier).state = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _restoreScrollPosition() {
    if (_pendingScrollOffset == null || _scrollRestored) return;
    _scrollRestored = true;
    final offset = _pendingScrollOffset!;
    _pendingScrollOffset = null;

    // Jump to saved position (clamped to valid range)
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncGroups = ref.watch(groupsProvider);
    final testResults = ref.watch(testResultsProvider);
    final title = widget.parent == ParentCategory.vocabulary
        ? l10n.parentVocabulary
        : l10n.parentConjugations;
    final filterType = widget.parent == ParentCategory.vocabulary
        ? GroupType.words
        : GroupType.endings;

    // When data loads and we have a pending scroll, schedule restore
    if (asyncGroups.hasValue &&
        _pendingScrollOffset != null &&
        !_scrollRestored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreScrollPosition();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: AppScaffold(
        title: title,
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        child: asyncGroups.when(
          data: (groups) {
            final childGroups = groups
                .where((g) => g.type == filterType)
                .toList();
            final theme = Theme.of(context);
            if (filterType == GroupType.endings) {
              return ListView.builder(
                controller: _scrollController,
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
                      testResult: testResults[group.id],
                      onTap: () => _onGroupTap(context, group, l10n),
                    ),
                  );
                },
              );
            }
            // Vocabulary: sectioned list with headers
            const sectionIds = [
              [
                'basic_verbs_01',
                'basic_verbs_02',
                'basic_verbs_03',
                'basic_verbs_04',
                'basic_verbs_05',
                'basic_verbs_06',
                'basic_verbs_07',
                'basic_verbs_08',
                'basic_verbs_09',
                'basic_verbs_10',
                'basic_verbs_11',
              ],
              [
                'adverbs_of_time',
                'prepositions',
                'demonstrative_pronouns',
                'relative_direction',
                'degree_quantity',
              ],
              [
                'people',
                'places',
                'daily_items_objects',
                'time_nature',
                'abstract_concepts',
              ],
              [
                'general_qualities',
                'people_emotions',
                'senses_feelings',
                'colors',
              ],
            ];
            final sectionHeaders = [
              l10n.groupWords,
              l10n.vocabSectionSettingWords,
              l10n.vocabSectionBasicNouns,
              l10n.vocabSectionBasicAdjectives,
            ];
            final idToGroup = {for (final g in childGroups) g.id: g};
            final items = <Object>[];
            for (var i = 0; i < sectionHeaders.length; i++) {
              items.add(sectionHeaders[i]);
              for (final id in sectionIds[i]) {
                final group = idToGroup[id];
                if (group != null) items.add(group);
              }
            }
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is String) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0 : 12,
                      bottom: 8,
                    ),
                    child: Text(
                      item,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }
                final group = item as GroupModel;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _GroupTile(
                    group: group,
                    l10n: l10n,
                    theme: theme,
                    testResult: testResults[group.id],
                    onTap: () => _onGroupTap(context, group, l10n),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(l10n.loadError)),
        ),
      ),
    );
  }

  Future<void> _onGroupTap(
    BuildContext context,
    GroupModel group,
    AppLocalizations l10n,
  ) async {
    final totalCards = group.cards.length;

    // No cards available
    if (totalCards <= 0) return;

    ref.read(selectedGroupProvider.notifier).state = group;

    final selection = await showModeBottomSheet(context, l10n);
    if (selection == null || !context.mounted) return;

    int count;
    if (selection.isTest) {
      // TEST mode: always use all cards
      count = totalCards;
    } else {
      // TRAIN mode: show count selection (or auto-select if ≤5)
      final selectedCount = await showCountBottomSheet(
        context,
        l10n,
        totalCount: totalCards,
      );
      if (selectedCount == null || !context.mounted) return;
      count = selectedCount;
    }

    final originRoute = widget.parent == ParentCategory.vocabulary
        ? AppRoutes.vocabulary
        : AppRoutes.conjugations;
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref
        .read(sessionProvider.notifier)
        .start(
          group: group,
          mode: selection.mode,
          questionCount: count,
          originRoute: originRoute,
          originScrollOffset: scrollOffset,
          isTest: selection.isTest,
        );
    if (context.mounted) context.go(AppRoutes.session);
  }
}
