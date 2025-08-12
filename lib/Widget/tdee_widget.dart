import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../ViewModel/tdee_provider.dart';

class TDEEWidget extends ConsumerWidget {
  const TDEEWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tdee = ref.watch(tdeeProvider);
    final activityLevels = ref.watch(activityLevelsProvider);
    final currentActivityLevel = ref.read(tdeeProvider.notifier).activityLevel;

    return Card(
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      color: Theme.of(context).colorScheme.card,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.totalDailyEnergyExpenditureTdee,
              style: AppTypography.headline3(context),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                tdee != null ? '${tdee.toInt()} kcal/day' : 'Not calculated',
                style: AppTypography.subtitle1(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.activityLevel,
              style: AppTypography.subtitle2(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ActivityLevel>(
              value: currentActivityLevel,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true, // expand dropdown width to parent
              dropdownColor: Theme.of(context).colorScheme.card,
              items: activityLevels.map((level) {
                return DropdownMenuItem<ActivityLevel>(
                  value: level,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Text(
                      level.description,
                      softWrap: true,
                      style: AppTypography.bodyMedium(context),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newLevel) {
                if (newLevel != null) {
                  ref.read(tdeeProvider.notifier).updateActivityLevel(newLevel);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.infoTextTdeeEstimate,
              style: AppTypography.caption(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
