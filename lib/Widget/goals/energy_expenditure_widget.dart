import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/weight_change_tdee_goal_provider.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/viewmodel/weight_change_tdee_provider.dart';
import '../../viewmodel/weight_progress_view_model.dart';

/// A widget that displays the current weight and goal weight with a progress indicator.
///
/// This widget follows the MVVM pattern by using the weightProgressProvider
/// to access the calculated progress data from the ViewModel.
class EnergyExpenditureWidget extends ConsumerWidget {
  const EnergyExpenditureWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the weight progress data from the ViewModel
    final progressData = ref.watch(weightProgressProvider);
    final tdee = ref.watch(weightChangeTDEEProvider);

    final notifier = ref.read(weightChangeGoalTDEEProvider.notifier);
    final goalState = ref.watch(weightChangeGoalTDEEProvider);

    final double? baseTDEE = goalState.baseTDEE;
    final double weightChangePerWeek = goalState.weightChangePerWeek;
    final bool isGainingWeight = goalState.isGainingWeight;
    final int days = 7;

    final double calorieAdjustment =
        (weightChangePerWeek * 7700) / days * (isGainingWeight ? 1 : -1);

    final double? goalTDEE = baseTDEE != null
        ? baseTDEE + calorieAdjustment
        : null;

    return Card(
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      color: Theme.of(context).colorScheme.card,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Section
            Text('Energy Expenditure', style: AppTypography.headline3(context)),
            const SizedBox(height: 16),
            // TDEE Metrics Cards
            Row(
              children: [
                // TDEE Calories Card
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'TDEE Calories',
                    tdee?.toStringAsFixed(0) ?? 'N/A',
                    Theme.of(context).colorScheme.info,
                  ),
                ),
                const SizedBox(width: 12),
                // Goal Weight TDEE Card
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Goal Weight TDEE',
                    goalTDEE?.toStringAsFixed(0) ?? 'N/A',
                    Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a metric card with improved visual design
  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background1,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // center children horizontally
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with max 2 lines, ellipsis, centered text
          Text(
            label,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center, // center text
            style: AppTypography.bodyMedium(context),
          ),
          const SizedBox(height: 8),
          // Value text with max 2 lines, centered
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center, // center text
            style: AppTypography.subtitle1(context),
          ),
        ],
      ),
    );
  }
}
