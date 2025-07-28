import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import 'latest_weight_provider.dart';
import 'weight_goal_provider.dart';
import 'start_weight_provider.dart';
import 'unit_conversion_provider.dart';
import 'dart:developer' as developer;

/// A data class that holds all the calculated weight progress information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (WeightProgressWidget).
class WeightProgressData {
  final double? currentWeight;
  final double? goalWeight;
  final double? startWeight;
  final double progressPercentage;
  final double remainingWeight;
  final bool isWeightLoss;
  final String unitSuffix;
  
  // Display weights (converted to user's preferred unit)
  final double? displayCurrentWeight;
  final double? displayGoalWeight;
  final double? displayStartWeight;
  final double displayRemainingWeight;

  WeightProgressData({
    this.currentWeight,
    this.goalWeight,
    this.startWeight,
    this.progressPercentage = 0.0,
    this.remainingWeight = 0.0,
    this.isWeightLoss = true,
    required this.unitSuffix,
    this.displayCurrentWeight,
    this.displayGoalWeight,
    this.displayStartWeight,
    this.displayRemainingWeight = 0.0,
  });
}

/// A ViewModel that calculates and provides weight progress information.
///
/// This class follows the MVVM pattern by processing data from multiple providers
/// and transforming it into a format that's ready for display in the View.
class WeightProgressViewModel extends StateNotifier<WeightProgressData> {
  WeightProgressViewModel(this.ref) : super(WeightProgressData(unitSuffix: 'kg')) {
    _calculateWeightProgress();
    
    // Listen for changes in the providers that affect weight progress
    ref.listen(latestWeightProvider, (_, __) => _calculateWeightProgress());
    ref.listen(weightGoalProvider, (_, __) => _calculateWeightProgress());
    ref.listen(startWeightProvider, (_, __) => _calculateWeightProgress());
    ref.listen(unitConversionProvider, (_, __) => _calculateWeightProgress());
  }

  final Ref ref;

  /// Logs the current state of the weight progress
  void _logState() {
    developer.log('===== Weight Progress ViewModel State =====');
    developer.log('Current Weight: ${state.currentWeight}');
    developer.log('Goal Weight: ${state.goalWeight}');
    developer.log('Start Weight: ${state.startWeight}');
    developer.log('Progress Percentage: ${state.progressPercentage}');
    developer.log('Remaining Weight: ${state.remainingWeight}');
    developer.log('Is Weight Loss: ${state.isWeightLoss}');
    developer.log('Unit Suffix: ${state.unitSuffix}');
    developer.log('===================================');
  }

  /// Calculates weight progress based on current, goal, and start weights
  void _calculateWeightProgress() {
    // Get the latest weight entry
    final latestEntry = ref.read(latestWeightProvider);

    // Get the weight goal
    final weightGoal = ref.read(weightGoalProvider);

    // Get the start weight
    final startWeight = ref.read(startWeightProvider);

    // Get unit preferences
    final unitPrefs = ref.read(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Calculate progress values
    final currentWeight = latestEntry?.weight;
    double progressPercentage = 0.0;
    double remainingWeight = 0.0;
    bool isWeightLoss = true;

    // Only calculate if all values are available
    if (currentWeight != null && weightGoal != null && startWeight != null) {
      // Determine if we're trying to gain or lose weight
      isWeightLoss = startWeight > weightGoal;

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

    // Update state with calculated values
    state = WeightProgressData(
      currentWeight: currentWeight,
      goalWeight: weightGoal,
      startWeight: startWeight,
      progressPercentage: progressPercentage,
      remainingWeight: remainingWeight,
      isWeightLoss: isWeightLoss,
      unitSuffix: unitSuffix,
      displayCurrentWeight: displayCurrentWeight,
      displayGoalWeight: displayGoalWeight,
      displayStartWeight: displayStartWeight,
      displayRemainingWeight: displayRemainingWeight,
    );
    
    _logState();
  }
}

/// A provider for accessing the WeightProgressViewModel.
///
/// This provider makes the WeightProgressViewModel available to widgets
/// that need to display weight progress information.
final weightProgressProvider = StateNotifierProvider<WeightProgressViewModel, WeightProgressData>(
  (ref) => WeightProgressViewModel(ref),
);