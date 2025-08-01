import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'entry_form_provider.dart';

/// A data class that holds all the calorie entry information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (CalorieEntryWidget).
class CalorieEntryData {
  final double? calorie;
  final TextEditingController calorieController;

  CalorieEntryData({
    this.calorie,
    required this.calorieController,
  });
}

/// A ViewModel that manages calorie entry information.
///
/// This class follows the MVVM pattern by processing data from the body entry provider
/// and transforming it into a format that's ready for display in the View.
class CalorieEntryViewModel extends StateNotifier<CalorieEntryData> {
  CalorieEntryViewModel(this.ref)
    : super(
        CalorieEntryData(
          calorieController: TextEditingController(),
        ),
      ) {
    _initializeController();

    // Listen for changes in the providers that affect calorie entry
    ref.listen(bodyEntryProvider, (_, __) => _updateController());
  }

  final Ref ref;

  @override
  void dispose() {
    state.calorieController.dispose();
    super.dispose();
  }

  /// Logs the current state of the calorie entry
  void _logState() {
    developer.log('===== Calorie Entry ViewModel State =====');
    developer.log('Calorie: ${state.calorie}');
    developer.log('===================================');
  }

  /// Initializes the text controller with current value
  void _initializeController() {
    final bodyEntry = ref.read(bodyEntryProvider);

    // Initialize calorie controller
    if (bodyEntry.calorie != null) {
      state.calorieController.text = bodyEntry.calorie!.toInt().toString();
    }

    // Update state
    state = CalorieEntryData(
      calorie: bodyEntry.calorie,
      calorieController: state.calorieController,
    );

    _logState();
  }

  /// Updates the controller when the underlying data changes
  void _updateController() {
    final bodyEntry = ref.read(bodyEntryProvider);

    // Update calorie controller
    if (bodyEntry.calorie != null) {
      state.calorieController.text = bodyEntry.calorie!.toInt().toString();
    } else {
      state.calorieController.text = '';
    }

    // Update state
    state = CalorieEntryData(
      calorie: bodyEntry.calorie,
      calorieController: state.calorieController,
    );

    _logState();
  }

  /// Handles calorie text changes
  void onCalorieChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);

    if (value.isEmpty) {
      notifier.updateCalorie(null);
      return;
    }

    try {
      final parsed = double.parse(value);
      notifier.updateCalorie(parsed);
    } catch (_) {
      // Silently ignore parsing errors
    }
  }
}

/// A provider for accessing the CalorieEntryViewModel.
///
/// This provider makes the CalorieEntryViewModel available to widgets
/// that need to display and modify calorie entry information.
final calorieEntryProvider =
    StateNotifierProvider<CalorieEntryViewModel, CalorieEntryData>(
      (ref) => CalorieEntryViewModel(ref),
    );