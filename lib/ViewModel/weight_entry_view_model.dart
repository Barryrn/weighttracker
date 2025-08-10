import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'entry_form_provider.dart';
import 'unit_conversion_provider.dart';

/// A data class that holds all the weight entry information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (WeightEntryWidget).
class WeightEntryData {
  final double? weight;
  final String unitSuffix;
  final bool useMetricWeight;
  final TextEditingController weightController;

  WeightEntryData({
    this.weight,
    required this.unitSuffix,
    required this.useMetricWeight,
    required this.weightController,
  });
}

/// A ViewModel that manages weight entry information.
///
/// This class follows the MVVM pattern by processing data from multiple providers
/// and transforming it into a format that's ready for display in the View.
class WeightEntryViewModel extends StateNotifier<WeightEntryData> {
  WeightEntryViewModel(this.ref)
    : super(
        WeightEntryData(
          unitSuffix: 'kg',
          useMetricWeight: true,
          weightController: TextEditingController(),
        ),
      ) {
    _initializeController();

    // Listen for changes in the providers that affect weight entry
    ref.listen(bodyEntryProvider, (_, __) => _updateController());
    ref.listen(unitConversionProvider, (_, __) => _updateUnitPreferences());
  }

  final Ref ref;

  @override
  void dispose() {
    state.weightController.dispose();
    super.dispose();
  }

  /// Logs the current state of the weight entry
  void _logState() {
    developer.log('===== Weight Entry ViewModel State =====');
    developer.log('Weight: ${state.weight}');
    developer.log('Unit Suffix: ${state.unitSuffix}');
    developer.log('Use Metric Weight: ${state.useMetricWeight}');
    developer.log('===================================');
  }

  /// Initializes the text controller with current value
  void _initializeController() {
    final bodyEntry = ref.read(bodyEntryProvider);
    final unitPrefs = ref.read(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Initialize weight controller
    if (bodyEntry.weight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? bodyEntry.weight!
          : bodyEntry.weight! / 0.45359237;

      // Format without automatic decimal point for whole numbers
      state.weightController.text = _formatWeight(displayWeight);
    }

    // Update state
    state = WeightEntryData(
      weight: bodyEntry.weight,
      unitSuffix: unitSuffix,
      useMetricWeight: unitPrefs.useMetricWeight,
      weightController: state.weightController,
    );

    _logState();
  }

  /// Updates the controller when the underlying data changes
  void _updateController() {
    final bodyEntry = ref.read(bodyEntryProvider);
    final unitPrefs = ref.read(unitConversionProvider);

    // Don't update controller if user is currently typing (controller has focus)
    if (state.weightController.text.isNotEmpty && bodyEntry.weight == null) {
      // User just cleared the field, don't interfere
      return;
    }

    // Update weight controller
    if (bodyEntry.weight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? bodyEntry.weight!
          : bodyEntry.weight! / 0.45359237;

      // Format without automatic decimal point for whole numbers
      final formattedWeight = _formatWeight(displayWeight);

      // Only update if the formatted weight is different from current text
      if (state.weightController.text != formattedWeight) {
        state.weightController.text = formattedWeight;
      }
    } else {
      // Only clear if not already empty
      if (state.weightController.text.isNotEmpty) {
        state.weightController.text = '';
      }
    }

    // Update state
    state = WeightEntryData(
      weight: bodyEntry.weight,
      unitSuffix: state.unitSuffix,
      useMetricWeight: state.useMetricWeight,
      weightController: state.weightController,
    );

    _logState();
  }

  /// Updates the unit preferences when they change
  void _updateUnitPreferences() {
    final unitPrefs = ref.read(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';
    final bodyEntry = ref.read(bodyEntryProvider);

    // Update state
    state = WeightEntryData(
      weight: bodyEntry.weight,
      unitSuffix: unitSuffix,
      useMetricWeight: unitPrefs.useMetricWeight,
      weightController: state.weightController,
    );

    // Update controller with converted value
    if (bodyEntry.weight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? bodyEntry.weight!
          : bodyEntry.weight! / 0.45359237;

      // Format without automatic decimal point for whole numbers
      state.weightController.text = _formatWeight(displayWeight);
    }

    _logState();
  }

  /// Format weight to avoid automatic decimal point for whole numbers
  /// Format weight to always show at most one decimal place
  String _formatWeight(double weight) {
    double rounded = (weight * 10).round() / 10;

    // Remove unnecessary ".0", e.g. 82.0 → "82"
    if (rounded == rounded.roundToDouble()) {
      return rounded.toInt().toString();
    } else {
      return rounded.toStringAsFixed(1);
    }
  }

  /// Handles weight text changes
  void onWeightChanged(String value) {
    print(
      '🔍 ViewModel onWeightChanged called with: "$value" (isEmpty: ${value.isEmpty})',
    );

    final notifier = ref.read(bodyEntryProvider.notifier);

    if (value.isEmpty) {
      print('🔍 Setting weight to null');
      notifier.updateWeight(null, useMetric: state.useMetricWeight);
      // Don't let the controller be overwritten by listeners
      state.weightController.text = '';
      print('🔍 Controller text set to: "${state.weightController.text}"');
      return;
    }

    try {
      // Don't update the model if the input is incomplete (just a decimal point)
      if (value == '.' || value.endsWith('.')) {
        return;
      }

      // Normalize the input by replacing commas with periods
      final normalizedValue = value.replaceAll(',', '.');
      final parsed = double.parse(normalizedValue);
      notifier.updateWeight(parsed, useMetric: state.useMetricWeight);
    } catch (_) {
      // Silently ignore parsing errors
    }
  }

  /// Toggles between metric and imperial units
  void toggleUnit() {
    final unitNotifier = ref.read(unitConversionProvider.notifier);
    unitNotifier.setWeightUnit(useMetric: !state.useMetricWeight);
  }
}

/// A provider for accessing the WeightEntryViewModel.
///
/// This provider makes the WeightEntryViewModel available to widgets
/// that need to display and modify weight entry information.
final weightEntryProvider =
    StateNotifierProvider<WeightEntryViewModel, WeightEntryData>(
      (ref) => WeightEntryViewModel(ref),
    );
