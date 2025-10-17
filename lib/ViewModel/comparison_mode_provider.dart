import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/comparison_mode_model.dart';

/// Provider for managing the comparison mode setting
class ComparisonModeNotifier extends StateNotifier<ComparisonMode> {
  static const String _comparisonModeKey = 'comparison_mode';

  ComparisonModeNotifier() : super(ComparisonMode.closestWeightShortestTime) {
    _loadComparisonMode();
  }

  /// Load the comparison mode from SharedPreferences
  Future<void> _loadComparisonMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt(_comparisonModeKey);

      if (modeIndex != null && modeIndex < ComparisonMode.values.length) {
        state = ComparisonMode.values[modeIndex];
      }
    } catch (e) {
      // If there's an error loading, keep the default value
      state = ComparisonMode.closestWeightShortestTime;
    }
  }

  /// Set the comparison mode and save to SharedPreferences
  Future<void> setComparisonMode(ComparisonMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_comparisonModeKey, mode.index);
    } catch (e) {
      // If there's an error saving, the state is still updated
    }
  }
}

/// Provider for comparison mode
final comparisonModeProvider =
    StateNotifierProvider<ComparisonModeNotifier, ComparisonMode>(
  (ref) => ComparisonModeNotifier(),
);
