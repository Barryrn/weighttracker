import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ViewModel/weight_change_tdee_provider.dart';

/// A widget that displays the TDEE calculated based on weight change and calorie intake.
///
/// This widget follows the MVVM pattern by acting as the View that displays data
/// from the ViewModel (WeightChangeTDEENotifier).
class WeightChangeTDEEWidget extends ConsumerWidget {
  const WeightChangeTDEEWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the calculated TDEE from the provider
    final tdee = ref.watch(weightChangeTDEEProvider);

    // Debug log when widget rebuilds with new TDEE value
    print('WeightChangeTDEEWidget rebuilding with TDEE: $tdee');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.weightChangeTdee,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(
                context,
              )!.basedOnYourWeightChangeAndCalorieIntakeOverTime,
            ),
            const SizedBox(height: 8),
            _buildTDEEDisplay(context, tdee),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.calculationFormulaText),
            const SizedBox(height: 8),
            _buildRequirementsText(tdee, context),
          ],
        ),
      ),
    );
  }

  /// Builds the display for the calculated TDEE value
  Widget _buildTDEEDisplay(BuildContext context, double? tdee) {
    if (tdee == null) {
      return Card(
        color: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.insufficientDataToCalculateGoalTdee,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Text(
                '${tdee.toStringAsFixed(0)} ${AppLocalizations.of(context)!.calories}',
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.yourEstimatedDailyCalorieNeeds,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the requirements text based on whether TDEE is calculated
  Widget _buildRequirementsText(double? tdee, BuildContext context) {
    if (tdee == null) {
      return Text(AppLocalizations.of(context)!.infoNoteCalorieTimeCalculation);
    } else {
      return Text(
        AppLocalizations.of(
          context,
        )!.thisCalculationAutomaticallyUpdatesWhenYouAddNewEntries,
      );
    }
  }
}
