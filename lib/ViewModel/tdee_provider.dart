import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/profile_settings_model.dart';
import 'dart:developer' as developer;
import 'latest_weight_provider.dart';
import 'profile_settings_provider.dart';
import '../provider/database_change_provider.dart';

/// Activity factor levels for TDEE calculation
enum ActivityLevel {
  sedentary(1.2, 'Sedentary (little or no exercise)'),
  lightlyActive(1.375, 'Lightly Active (light exercise 1-3 days/week)'),
  moderatelyActive(1.55, 'Moderately Active (moderate exercise 3-5 days/week)'),
  veryActive(1.725, 'Very Active (hard exercise 6-7 days/week)'),
  extraActive(
    1.9,
    'Extra Active (very hard exercise & physical job or 2x training)',
  );

  final double factor;
  final String description;

  const ActivityLevel(this.factor, this.description);
}

/// A provider that calculates the Total Daily Energy Expenditure (TDEE) using the Mifflin-St Jeor Equation.
///
/// This provider follows the MVVM pattern by acting as the ViewModel that connects
/// the Models (weight from database, profile settings from SharedPreferences) with the View.
class TDEENotifier extends StateNotifier<double?> {
  TDEENotifier(this.ref) : super(null) {
    _initialize();

    // Listen for changes in weight
    ref.listen(latestWeightProvider, (_, __) {
      calculateTDEE();
    });

    // Listen for changes in profile settings
    ref.listen(profileSettingsProvider, (_, __) {
      calculateTDEE();
    });

    // Listen for database changes
    ref.listen(databaseChangeProvider, (_, __) {
      calculateTDEE();
    });
  }

  final Ref ref;
  ActivityLevel _activityLevel =
      ActivityLevel.moderatelyActive; // Default activity level

  /// Initialize the TDEE calculation
  void _initialize() {
    calculateTDEE();
  }

  /// Get the current activity level
  ActivityLevel get activityLevel => _activityLevel;

  /// Update the activity level and recalculate TDEE
  void updateActivityLevel(ActivityLevel level) {
    _activityLevel = level;
    calculateTDEE();
    _logState();
  }

  /// Calculate the TDEE using the Mifflin-St Jeor Equation
  ///
  /// Females: (10 × weight [kg]) + (6.25 × height [cm]) – (5 × age [years]) – 161
  /// Males: (10 × weight [kg]) + (6.25 × height [cm]) – (5 × age [years]) + 5
  ///
  /// Then multiply by activity factor to get TDEE
  void calculateTDEE() {
    final latestEntry = ref.read(latestWeightProvider);
    final profileSettings = ref.read(profileSettingsProvider);
    
    // Get gender and birthday directly from profile settings provider
    final gender = profileSettings.gender;
    final birthday = profileSettings.birthday;
    
    // Log the values we're getting from profile settings
    developer.log('Profile settings - Gender: $gender, Birthday: $birthday');

    // Check if we have all required data and log missing data
    bool hasMissingData = false;
    
    if (latestEntry?.weight == null) {
      developer.log('Missing data for TDEE calculation: weight');
      hasMissingData = true;
    }
    
    if (profileSettings.height == null) {
      developer.log('Missing data for TDEE calculation: height');
      hasMissingData = true;
    }
    
    if (gender == null) {
      developer.log('Missing data for TDEE calculation: gender');
      hasMissingData = true;
    }
    
    if (birthday == null) {
      developer.log('Missing data for TDEE calculation: birthday');
      hasMissingData = true;
    }
    
    if (hasMissingData) {
      developer.log('TDEE calculation aborted due to missing data');
      state = null;
      return;
    }

    // Weight is already checked for null above, but we need to handle the nullable type properly
    final double weight = latestEntry!.weight!;
    final height = profileSettings.height!;
    
    // Calculate age from birthday
    final now = DateTime.now();
    final age =
        now.year -
        birthday!.year -
        (now.month > birthday.month ||
                (now.month == birthday.month && now.day >= birthday.day)
            ? 0
            : 1);

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (gender!.toLowerCase() == 'female') {
      bmr = (10.0 * weight) + (6.25 * height) - (5.0 * age) - 161.0;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    }

    // Calculate TDEE by multiplying BMR by activity factor
    final tdee = bmr * _activityLevel.factor;

    // Update state with calculated TDEE
    state = tdee;
    _logState();
  }

  /// Logs the current state of the TDEE calculation
  void _logState() {
    developer.log('===== TDEE Provider State =====');
    developer.log('TDEE: ${state ?? "Not calculated"}');
    developer.log('Activity Level: ${_activityLevel.description}');
    developer.log('Activity Factor: ${_activityLevel.factor}');
    developer.log('===================================');
  }
}

/// A provider for accessing the calculated TDEE.
///
/// This provider makes the TDEENotifier available to widgets
/// that need to read the calculated TDEE value.
final tdeeProvider = StateNotifierProvider<TDEENotifier, double?>(
  (ref) => TDEENotifier(ref),
);

/// A provider that exposes the list of available activity levels
final activityLevelsProvider = Provider<List<ActivityLevel>>((ref) {
  return ActivityLevel.values;
});
