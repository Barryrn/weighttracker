import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/profile_settings_model.dart';
import '../model/profile_settings_storage_model.dart';

/// A ViewModel class that calculates body fat percentage based on measurements.
///
/// This class follows the MVVM pattern by providing business logic for calculating
/// body fat percentage based on user inputs.
class FatPercentageCalculator extends StateNotifier<double?> {
  FatPercentageCalculator() : super(null);

  /// Calculates body fat percentage based on gender and measurements.
  ///
  /// For men: BF (%) = 86.010 x log10 (abdomen – neck) – 70.041 x log10 (height) + 36.76
  /// For women: BF (%) = 163.205 x log10 (waist + hip – neck) – 97.684 x log10 (height) – 78.387
  ///
  /// All measurements should be in inches.
  ///
  /// @param gender The user's gender ('Male' or 'Female')
  /// @param height The user's height in inches
  /// @param neck The user's neck circumference in inches
  /// @param waist The user's waist circumference in inches
  /// @param hip The user's hip circumference in inches (only used for women)
  /// @return The calculated body fat percentage or null if calculation fails
  Future<double?> calculateFatPercentage({
    String? gender,
    double? height,
    double? neck,
    double? waist,
    double? hip,
  }) async {
    // If gender is not provided, try to get it from profile settings
    if (gender == null) {
      final profileSettings =
          await ProfileSettingsStorage.loadProfileSettings();
      gender = profileSettings.gender;
    }

    // If height is not provided, try to get it from profile settings
    if (height == null) {
      final profileSettings =
          await ProfileSettingsStorage.loadProfileSettings();
      height = profileSettings.height;

      // Convert height from cm to inches if available
      if (height != null) {
        height = height / 2.54; // Convert cm to inches
      }
    }

    // Return null if required parameters are missing
    if (gender == null || height == null || neck == null || waist == null) {
      return null;
    }

    // For women, hip measurement is required
    if (gender.toLowerCase() == 'female' && hip == null) {
      return null;
    }

    double result;

    if (gender.toLowerCase() == 'male') {
      // Men: BF (%) = 86.010 x log10 (abdomen – neck) – 70.041 x log10 (height) + 36.76
      result = 86.010 * log10(waist - neck) - 70.041 * log10(height) + 36.76;
    } else {
      // Women: BF (%) = 163.205 x log10 (waist + hip – neck) – 97.684 x log10 (height) – 78.387
      result =
          163.205 * log10(waist + hip! - neck) -
          97.684 * log10(height) -
          78.387;
    }

    // Ensure the result is within reasonable bounds (0-100%)
    result = result.clamp(0, 100);

    state = result;
    return result;
  }

  /// Helper function to calculate log base 10 of a number
  double log10(double x) {
    return log(x) / log(10);
  }
}

final fatPercentageCalculatorProvider =
    StateNotifierProvider<FatPercentageCalculator, double?>((ref) {
      return FatPercentageCalculator();
    });
