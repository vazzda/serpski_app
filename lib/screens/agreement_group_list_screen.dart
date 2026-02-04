import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../data/models/group_model.dart';
import '../data/models/group_progress.dart';
import '../quiz/session_notifier.dart';
import '../providers/app_settings_provider.dart';
import '../providers/group_progress_provider.dart';
import '../providers/groups_provider.dart';
import '../router/app_router.dart';
import '../shared/theme/app_theme.dart';
import '../shared/ui/app_card.dart';
import '../shared/ui/app_scaffold.dart';
import '../shared/ui/quiz_bottom_sheets.dart';
import '../utils/group_label.dart';
import '../utils/progress_calculator.dart';
import 'group_list_screen.dart' show formatRelativeDate, retentionColor, retentionLabel;

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
    final allProgress = ref.watch(groupProgressProvider);
    final settings = ref.watch(appSettingsProvider);

    // When data loads and we have a pending scroll, schedule restore
    if (asyncGroups.hasValue && _pendingScrollOffset != null && !_scrollRestored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _restoreScrollPosition();
      });
    }

    // Helper to get retention for a group
    double getRetention(String groupId) {
      final progress = allProgress[groupId];
      if (progress == null) return 0.0;
      return ProgressCalculator.calculateRetention(
          progress, settings.decayFormula);
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
                final progress = allProgress[groupId];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AgreementGroupTile(
                    group: group,
                    l10n: l10n,
                    theme: theme,
                    progress: progress,
                    retention: getRetention(groupId),
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
    final mode = await showModeBottomSheet(context, l10n, showAllModes: false);
    if (mode == null || !context.mounted) return;

    // Show count selection (or auto-select if ≤5)
    final selectedCount = await showCountBottomSheet(
      context,
      l10n,
      totalCount: totalCards,
    );
    if (selectedCount == null || !context.mounted) return;

    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    ref.read(sessionProvider.notifier).startAgreement(
          adjectiveGroup: group,
          allGroups: allGroups,
          mode: mode,
          questionCount: selectedCount,
          originRoute: AppRoutes.agreement,
          originScrollOffset: scrollOffset,
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
    this.progress,
    this.retention = 0.0,
  });

  final GroupModel group;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onTap;
  final GroupProgress? progress;
  final double retention;

  @override
  Widget build(BuildContext context) {
    final label = groupLabel(l10n, group.labelKey);
    final count = wordCount(group);
    final preview = groupPreviewText(group);
    final countText = preview.isNotEmpty
        ? l10n.wordsCountWithPreview(count, preview)
        : l10n.wordsCount(count);

    // Show badge if there's any progress
    final showBadge = progress != null && progress!.recentSessions.isNotEmpty;

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
          // Progress badge (if any sessions done)
          if (showBadge)
            Positioned(
              top: 0,
              right: 0,
              child: _ProgressBadge(
                progress: progress!,
                retention: retention,
                l10n: l10n,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.progress,
    required this.retention,
    required this.l10n,
  });

  final GroupProgress progress;
  final double retention;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = progress.totalProgress.round();
    final level = ProgressCalculator.getRetentionLevel(
      retention,
      progress.totalProgress,
    );
    final levelColor = retentionColor(level);
    final levelLabel = retentionLabel(level, l10n);
    final dateText = progress.lastSessionDate != null
        ? formatRelativeDate(progress.lastSessionDate!, l10n)
        : '-';

    const chipPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);
    final outlinedChipStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppTheme.onSurface,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
    final filledChipStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppTheme.retentionText,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chip 1: Percentage (outlined)
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(
              color: AppTheme.onSurface,
              width: AppTheme.chipBorderWidth,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: Text('$percentage%', style: outlinedChipStyle),
        ),
        const SizedBox(width: 4),
        // Chip 2: Date (outlined)
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(
              color: AppTheme.onSurface,
              width: AppTheme.chipBorderWidth,
            ),
          ),
          child: Text(dateText, style: outlinedChipStyle),
        ),
        const SizedBox(width: 4),
        // Chip 3: Retention level (filled with level color)
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: levelColor,
            border: Border.all(
              color: AppTheme.onSurface,
              width: AppTheme.chipBorderWidth,
            ),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
            ),
          ),
          child: Text(levelLabel, style: filledChipStyle),
        ),
      ],
    );
  }
}
