import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'unit_conversion_provider.dart';

/// A StateNotifier that manages the user's start weight.
///
/// This class follows the MVVM pattern by acting as the ViewModel that connects
/// the Model (start weight data) with the View (WeightGoalWidget).
class StartWeightNotifier extends StateNotifier<double?> {
  /// Creates a StartWeightNotifier with null initial state.
  /// Loads saved start weight from storage when initialized.
  StartWeightNotifier() : super(null) {
    _loadStartWeight();
  }

  /// The key used to store the start weight in SharedPreferences.
  static const String _startWeightKey = 'start_weight_kg';

  /// Logs the current state of the start weight
  /// This is called after each state update to help with debugging
  void _logState() {
    developer.log('===== Start Weight Provider State =====');
    developer.log('Start Weight (kg): $state');
    developer.log('===================================');
  }

  /// Loads start weight from SharedPreferences
  Future<void> _loadStartWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final startWeight = prefs.getDouble(_startWeightKey);
      state = startWeight;
      _logState();
    } catch (e) {
      developer.log('Error loading start weight: $e');
    }
  }

  /// Saves the current start weight to SharedPreferences
  Future<void> _saveStartWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state != null) {
        await prefs.setDouble(_startWeightKey, state!);
      } else {
        await prefs.remove(_startWeightKey);
      }
    } catch (e) {
      developer.log('Error saving start weight: $e');
    }
  }

  /// Updates the start weight value, converting from display units to standard units (kg)
  /// @param startWeight The start weight value in the current display unit (kg or lb)
  /// @param useMetric Whether the input is in metric units
  void updateStartWeight(double? startWeight, {required bool useMetric}) {
    if (startWeight == null) {
      state = null;
    } else {
      // Convert to standard unit (kg) if needed
      final standardWeight = useMetric ? startWeight : startWeight * 0.45359237;
      state = standardWeight;
    }
    _saveStartWeight();
    _logState();
  }
}

/// A provider for accessing and modifying the start weight.
///
/// This provider makes the StartWeightNotifier available to widgets
/// that need to read or update the start weight.
final startWeightProvider = StateNotifierProvider<StartWeightNotifier, double?>(
  (ref) => StartWeightNotifier(),
);
