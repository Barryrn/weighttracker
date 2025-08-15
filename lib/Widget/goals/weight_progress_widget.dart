import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      color: Theme.of(context).colorScheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weight information row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Current weight
                Expanded(
                  child: _buildWeightInfoColumn(
                    AppLocalizations.of(context)!.current,
                    progressData.displayCurrentWeight != null
                        ? '${progressData.displayCurrentWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
                        : '-- ${progressData.unitSuffix}',
                    Theme.of(context).colorScheme.primary,
                    context,
                  ),
                ),

                const SizedBox(width: 8),

                // Goal weight
                Expanded(
                  child: _buildWeightInfoColumn(
                    AppLocalizations.of(context)!.goal,
                    progressData.displayGoalWeight != null
                        ? '${progressData.displayGoalWeight!.toStringAsFixed(1)} ${progressData.unitSuffix}'
                        : '-- ${progressData.unitSuffix}',
                    Theme.of(context).colorScheme.error,
                    context,
                  ),
                ),

                const SizedBox(width: 8),

                // Remaining weight
                Expanded(
                  child: _buildWeightInfoColumn(
                    AppLocalizations.of(context)!.remaining,
                    progressData.currentWeight != null &&
                            progressData.goalWeight != null
                        ? '${progressData.displayRemainingWeight.abs().toStringAsFixed(1)} ${progressData.unitSuffix}'
                        : '-- ${progressData.unitSuffix}',
                    Theme.of(context).colorScheme.warning,
                    context,
                  ),
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
                      color: Theme.of(context).colorScheme.primaryExtraLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Animated Progress circle
                  TweenAnimationBuilder<double>(
                    // Start from 0 and animate to the target progress percentage
                    tween: Tween<double>(
                      begin: 0.0,
                      end: progressData.progressPercentage,
                    ),
                    // Animation duration - adjust as needed
                    duration: const Duration(milliseconds: 1000),
                    // Optional curve for more dynamic animation
                    curve: Curves.easeIn,

                    // Builder function that updates with the animated value
                    builder: (context, animatedValue, child) {
                      return SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: animatedValue,
                          strokeWidth: 12,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primaryDark,
                          ),
                        ),
                      );
                    },
                  ),
                  // Center content with static percentage text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progressData.progressPercentage * 100).toStringAsFixed(0)}%',
                        style: AppTypography.headline2(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.complete,
                        style: AppTypography.bodyLarge(context).copyWith(
                          color: Theme.of(context).colorScheme.textSecondary,
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
  Widget _buildWeightInfoColumn(
    String label,
    String value,
    Color valueColor,
    BuildContext context,
  ) {
    return Card(
      color: Theme.of(context).colorScheme.background1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodyLarge(
                context,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.subtitle2(
                context,
              ).copyWith(color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a TDEE information column
  Widget _buildTDEEInfoColumn(
    String label,
    String value,
    Color valueColor,
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.subtitle1(context).copyWith(color: valueColor),
        ),
      ],
    );
  }
}
