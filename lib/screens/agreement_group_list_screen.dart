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
import '../shared/ui/quiz_bottom_sheets.dart';
import '../utils/group_label.dart';

/// Screen to select an adjective group for an agreement session.
class AgreementGroupListScreen extends ConsumerWidget {
  const AgreementGroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncGroups = ref.watch(groupsProvider);

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
              padding: const EdgeInsets.all(16),
              itemCount: adjectiveGroupsList.length,
              itemBuilder: (context, index) {
                final group = adjectiveGroupsList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AgreementGroupTile(
                    group: group,
                    l10n: l10n,
                    theme: theme,
                    onTap: () => _onGroupTap(context, ref, group, groups, l10n),
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
    List<GroupModel> allGroups,
    AppLocalizations l10n,
  ) async {
    final count = await showCountBottomSheet(context, l10n);
    if (count == null || !context.mounted) return;

    ref.read(sessionProvider.notifier).startAgreement(
          adjectiveGroup: group,
          allGroups: allGroups,
          mode: QuizMode.write,
          questionCount: count,
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
