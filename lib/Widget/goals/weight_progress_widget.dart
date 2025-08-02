import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:weigthtracker/ViewModel/weight_change_tdee_goal_provider.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/viewmodel/weight_change_tdee_provider.dart';
import '../../viewmodel/weight_progress_view_model.dart';

/// A widget that displays the current weight and goal weight with a progress indicator.
///
/// This widget follows the MVVM pattern by using the weightProgressProvider
/// to access the calculated progress data from the ViewModel.
class WeightProgressWidget extends ConsumerWidget {
  const WeightProgressWidget({Key? key}) : super(key: key);

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
                      progressData.displayCurrentWeight != null
                          ? '${progressData.displayCurrentWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
                          : '-- ${progressData.unitSuffix}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

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
                      progressData.displayGoalWeight != null
                          ? '${progressData.displayGoalWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
                          : '-- ${progressData.unitSuffix}',
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
                        value: progressData.progressPercentage,
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
                          '${(progressData.progressPercentage * 100).toStringAsFixed(0)}%',
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remaining weight
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'TDEE Calories',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tdee?.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

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
                        progressData.currentWeight != null &&
                                progressData.goalWeight != null
                            ? '${progressData.displayRemainingWeight.abs().toStringAsFixed(1)} ${progressData.unitSuffix}'
                            : '-- ${progressData.unitSuffix}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Goal Weight TDEE',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${goalTDEE?.toStringAsFixed(0) ?? 'N/A'}',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

  // Helper method to calculate goal TDEE
  
