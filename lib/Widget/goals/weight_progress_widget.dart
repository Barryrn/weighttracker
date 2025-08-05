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
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.2),
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weight information row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Current weight
                _buildWeightInfoColumn(
                  'Current',
                  progressData.displayCurrentWeight != null
                      ? '${progressData.displayCurrentWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
                      : '-- ${progressData.unitSuffix}',
                  AppColors.primary,
                ),

                // Goal weight
                _buildWeightInfoColumn(
                  'Goal',
                  progressData.displayGoalWeight != null
                      ? '${progressData.displayGoalWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
                      : '-- ${progressData.unitSuffix}',
                  AppColors.success,
                ),

                // Remaining weight
                _buildWeightInfoColumn(
                  'Remaining',
                  progressData.currentWeight != null &&
                          progressData.goalWeight != null
                      ? '${progressData.displayRemainingWeight.abs().toStringAsFixed(1)} ${progressData.unitSuffix}'
                      : '-- ${progressData.unitSuffix}',
                  AppColors.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress circle at the top
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: progressData.progressPercentage,
                      strokeWidth: 12,
                      backgroundColor: AppColors.primaryExtraLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progressData.progressPercentage * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        'complete',
                        style: TextStyle(
                          fontSize: 16,
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

          // TDEE information row
        ],
      ),
    );
  }

  /// Helper method to build a weight information column
  Widget _buildWeightInfoColumn(String label, String value, Color valueColor) {
    return Card(
      color: AppColors.background1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15), // You can adjust the padding value
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a TDEE information column
  Widget _buildTDEEInfoColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
