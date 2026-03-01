import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../entities/group/group_model.dart';
import '../shared/repositories/models/deck_progress.dart';
import '../features/quiz/session_notifier.dart';
import '../app/providers/app_settings_provider.dart';
import '../app/providers/deck_progress_provider.dart';
import '../app/providers/groups_provider.dart';
import '../app/router/app_router.dart';
import '../app/theme/vessel_themes.dart';
import '../shared/ui/card/vessel_card.dart';
import '../shared/ui/screen_layout/vessel_scaffold.dart';
import '../shared/ui/bottom_sheet/quiz_bottom_sheets.dart';
import 'package:srpski_card/shared/lib/group_label.dart';
import 'package:srpski_card/shared/lib/progress_calculator.dart';
import 'group_list_screen.dart' show formatRelativeDate, retentionColor, retentionLabel;
import '../shared/ui/gap/vessel_gap.dart';
import '../app/layout/vessel_layout.dart';

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
    _pendingScrollOffset = ref.read(scrollOffsetToRestoreProvider);
    if (_pendingScrollOffset != null) {
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

    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = VesselThemes.of(context);
    final asyncGroups = ref.watch(groupsProvider);
    final allProgress = ref.watch(deckProgressProvider);
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
        if (!didPop) context.go(AppRoutes.tools);
      },
      child: VesselScaffold(
        title: l10n.parentAgreement,
        showBottomNav: true,
        leading: BackButton(
          onPressed: () => context.go(AppRoutes.tools),
        ),
        child: asyncGroups.when(
          data: (groups) {
            final adjectiveGroupsList = adjectiveGroups(groups);
            if (adjectiveGroupsList.isEmpty) {
              return Center(
                child: Text(
                  l10n.loadError,
                  style: VesselFonts.textBody.copyWith(color: t.textPrimary),
                ),
              );
            }
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(VesselLayout.screenPadding),
              itemCount: adjectiveGroupsList.length,
              itemBuilder: (context, index) {
                final group = adjectiveGroupsList[index];
                final groupId = 'agreement:${group.id}';
                final progress = allProgress[groupId];
                return Padding(
                  padding: const EdgeInsets.only(bottom: VesselLayout.listItemGap),
                  child: _AgreementGroupTile(
                    group: group,
                    l10n: l10n,
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
    final totalCards = group.cards.length;

    // No cards available
    if (totalCards <= 0) return;

    // Agreement only supports writing mode
    final selection = await showModeBottomSheet(context, l10n, showAllModes: false);
    if (selection == null || !context.mounted) return;

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
          mode: selection.mode,
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
    required this.onTap,
    this.progress,
    this.retention = 0.0,
  });

  final GroupModel group;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final DeckProgress? progress;
  final double retention;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final label = groupLabel(l10n, group.labelKey);
    final count = wordCount(group);
    final preview = groupPreviewText(group);
    final countText = preview.isNotEmpty
        ? l10n.wordsCountWithPreview(count, preview)
        : l10n.wordsCount(count);

    // Show badge if there's any progress
    final showBadge = progress != null && progress!.recentSessions.isNotEmpty;

    return VesselCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(VesselLayout.screenPadding),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: VesselFonts.textListItem.copyWith(color: t.textPrimary),
                      ),
                      const VesselGap.xxs(),
                      Text(
                        countText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VesselFonts.textCaption.copyWith(color: t.textSecondary),
                      ),
                    ],
                  ),
                ),
                const VesselGap.hl(),
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

  final DeckProgress progress;
  final double retention;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final t = VesselThemes.of(context);
    final percentage = progress.totalProgress.round();
    final level = ProgressCalculator.getRetentionLevel(
      retention,
      progress.totalProgress,
    );
    final levelColor = retentionColor(level, t);
    final levelLabel = retentionLabel(level, l10n);
    final dateText = progress.lastSessionDate != null
        ? formatRelativeDate(progress.lastSessionDate!, l10n)
        : '-';

    const chipPadding = EdgeInsets.symmetric(horizontal: VesselLayout.chipPaddingH, vertical: VesselLayout.chipPaddingV);
    final outlinedChipStyle = VesselFonts.textProgressChip.copyWith(
      color: t.textPrimary,
    );
    final filledChipStyle = VesselFonts.textProgressChip.copyWith(
      color: t.retentionText,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chip 1: Percentage (outlined)
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: t.cardBackground,
            border: Border.all(
              color: t.textPrimary,
              width: t.cardBorderWidth,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: Text('$percentage%', style: outlinedChipStyle),
        ),
        const VesselGap.hxs(),
        // Chip 2: Date (outlined)
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: t.cardBackground,
            border: Border.all(
              color: t.textPrimary,
              width: t.cardBorderWidth,
            ),
          ),
          child: Text(dateText, style: outlinedChipStyle),
        ),
        const VesselGap.hxs(),
        // Chip 3: Retention level (filled with level color)
        Container(
          padding: chipPadding,
          decoration: BoxDecoration(
            color: levelColor,
            border: Border.all(
              color: t.textPrimary,
              width: t.cardBorderWidth,
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
