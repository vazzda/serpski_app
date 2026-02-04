import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../data/models/decay_formula.dart';
import '../providers/app_settings_provider.dart';
import '../router/app_router.dart';
import '../shared/ui/app_scaffold.dart';

/// Settings screen for app configuration.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(AppRoutes.home);
      },
      child: AppScaffold(
        title: l10n.settingsTitle,
        leading: BackButton(
          onPressed: () => context.go(AppRoutes.home),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.settingsDecaySpeed,
                style: theme.textTheme.titleMedium,
              ),
            ),
            // Decay formula options
            _DecayOption(
              title: l10n.decayRelaxed,
              description: l10n.decayRelaxedDesc,
              isSelected: settings.decayFormula == DecayFormula.relaxed,
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setDecayFormula(DecayFormula.relaxed),
            ),
            const SizedBox(height: 8),
            _DecayOption(
              title: l10n.decayStandard,
              description: l10n.decayStandardDesc,
              isSelected: settings.decayFormula == DecayFormula.standard,
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setDecayFormula(DecayFormula.standard),
            ),
            const SizedBox(height: 8),
            _DecayOption(
              title: l10n.decayIntensive,
              description: l10n.decayIntensiveDesc,
              isSelected: settings.decayFormula == DecayFormula.intensive,
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setDecayFormula(DecayFormula.intensive),
            ),
            const SizedBox(height: 8),
            _DecayOption(
              title: l10n.decayHardcore,
              description: l10n.decayHardcoreDesc,
              isSelected: settings.decayFormula == DecayFormula.hardcore,
              onTap: () => ref
                  .read(appSettingsProvider.notifier)
                  .setDecayFormula(DecayFormula.hardcore),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecayOption extends StatelessWidget {
  const _DecayOption({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
