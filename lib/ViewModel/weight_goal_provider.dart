import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import 'unit_conversion_provider.dart';

/// A StateNotifier that manages the user's weight goal.
///
/// This class follows the MVVM pattern by acting as the ViewModel that connects
/// the Model (weight goal data) with the View (WeightGoalWidget).
class WeightGoalNotifier extends StateNotifier<double?> {
  /// Creates a WeightGoalNotifier with null initial state.
  /// Loads saved weight goal from storage when initialized.
  WeightGoalNotifier() : super(null) {
    _loadWeightGoal();
  }

  /// The key used to store the weight goal in SharedPreferences.
  static const String _weightGoalKey = 'weight_goal_kg';

  /// Logs the current state of the weight goal
  /// This is called after each state update to help with debugging
  void _logState() {
    developer.log('===== Weight Goal Provider State =====');
    developer.log('Weight Goal (kg): $state');
    developer.log('===================================');
  }

  /// Loads weight goal from SharedPreferences
  Future<void> _loadWeightGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weightGoal = prefs.getDouble(_weightGoalKey);
      state = weightGoal;
      _logState();
    } catch (e) {
      developer.log('Error loading weight goal: $e');
    }
  }

  /// Saves the current weight goal to SharedPreferences
  Future<void> _saveWeightGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state != null) {
        await prefs.setDouble(_weightGoalKey, state!);
      } else {
        await prefs.remove(_weightGoalKey);
      }
    } catch (e) {
      developer.log('Error saving weight goal: $e');
    }
  }

  /// Updates the weight goal value, converting from display units to standard units (kg)
  /// @param weightGoal The weight goal value in the current display unit (kg or lb)
  /// @param useMetric Whether the input is in metric units
  void updateWeightGoal(double? weightGoal, {required bool useMetric}) {
    if (weightGoal == null) {
      state = null;
    } else {
      // Convert to standard unit (kg) if needed
      final standardWeight = useMetric ? weightGoal : weightGoal * 0.45359237;
      state = standardWeight;
    }
    _saveWeightGoal();
    _logState();
  }
}

/// A provider for accessing and modifying the weight goal.
///
/// This provider makes the WeightGoalNotifier available to widgets
/// that need to read or update the weight goal.
final weightGoalProvider = StateNotifierProvider<WeightGoalNotifier, double?>(
  (ref) => WeightGoalNotifier(),
);
