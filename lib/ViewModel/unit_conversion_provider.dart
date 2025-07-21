import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A ViewModel that handles unit conversions and unit preferences.
///
/// This class follows the MVVM pattern by providing business logic for
/// converting between different measurement units and storing user preferences.
class UnitConversionNotifier extends StateNotifier<UnitPreferences> {
  UnitConversionNotifier() : super(UnitPreferences()) {
    _loadPreferences();
  }

  /// Loads saved unit preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final useMetricWeight = prefs.getBool('use_metric_weight') ?? true;
    final useMetricHeight = prefs.getBool('use_metric_height') ?? true;
    
    state = UnitPreferences(
      useMetricWeight: useMetricWeight,
      useMetricHeight: useMetricHeight,
    );
  }

  /// Saves the current unit preferences to SharedPreferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_metric_weight', state.useMetricWeight);
    await prefs.setBool('use_metric_height', state.useMetricHeight);
  }

  /// Updates the weight unit preference (metric or imperial)
  /// @param useMetric True to use kg, false to use lb
  void setWeightUnit({required bool useMetric}) {
    state = state.copyWith(useMetricWeight: useMetric);
    _savePreferences();
  }

  /// Updates the height unit preference (metric or imperial)
  /// @param useMetric True to use cm, false to use inches
  void setHeightUnit({required bool useMetric}) {
    state = state.copyWith(useMetricHeight: useMetric);
    _savePreferences();
  }

  /// Converts weight from pounds to kilograms
  /// @param pounds Weight in pounds
  /// @return Weight in kilograms
  double lbToKg(double pounds) {
    return pounds * 0.45359237;
  }

  /// Converts weight from kilograms to pounds
  /// @param kg Weight in kilograms
  /// @return Weight in pounds
  double kgToLb(double kg) {
    return kg / 0.45359237;
  }

  /// Converts length from inches to centimeters
  /// @param inches Length in inches
  /// @return Length in centimeters
  double inchesToCm(double inches) {
    return inches * 2.54;
  }

  /// Converts length from centimeters to inches
  /// @param cm Length in centimeters
  /// @return Length in inches
  double cmToInches(double cm) {
    return cm / 2.54;
  }

  /// Converts a weight value to the standard unit (kg) based on current preferences
  /// @param value The weight value to convert
  /// @return The weight in kilograms
  double convertWeightToStandard(double value) {
    if (state.useMetricWeight) {
      return value; // Already in kg
    } else {
      return lbToKg(value); // Convert from lb to kg
    }
  }

  /// Converts a weight value from the standard unit (kg) to the display unit
  /// @param value The weight value in kg
  /// @return The weight in the display unit (kg or lb)
  double convertWeightFromStandard(double value) {
    if (state.useMetricWeight) {
      return value; // Keep as kg
    } else {
      return kgToLb(value); // Convert to lb
    }
  }

  /// Converts a length value to the standard unit (cm) based on current preferences
  /// @param value The length value to convert
  /// @return The length in centimeters
  double convertLengthToStandard(double value) {
    if (state.useMetricHeight) {
      return value; // Already in cm
    } else {
      return inchesToCm(value); // Convert from inches to cm
    }
  }

  /// Converts a length value from the standard unit (cm) to the display unit
  /// @param value The length value in cm
  /// @return The length in the display unit (cm or inches)
  double convertLengthFromStandard(double value) {
    if (state.useMetricHeight) {
      return value; // Keep as cm
    } else {
      return cmToInches(value); // Convert to inches
    }
  }

  /// Gets the current weight unit suffix (kg or lb)
  String get weightUnit => state.useMetricWeight ? 'kg' : 'lb';

  /// Gets the current height unit suffix (cm or inches)
  String get heightUnit => state.useMetricHeight ? 'cm' : 'inches';
}

/// A class that stores the user's unit preferences
class UnitPreferences {
  /// Whether to use metric units for weight (kg vs lb)
  final bool useMetricWeight;
  
  /// Whether to use metric units for height (cm vs inches)
  final bool useMetricHeight;

  UnitPreferences({
    this.useMetricWeight = true,
    this.useMetricHeight = true,
  });

  /// Creates a copy of this UnitPreferences with the given fields replaced with new values
  UnitPreferences copyWith({
    bool? useMetricWeight,
    bool? useMetricHeight,
  }) {
    return UnitPreferences(
      useMetricWeight: useMetricWeight ?? this.useMetricWeight,
      useMetricHeight: useMetricHeight ?? this.useMetricHeight,
    );
  }
}

/// Provider for accessing the UnitConversionNotifier
final unitConversionProvider = StateNotifierProvider<UnitConversionNotifier, UnitPreferences>((ref) {
  return UnitConversionNotifier();
});