import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../data/models/group_model.dart';
import '../data/test_result_repository.dart';
import '../quiz/session_notifier.dart';
import '../providers/groups_provider.dart';
import '../providers/test_result_provider.dart';
import '../router/app_router.dart';
import '../shared/theme/app_theme.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_scaffold.dart';
import '../shared/ui/quiz_bottom_sheets.dart';
import '../utils/group_label.dart';
import 'group_list_screen.dart' show formatRelativeDate;

/// Screen to select an adjective group for an agreement session.
class AgreementGroupListScreen extends ConsumerStatefulWidget {
  const AgreementGroupListScreen({super.key});

  @override
  ConsumerState<AgreementGroupListScreen> createState() => _AgreementGroupListScreenState();
}

class _AgreementGroupListScreenState extends ConsumerState<AgreementGroupListScreen> {
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

    // When data loads and we have a pending scroll, schedule restore
    if (asyncGroups.hasValue && _pendingScrollOffset != null && !_scrollRestored) {
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
        title: l10n.parentAgreement,
        leading: BackButton(
          onPressed: () => context.go(AppRoutes.home),
        ),
        child: asyncGroups.when(
          data: (groups) {
            final adjectiveGroupsList = adjectiveGroups(groups);
            final theme = Theme.of(context);
            if (adjectiveGroupsList.isEmpty) {
              return Center(
                child: Text(
                  l10n.loadError,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: adjectiveGroupsList.length,
              itemBuilder: (context, index) {
                final group = adjectiveGroupsList[index];
                final groupId = 'agreement:${group.id}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AgreementGroupTile(
                    group: group,
                    l10n: l10n,
                    theme: theme,
                    testResult: testResults[groupId],
                    onTap: () => _onGroupTap(context, group, groups, l10n),
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
    GroupModel group,
    List<GroupModel> allGroups,
    AppLocalizations l10n,
  ) async {
    final totalCards = group.cards.length; // adjective count

    // No cards available
    if (totalCards <= 0) return;

    // Agreement only supports writing mode
    final selection = await showModeBottomSheet(context, l10n, showAllModes: false);
    if (selection == null || !context.mounted) return;

    int count;
    if (selection.isTest) {
      // TEST mode: always use all adjectives
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

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref.read(sessionProvider.notifier).startAgreement(
          adjectiveGroup: group,
          allGroups: allGroups,
          mode: selection.mode,
          questionCount: count,
          originRoute: AppRoutes.agreement,
          originScrollOffset: scrollOffset,
          isTest: selection.isTest,
        );
    if (context.mounted) context.go(AppRoutes.session);
  }
}

class _AgreementGroupTile extends StatelessWidget {
  const _AgreementGroupTile({
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
      child: Stack(
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
              child: _TestBadge(
                testResult: testResult!,
                l10n: l10n,
              ),
            ),
        ],
      ),
    );
  }
}

class _TestBadge extends StatelessWidget {
  const _TestBadge({
    required this.testResult,
    required this.l10n,
  });

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
            style: TextStyle(
              color: dateInfo.color,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
