import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'weight_change_tdee_provider.dart';

/// Enum to represent the weight goal type (loss or gain)
enum WeightGoalType { loss, gain }

/// A data class that holds all the weight goal information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (WeightLossGoalWidget).
class WeightLossGoalData {
  final double? weeklyGoal; // Weekly weight goal in kg (positive value)
  final double? dailyCalorieChange; // Daily calorie deficit/surplus needed
  final double? currentTDEE; // Current TDEE from weight_change_tdee_provider
  final double? adjustedTDEE; // TDEE adjusted for weight goal
  final double? targetCalorieIntake; // Suggested daily calorie intake
  final TextEditingController weeklyGoalController;
  final String unitSuffix;
  final bool useMetricWeight;
  final WeightGoalType goalType; // Whether losing or gaining weight

  WeightLossGoalData({
    this.weeklyGoal,
    this.dailyCalorieChange,
    this.currentTDEE,
    this.adjustedTDEE,
    this.targetCalorieIntake,
    required this.weeklyGoalController,
    required this.unitSuffix,
    required this.useMetricWeight,
    required this.goalType,
  });
}

/// A ViewModel that manages weight goal information (loss or gain).
///
/// This class follows the MVVM pattern by processing data from the TDEE provider
/// and transforming it into a format that's ready for display in the View.
class WeightLossGoalViewModel extends StateNotifier<WeightLossGoalData> {
  WeightLossGoalViewModel(this.ref)
    : super(
        WeightLossGoalData(
          weeklyGoalController: TextEditingController(),
          unitSuffix: 'kg',
          useMetricWeight: true,
          goalType: WeightGoalType.loss, // Default to weight loss
        ),
      ) {
    _initializeController();

    // Listen for changes in the TDEE provider to update calculations immediately
    ref.listen(weightChangeTDEEProvider, (oldTDEE, newTDEE) {
      developer.log(
        'TDEE changed from: $oldTDEE to: $newTDEE, updating calculations',
      );

      // Update the state with the new TDEE value first
      state = WeightLossGoalData(
        weeklyGoal: state.weeklyGoal,
        dailyCalorieChange: state.dailyCalorieChange,
        currentTDEE: newTDEE, // Update with the new TDEE value
        adjustedTDEE: state.adjustedTDEE,
        targetCalorieIntake: state.targetCalorieIntake,
        weeklyGoalController: state.weeklyGoalController,
        unitSuffix: state.unitSuffix,
        useMetricWeight: state.useMetricWeight,
        goalType: state.goalType,
      );

      // Then recalculate all values based on the new TDEE
      _updateCalculations();
    });
  }

  final Ref ref;
  // Constant for calories per kg (1 kg ≈ 7700 kcal)
  static const double _caloriesPerKg = 7700;

  @override
  void dispose() {
    state.weeklyGoalController.dispose();
    super.dispose();
  }

  /// Logs the current state of the weight goal
  void _logState() {
    developer.log('===== Weight Goal ViewModel State =====');
    developer.log('Goal Type: ${state.goalType}');
    developer.log('Weekly Goal: ${state.weeklyGoal} kg');
    developer.log('Daily Calorie Change: ${state.dailyCalorieChange} kcal');
    developer.log('Current TDEE: ${state.currentTDEE} kcal');
    developer.log('Adjusted TDEE: ${state.adjustedTDEE} kcal');
    developer.log('Target Calorie Intake: ${state.targetCalorieIntake} kcal');
    developer.log('===================================');
  }

  /// Initializes the text controller with current value
  void _initializeController() {
    // Default to empty controller
    state = WeightLossGoalData(
      weeklyGoalController: state.weeklyGoalController,
      unitSuffix: 'kg',
      useMetricWeight: true,
      currentTDEE: ref.read(weightChangeTDEEProvider),
      goalType: state.goalType,
    );

    _updateCalculations();
  }

  /// Updates all calculations based on the weekly goal, goal type, and current TDEE
  void _updateCalculations() {
    final currentTDEE = ref.read(weightChangeTDEEProvider);
    final weeklyGoal = state.weeklyGoal;
    final goalType = state.goalType;

    double? dailyCalorieChange;
    double? adjustedTDEE;
    double? targetCalorieIntake;

    // Calculate daily calorie change if weekly goal is set
    if (weeklyGoal != null && weeklyGoal > 0) {
      // Convert weekly kg change to daily calorie change
      // 1 kg ≈ 7700 kcal, divide by 7 for daily change
      dailyCalorieChange = (weeklyGoal * _caloriesPerKg) / 7;

      // Calculate adjusted TDEE and target intake if TDEE is available
      if (currentTDEE != null) {
        // For weight loss, subtract the deficit; for weight gain, add the surplus
        adjustedTDEE = goalType == WeightGoalType.loss
            ? currentTDEE - dailyCalorieChange
            : currentTDEE + dailyCalorieChange;
        targetCalorieIntake = adjustedTDEE;
      }
    }

    // Update state with new calculations
    state = WeightLossGoalData(
      weeklyGoal: weeklyGoal,
      dailyCalorieChange: dailyCalorieChange,
      currentTDEE: currentTDEE,
      adjustedTDEE: adjustedTDEE,
      targetCalorieIntake: targetCalorieIntake,
      weeklyGoalController: state.weeklyGoalController,
      unitSuffix: state.unitSuffix,
      useMetricWeight: state.useMetricWeight,
      goalType: goalType,
    );

    _logState();
  }

  /// Handles weekly goal text changes
  void onWeeklyGoalChanged(String value) {
    if (value.isEmpty) {
      state = WeightLossGoalData(
        weeklyGoal: null,
        dailyCalorieChange: null,
        currentTDEE: state.currentTDEE,
        adjustedTDEE: null,
        targetCalorieIntake: null,
        weeklyGoalController: state.weeklyGoalController,
        unitSuffix: state.unitSuffix,
        useMetricWeight: state.useMetricWeight,
        goalType: state.goalType,
      );
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      state = WeightLossGoalData(
        weeklyGoal: parsed,
        dailyCalorieChange: state.dailyCalorieChange,
        currentTDEE: state.currentTDEE,
        adjustedTDEE: state.adjustedTDEE,
        targetCalorieIntake: state.targetCalorieIntake,
        weeklyGoalController: state.weeklyGoalController,
        unitSuffix: state.unitSuffix,
        useMetricWeight: state.useMetricWeight,
        goalType: state.goalType,
      );
      _updateCalculations();
    } catch (_) {
      // silently ignore parsing errors
    }
  }

  /// Toggles between weight loss and weight gain goals
  void toggleGoalType() {
    final newGoalType = state.goalType == WeightGoalType.loss
        ? WeightGoalType.gain
        : WeightGoalType.loss;

    state = WeightLossGoalData(
      weeklyGoal: state.weeklyGoal,
      dailyCalorieChange: state.dailyCalorieChange,
      currentTDEE: state.currentTDEE,
      adjustedTDEE: state.adjustedTDEE,
      targetCalorieIntake: state.targetCalorieIntake,
      weeklyGoalController: state.weeklyGoalController,
      unitSuffix: state.unitSuffix,
      useMetricWeight: state.useMetricWeight,
      goalType: newGoalType,
    );

    // Recalculate with the new goal type
    _updateCalculations();
  }
}

/// A provider for accessing the WeightLossGoalViewModel.
///
/// This provider makes the WeightLossGoalViewModel available to widgets
/// that need to display and modify weight goal information (loss or gain).
final weightLossGoalViewModelProvider =
    StateNotifierProvider<WeightLossGoalViewModel, WeightLossGoalData>(
      (ref) => WeightLossGoalViewModel(ref),
    );
