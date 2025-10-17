import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../model/comparison_mode_model.dart';
import '../viewmodel/comparison_mode_provider.dart';
import '../theme.dart';

/// Widget for selecting the comparison mode
class ComparisonModeSettingsWidget extends ConsumerWidget {
  const ComparisonModeSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(comparisonModeProvider);

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          //   child: Text(
          //     AppLocalizations.of(context)!.comparisonMode,
          //     style: AppTypography.bodyMedium(
          //       context,
          //     ).copyWith(fontWeight: FontWeight.bold),
          //   ),
          // ),
          // const SizedBox(height: 4),
          ...ComparisonMode.values.map((mode) {
            final isSelected = currentMode == mode;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.0,
              ),
              child: InkWell(
                onTap: () {
                  ref
                      .read(comparisonModeProvider.notifier)
                      .setComparisonMode(mode);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<ComparisonMode>(
                        value: mode,
                        groupValue: currentMode,
                        onChanged: (ComparisonMode? value) {
                          if (value != null) {
                            ref
                                .read(comparisonModeProvider.notifier)
                                .setComparisonMode(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLocalizedModeName(context, mode),
                              style: AppTypography.bodyMedium(context).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLocalizedModeDescription(context, mode),
                              style: AppTypography.bodySmall(
                                context,
                              ).copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Get the localized name for a comparison mode
  String _getLocalizedModeName(BuildContext context, ComparisonMode mode) {
    switch (mode) {
      case ComparisonMode.closestWeightShortestTime:
        return AppLocalizations.of(context)!.shortestTimeDifference;
      case ComparisonMode.closestWeightLongestTime:
        return AppLocalizations.of(context)!.longestTimeDifference;
    }
  }

  /// Get the localized description for a comparison mode
  String _getLocalizedModeDescription(
    BuildContext context,
    ComparisonMode mode,
  ) {
    switch (mode) {
      case ComparisonMode.closestWeightShortestTime:
        return AppLocalizations.of(context)!.shortestTimeDifferenceDescription;
      case ComparisonMode.closestWeightLongestTime:
        return AppLocalizations.of(context)!.longestTimeDifferenceDescription;
    }
  }
}
