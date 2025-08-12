import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'dart:developer' as developer;
import 'weight_goal_provider.dart';
import 'start_weight_provider.dart';
import 'unit_conversion_provider.dart';

/// A data class that holds all the weight goal information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (WeightGoalWidget).
class WeightGoalData {
  final double? goalWeight;
  final double? startWeight;
  final String unitSuffix;
  final bool useMetricWeight;
  final TextEditingController goalController;
  final TextEditingController startController;

  WeightGoalData({
    this.goalWeight,
    this.startWeight,
    required this.unitSuffix,
    required this.useMetricWeight,
    required this.goalController,
    required this.startController,
  });
}

/// A ViewModel that manages weight goal information.
///
/// This class follows the MVVM pattern by processing data from multiple providers
/// and transforming it into a format that's ready for display in the View.
class WeightGoalViewModel extends StateNotifier<WeightGoalData> {
  WeightGoalViewModel(this.ref)
    : super(
        WeightGoalData(
          unitSuffix: 'kg',
          useMetricWeight: true,
          goalController: TextEditingController(),
          startController: TextEditingController(),
        ),
      ) {
    _initializeControllers();

    // Listen for changes in the providers that affect weight goals
    ref.listen(weightGoalProvider, (_, __) => _updateControllers());
    ref.listen(startWeightProvider, (_, __) => _updateControllers());
    ref.listen(unitConversionProvider, (_, __) => _updateUnitPreferences());
  }

  final Ref ref;

  @override
  void dispose() {
    state.goalController.dispose();
    state.startController.dispose();
    super.dispose();
  }

  /// Logs the current state of the weight goal
  void _logState() {
    developer.log('===== Weight Goal ViewModel State =====');
    developer.log('Goal Weight: ${state.goalWeight}');
    developer.log('Start Weight: ${state.startWeight}');
    developer.log('Unit Suffix: ${state.unitSuffix}');
    developer.log('Use Metric Weight: ${state.useMetricWeight}');
    developer.log('===================================');
  }

  /// Initializes the text controllers with current values
  void _initializeControllers() {
    final unitPrefs = ref.read(unitConversionProvider);
    final weightGoal = ref.read(weightGoalProvider);
    final startWeight = ref.read(startWeightProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Initialize goal controller
    if (weightGoal != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? weightGoal
          : weightGoal / 0.45359237;
      // Format without decimal if it's a whole number
      state.goalController.text = displayWeight % 1 == 0
          ? displayWeight.toInt().toString()
          : displayWeight.toStringAsFixed(1);
    }

    // Initialize start controller
    if (startWeight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? startWeight
          : startWeight / 0.45359237;
      // Format without decimal if it's a whole number
      state.startController.text = displayWeight % 1 == 0
          ? displayWeight.toInt().toString()
          : displayWeight.toStringAsFixed(1);
    }

    // Update state
    state = WeightGoalData(
      goalWeight: weightGoal,
      startWeight: startWeight,
      unitSuffix: unitSuffix,
      useMetricWeight: unitPrefs.useMetricWeight,
      goalController: state.goalController,
      startController: state.startController,
    );

    _logState();
  }

  /// Updates the controllers when the underlying data changes
  void _updateControllers() {
    final unitPrefs = ref.read(unitConversionProvider);
    final weightGoal = ref.read(weightGoalProvider);
    final startWeight = ref.read(startWeightProvider);

    // Update goal controller
    if (weightGoal != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? weightGoal
          : weightGoal / 0.45359237;
      // Format without decimal if it's a whole number
      state.goalController.text = displayWeight % 1 == 0
          ? displayWeight.toInt().toString()
          : displayWeight.toStringAsFixed(1);
    } else {
      state.goalController.text = '';
    }

    // Update start controller
    if (startWeight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? startWeight
          : startWeight / 0.45359237;
      // Format without decimal if it's a whole number
      state.startController.text = displayWeight % 1 == 0
          ? displayWeight.toInt().toString()
          : displayWeight.toStringAsFixed(1);
    } else {
      state.startController.text = '';
    }

    // Update state
    state = WeightGoalData(
      goalWeight: weightGoal,
      startWeight: startWeight,
      unitSuffix: state.unitSuffix,
      useMetricWeight: state.useMetricWeight,
      goalController: state.goalController,
      startController: state.startController,
    );

    _logState();
  }

  /// Updates the unit preferences when they change
  void _updateUnitPreferences() {
    final unitPrefs = ref.read(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Update state
    state = WeightGoalData(
      goalWeight: state.goalWeight,
      startWeight: state.startWeight,
      unitSuffix: unitSuffix,
      useMetricWeight: unitPrefs.useMetricWeight,
      goalController: state.goalController,
      startController: state.startController,
    );

    // Update controllers with converted values
    _updateControllers();
  }

  /// Handles weight goal text changes
  void onWeightGoalChanged(String value) {
    final notifier = ref.read(weightGoalProvider.notifier);

    if (value.isEmpty) {
      notifier.updateWeightGoal(null, useMetric: state.useMetricWeight);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateWeightGoal(parsed, useMetric: state.useMetricWeight);
    } catch (_) {
      // silently ignore
    }
  }

  /// Handles start weight text changes
  void onStartWeightChanged(String value) {
    final notifier = ref.read(startWeightProvider.notifier);

    if (value.isEmpty) {
      notifier.updateStartWeight(null, useMetric: state.useMetricWeight);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateStartWeight(parsed, useMetric: state.useMetricWeight);
    } catch (_) {
      // silently ignore
    }
  }

  /// Toggles between metric and imperial units
  void toggleUnit() {
    final unitNotifier = ref.read(unitConversionProvider.notifier);
    unitNotifier.setWeightUnit(useMetric: !state.useMetricWeight);
  }
}

/// A provider for accessing the WeightGoalViewModel.
///
/// This provider makes the WeightGoalViewModel available to widgets
/// that need to display and modify weight goal information.
final weightGoalViewModelProvider =
    StateNotifierProvider<WeightGoalViewModel, WeightGoalData>(
      (ref) => WeightGoalViewModel(ref),
    );
