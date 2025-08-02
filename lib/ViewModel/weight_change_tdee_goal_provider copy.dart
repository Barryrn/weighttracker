// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'dart:developer' as developer;
// import '../Model/body_entry_model.dart';
// import '../Model/database_helper.dart';
// import '../provider/database_change_provider.dart';

// /// A provider that calculates the TDEE based on weight change and calorie intake.
// ///
// /// This provider follows the MVVM pattern by acting as the ViewModel that connects
// /// the Models (weight and calorie data from database) with the View.
// class WeightChangeGoalTDEENotifier extends StateNotifier<double?> {
//   WeightChangeGoalTDEENotifier(this.ref) : super(null) {
//     _initialize();

//     // Listen for database changes to recalculate TDEE
//     ref.listen(databaseChangeProvider, (previous, current) {
//       developer.log('Database change detected in WeightChangeGoalTDEENotifier');
//       developer.log('Previous state: $previous, Current state: $current');
//       calculateTDEE();
//     });
//   }

//   final Ref ref;
//   final DatabaseHelper _databaseHelper = DatabaseHelper();

//   // Constants for TDEE calculation
//   static const int _minRequiredDays = 7;
//   static const int _maxDaysToUse = 14;
//   static const int _caloriesPerKg = 7700; // Calories per kg of body weight

//   /// Initialize the TDEE calculation
//   void _initialize() async {
//     await calculateTDEE();
//   }

//   /// Calculate the TDEE based on weight change and calorie intake
//   /// using the formula: TDEE = (CaloriesConsumed + (WeightChange_kg × 7700)) / Days
//   Future<void> calculateTDEE() async {
//     try {
//       developer.log('Starting TDEE calculation...');

//       // Get all body entries ordered by date
//       final List<BodyEntry> allEntries = await _databaseHelper
//           .queryAllBodyEntries();

//       developer.log(
//         'Retrieved ${allEntries.length} total entries from database',
//       );

//       // Sort entries by date (oldest first) to ensure proper sequence
//       allEntries.sort((a, b) => a.date.compareTo(b.date));

//       // Find continuous days of data
//       final List<BodyEntry> continuousEntries = _findContinuousEntries(
//         allEntries,
//       );

//       developer.log(
//         'Found ${continuousEntries.length} continuous entries with both weight and calorie data',
//       );
//       if (continuousEntries.isNotEmpty) {
//         developer.log(
//           'Continuous entries date range: ${continuousEntries.first.date} to ${continuousEntries.last.date}',
//         );
//       }

//       // Check if we have enough continuous days of data
//       if (continuousEntries.length < _minRequiredDays) {
//         developer.log(
//           'Not enough continuous days of data for TDEE calculation. '
//           'Need at least $_minRequiredDays days, but only have ${continuousEntries.length}.',
//         );
//         state = null;
//         return;
//       }

//       // Use up to the last _maxDaysToUse continuous days
//       final List<BodyEntry> entriesToUse =
//           continuousEntries.length > _maxDaysToUse
//           ? continuousEntries.sublist(continuousEntries.length - _maxDaysToUse)
//           : continuousEntries;

//       developer.log(
//         'Using ${entriesToUse.length} entries for TDEE calculation',
//       );

//       // Calculate TDEE based on weight change and calorie intake
//       final double tdee = _calculateTDEEFromEntries(entriesToUse);
//       developer.log('Calculated TDEE: $tdee calories');

//       // Update state with calculated TDEE
//       state = tdee;
//       _logState(entriesToUse);
//       developer.log('TDEE calculation completed successfully');
//     } catch (e) {
//       developer.log('Error calculating TDEE: $e');
//       state = null;
//     }
//   }

//   /// Calculate a goal TDEE based on desired weight change per week
//   ///
//   /// Parameters:
//   /// - [isGainingWeight]: true if the user wants to gain weight, false if they want to lose weight
//   /// - [weightChangePerWeek]: how many kilograms the user wants to gain or lose per week
//   ///
//   /// Returns the adjusted goal TDEE that would achieve the desired weight change rate.
//   /// Returns null if the base TDEE hasn't been calculated yet.
//   double? calculateGoalTDEE({
//     required bool isGainingWeight,
//     required double weightChangePerWeek,
//   }) {
//     // Check if base TDEE is available
//     if (state == null) {
//       developer.log('Cannot calculate goal TDEE: Base TDEE not available');
//       return null;
//     }

//     // Ensure weight change is positive for calculation
//     final double absWeightChangePerWeek = weightChangePerWeek.abs();

//     // Calculate daily calorie adjustment needed
//     // Weekly weight change in kg × calories per kg ÷ 7 days
//     final double dailyCalorieAdjustment =
//         (absWeightChangePerWeek * _caloriesPerKg) / 7;

//     developer.log(
//       'Daily calorie adjustment for ${absWeightChangePerWeek}kg/week: '
//       '$dailyCalorieAdjustment calories',
//     );

//     // Calculate goal TDEE by adding or subtracting the adjustment
//     final double goalTDEE = isGainingWeight
//         ? state! +
//               dailyCalorieAdjustment // Calorie surplus for weight gain
//         : state! - dailyCalorieAdjustment; // Calorie deficit for weight loss

//     developer.log(
//       'Goal TDEE calculation: Base TDEE (${state!}) '
//       '${isGainingWeight ? "+" : "-"} $dailyCalorieAdjustment = $goalTDEE',
//     );

//     return goalTDEE;
//   }

//   /// Find the most recent *completed* continuous streak
//   /// that has at least `_minRequiredDays` entries.
//   List<BodyEntry> _findContinuousEntries(List<BodyEntry> allEntries) {
//     if (allEntries.isEmpty) return [];

//     List<List<BodyEntry>> streaks = [];
//     List<BodyEntry> currentStreak = [];

//     for (int i = 0; i < allEntries.length; i++) {
//       final entry = allEntries[i];

//       if (entry.weight == null || entry.calorie == null) {
//         // End the current streak if data is incomplete
//         if (currentStreak.length >= _minRequiredDays) {
//           streaks.add(List.from(currentStreak));
//         }
//         currentStreak = [];
//         continue;
//       }

//       if (currentStreak.isEmpty) {
//         currentStreak.add(entry);
//       } else {
//         final DateTime lastDate = currentStreak.last.date;
//         final DateTime currentDate = entry.date;
//         final difference = currentDate.difference(lastDate).inDays;

//         if (difference == 1) {
//           currentStreak.add(entry);
//         } else {
//           // End current streak and start a new one
//           if (currentStreak.length >= _minRequiredDays) {
//             streaks.add(List.from(currentStreak));
//           }
//           currentStreak = [entry];
//         }
//       }
//     }

//     // Add final streak if complete
//     if (currentStreak.length >= _minRequiredDays) {
//       streaks.add(List.from(currentStreak));
//     }

//     if (streaks.isEmpty) {
//       return [];
//     }

//     // Return the latest completed streak (most recent by date)
//     streaks.sort((a, b) => b.last.date.compareTo(a.last.date));
//     return streaks.first;
//   }

//   /// Calculate TDEE from a list of continuous entries
//   /// using the formula: TDEE = (CaloriesConsumed + (WeightChange_kg × 7700)) / Days
//   double _calculateTDEEFromEntries(List<BodyEntry> entries) {
//     // Get first and last weight
//     final double firstWeight = entries.first.weight!;
//     final double lastWeight = entries.last.weight!;
//     developer.log('First weight: $firstWeight kg, Last weight: $lastWeight kg');

//     // Calculate weight change in kg
//     final double weightChange = lastWeight - firstWeight;
//     developer.log('Weight change: $weightChange kg');

//     // Calculate total calories consumed
//     double totalCalories = 0;
//     for (var entry in entries) {
//       totalCalories += entry.calorie ?? 0;
//     }
//     developer.log('Total calories consumed: $totalCalories calories');

//     // Calculate number of days
//     final int days = entries.length;
//     developer.log('Number of days: $days days');

//     // Calculate TDEE using the formula
//     // TDEE = (CaloriesConsumed + (WeightChange_kg × 7700)) / Days
//     final double caloriesFromWeightChange = weightChange * _caloriesPerKg;
//     developer.log(
//       'Calories from weight change: $caloriesFromWeightChange calories',
//     );

//     final double tdee = (totalCalories + caloriesFromWeightChange) / days;
//     developer.log(
//       'TDEE calculation: ($totalCalories + $caloriesFromWeightChange) / $days = $tdee',
//     );

//     return tdee;
//   }

//   /// Logs the current state of the TDEE calculation
//   void _logState(List<BodyEntry> entries) {
//     developer.log('===== Weight Change TDEE Provider State =====');
//     developer.log('TDEE: ${state ?? "Not calculated"}');
//     developer.log('Number of days used: ${entries.length}');
//     developer.log('First day: ${entries.first.date}');
//     developer.log('Last day: ${entries.last.date}');
//     developer.log('First weight: ${entries.first.weight}');
//     developer.log('Last weight: ${entries.last.weight}');
//     developer.log(
//       'Weight change: ${entries.last.weight! - entries.first.weight!}',
//     );
//     developer.log('===================================');
//   }
// }

// /// A provider for accessing the calculated TDEE based on weight change.
// ///
// /// This provider makes the WeightChangeGoalTDEENotifier available to widgets
// /// that need to read the calculated TDEE value.
// final weightChangeGoalTDEEProvider =
//     StateNotifierProvider<WeightChangeGoalTDEENotifier, double?>(
//       (ref) => WeightChangeGoalTDEENotifier(ref),
//     );

// // The databaseChangeProvider is already defined in database_change_provider.dart
