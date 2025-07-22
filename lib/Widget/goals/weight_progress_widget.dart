import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/latest_weight_provider.dart';
import '../../viewmodel/weight_goal_provider.dart';
import '../../viewmodel/start_weight_provider.dart';
import '../../viewmodel/unit_conversion_provider.dart';

/// A widget that displays the current weight and goal weight with a progress indicator.
///
/// This widget follows the MVVM pattern by using the latestWeightProvider,
/// startWeightProvider, and weightGoalProvider to access the current state.
class WeightProgressWidget extends ConsumerWidget {
  const WeightProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the latest weight entry
    final latestEntry = ref.watch(latestWeightProvider);

    // Get the weight goal
    final weightGoal = ref.watch(weightGoalProvider);

    // Get the start weight
    final startWeight = ref.watch(startWeightProvider);

    // Get unit preferences
    final unitPrefs = ref.watch(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Calculate progress values
    final currentWeight = latestEntry?.weight;
    double progressPercentage = 0.0;
    double remainingWeight = 0.0;

    // Only calculate if all values are available
    if (currentWeight != null && weightGoal != null && startWeight != null) {
      // Determine if we're trying to gain or lose weight
      final isWeightLoss = startWeight > weightGoal;

      if (isWeightLoss) {
        // For weight loss: calculate how much has been lost as a percentage of total goal
        final totalToLose = startWeight - weightGoal;
        final alreadyLost = startWeight - currentWeight;

        progressPercentage = totalToLose > 0
            ? (alreadyLost / totalToLose)
            : 0.0;
        remainingWeight = currentWeight - weightGoal;
      } else {
        // For weight gain: calculate how much has been gained as a percentage of total goal
        final totalToGain = weightGoal - startWeight;
        final alreadyGained = currentWeight - startWeight;

        progressPercentage = totalToGain > 0
            ? (alreadyGained / totalToGain)
            : 0.0;
        remainingWeight = weightGoal - currentWeight;
      }

      // Ensure percentage is between 0 and 1
      progressPercentage = progressPercentage.clamp(0.0, 1.0);
    }

    // Convert weights to display units if needed
    final displayCurrentWeight =
        currentWeight != null && !unitPrefs.useMetricWeight
        ? currentWeight / 0.45359237
        : currentWeight;

    final displayGoalWeight = weightGoal != null && !unitPrefs.useMetricWeight
        ? weightGoal / 0.45359237
        : weightGoal;

    final displayStartWeight = startWeight != null && !unitPrefs.useMetricWeight
        ? startWeight / 0.45359237
        : startWeight;

    final displayRemainingWeight = !unitPrefs.useMetricWeight
        ? remainingWeight / 0.45359237
        : remainingWeight;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current weight
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayCurrentWeight != null
                          ? '${displayCurrentWeight.toStringAsFixed(1)} $unitSuffix'
                          : '-- $unitSuffix',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                // Start weight
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     const Text(
                //       'Start',
                //       style: TextStyle(fontSize: 14, color: Colors.grey),
                //     ),
                //     const SizedBox(height: 4),
                //     Text(
                //       displayStartWeight != null
                //           ? '${displayStartWeight.toStringAsFixed(1)} $unitSuffix'
                //           : '-- $unitSuffix',
                //       style: const TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ],
                // ),

                // Goal weight
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Goal',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayGoalWeight != null
                          ? '${displayGoalWeight.toStringAsFixed(1)} $unitSuffix'
                          : '-- $unitSuffix',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress circle
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress circle
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: progressPercentage,
                        strokeWidth: 12,
                        backgroundColor: AppColors.primaryVeryLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),

                    // Percentage text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(progressPercentage * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'complete',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Remaining weight
            Center(
              child: Column(
                children: [
                  const Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentWeight != null && weightGoal != null
                        ? '${displayRemainingWeight.abs().toStringAsFixed(1)} $unitSuffix'
                        : '-- $unitSuffix',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
