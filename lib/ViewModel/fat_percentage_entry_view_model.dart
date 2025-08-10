import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'entry_form_provider.dart';

/// A data class that holds all the fat percentage entry information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (FatPercentageEntryWidget).
class FatPercentageEntryData {
  final double? fatPercentage;
  final TextEditingController fatPercentageController;

  FatPercentageEntryData({
    this.fatPercentage,
    required this.fatPercentageController,
  });
}

/// A ViewModel that manages fat percentage entry information.
///
/// This class follows the MVVM pattern by processing data from the bodyEntryProvider
/// and transforming it into a format that's ready for display in the View.
class FatPercentageEntryViewModel
    extends StateNotifier<FatPercentageEntryData> {
  FatPercentageEntryViewModel(this.ref)
    : super(
        FatPercentageEntryData(
          fatPercentageController: TextEditingController(),
        ),
      ) {
    _initializeController();

    // Listen for changes in the bodyEntryProvider that affect fat percentage entry
    ref.listen(bodyEntryProvider, (_, __) => _updateController());
  }

  final Ref ref;

  @override
  void dispose() {
    state.fatPercentageController.dispose();
    super.dispose();
  }

  /// Logs the current state of the fat percentage entry
  void _logState() {
    developer.log('===== Fat Percentage Entry ViewModel State ====');
    developer.log('Fat Percentage: ${state.fatPercentage}');
    developer.log('===================================');
  }

  /// Initializes the text controller with current value
  void _initializeController() {
    final bodyEntry = ref.read(bodyEntryProvider);

    // Initialize fat percentage controller
    if (bodyEntry.fatPercentage != null) {
      state.fatPercentageController.text = _formatFatPercentage(
        bodyEntry.fatPercentage!,
      );
    }

    // Update state
    state = FatPercentageEntryData(
      fatPercentage: bodyEntry.fatPercentage,
      fatPercentageController: state.fatPercentageController,
    );

    _logState();
  }

  /// Updates the controller when the underlying data changes
  void _updateController() {
    final bodyEntry = ref.read(bodyEntryProvider);

    // Don't update controller if user is currently typing (controller has focus)
    if (state.fatPercentageController.text.isNotEmpty &&
        bodyEntry.fatPercentage == null) {
      // User just cleared the field, don't interfere
      return;
    }

    // Update fat percentage controller
    if (bodyEntry.fatPercentage != null) {
      state.fatPercentageController.text = _formatFatPercentage(
        bodyEntry.fatPercentage!,
      );
    } else {
      if (state.fatPercentageController.text.isNotEmpty) {
        state.fatPercentageController.text = '';
      }
    }

    // Update state
    state = FatPercentageEntryData(
      fatPercentage: bodyEntry.fatPercentage,
      fatPercentageController: state.fatPercentageController,
    );

    _logState();
  }

  /// Format fat percentage to avoid automatic decimal point for whole numbers
  String _formatFatPercentage(double fatPercentage) {
    // Check if the fat percentage is a whole number
    if (fatPercentage == fatPercentage.roundToDouble()) {
      return fatPercentage
          .toInt()
          .toString(); // Convert to int to remove decimal
    } else {
      return fatPercentage.toString(); // Keep decimal for non-whole numbers
    }
  }

  /// Handles fat percentage text changes
  void onFatPercentageChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);

    if (value.isEmpty) {
      notifier.updateFatPercentage(null);
      state.fatPercentageController.text = '';
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
      notifier.updateFatPercentage(parsed);
    } catch (_) {
      // Silently ignore parsing errors
    }
  }

  /// Updates the fat percentage with a calculated value
  void updateCalculatedFatPercentage(double value) {
    state.fatPercentageController.text = value.toStringAsFixed(1);
    ref.read(bodyEntryProvider.notifier).updateFatPercentage(value);
  }
}

/// A provider for accessing the FatPercentageEntryViewModel.
///
/// This provider makes the FatPercentageEntryViewModel available to widgets
/// that need to display and modify fat percentage entry information.
final fatPercentageEntryProvider =
    StateNotifierProvider<FatPercentageEntryViewModel, FatPercentageEntryData>(
      (ref) => FatPercentageEntryViewModel(ref),
    );
