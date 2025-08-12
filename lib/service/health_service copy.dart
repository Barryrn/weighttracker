// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:health/health.dart';
// import 'package:intl/intl.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:weigthtracker/model/database_helper.dart';
// import '../model/body_entry_model.dart';
// import '../model/weight_entry_model.dart';
// import '../repository/weight_repository.dart';

// /// Service class for handling health data integration with Apple Health and Google Health Connect
// class HealthService {
//   final Health _health = Health();
//   final WeightRepository _weightRepository;

//   /// Set to track synced entries to prevent duplicate writes
//   final Set<String> _syncedEntries = <String>{};

//   Future<void> initialize() async {
//     await _health.configure();
//   }

//   // Define the types of data we want to access
//   static const List<HealthDataType> _types = [
//     HealthDataType.WEIGHT,
//     HealthDataType.BODY_FAT_PERCENTAGE,
//     HealthDataType.BODY_MASS_INDEX, // Added BMI data type
//   ];

//   // Define the permissions we need
//   static const List<HealthDataAccess> _permissions = [
//     HealthDataAccess.READ_WRITE,
//     HealthDataAccess.READ_WRITE,
//     HealthDataAccess.READ_WRITE, // Added permission for BMI
//   ];

//   /// Constructor that takes a WeightRepository instance
//   HealthService({WeightRepository? weightRepository})
//     : _weightRepository = weightRepository ?? WeightRepository();

//   /// Request authorization to access health data
//   /// @return Future<bool> Whether authorization was granted
//   Future<bool> requestAuthorization() async {
//     try {
//       // Request authorization for the specified data types
//       final authorized = await _health.requestAuthorization(
//         _types,
//         permissions: _permissions,
//       );
//       return authorized;
//     } catch (e) {
//       debugPrint('Error requesting health authorization: $e');
//       return false;
//     }
//   }

//   /// Check if Health Connect is available on Android
//   /// @return Future<bool> Whether Health Connect is available
//   Future<bool> isHealthConnectAvailable() async {
//     if (!defaultTargetPlatform.isAndroid) return false;
//     try {
//       final status = await _health.getHealthConnectSdkStatus();
//       return status == HealthConnectSdkStatus.sdkAvailable;
//     } catch (e) {
//       debugPrint('Error checking Health Connect availability: $e');
//       return false;
//     }
//   }

//   /// Check if Health data is available on the device
//   /// @return Future<bool> Whether health data is available
//   Future<bool> isHealthDataAvailable() async {
//     try {
//       if (defaultTargetPlatform.isIOS) {
//         // On iOS, HealthKit is generally available on all iOS devices running iOS 8 or later
//         // We can't directly check for HealthKit availability like we can with Health Connect,
//         // but we can assume it's available and then handle any errors during authorization
//         // This is a more reliable approach than using hasPermissions() which checks authorization, not availability
//         return true;
//       } else if (defaultTargetPlatform.isAndroid) {
//         // For Android, we check if Health Connect is available
//         return await isHealthConnectAvailable();
//       }
//       return false;
//     } catch (e) {
//       debugPrint('Error checking health data availability: $e');
//       return false;
//     }
//   }

//   /// Sync weight data from the app to health services with duplicate prevention
//   /// @param entries List of BodyEntry objects to sync
//   /// @return Future<bool> Whether the sync was successful
//   Future<bool> syncDataToHealth(List<BodyEntry> entries) async {
//     try {
//       final authorized = await requestAuthorization();
//       if (!authorized) return false;

//       bool allSuccess = true;

//       for (final entry in entries) {
//         if (entry.weight != null) {
//           // Create precise timestamp with seconds precision to avoid duplicates
//           final preciseStartTime = DateTime(
//             entry.date.year,
//             entry.date.month,
//             entry.date.day,
//             12, // Use noon to avoid timezone issues
//             0,
//             0,
//           );
//           final preciseEndTime = preciseStartTime;

//           // Create unique identifier for this entry
//           final entryId =
//               '${DateFormat('yyyy-MM-dd').format(entry.date)}_${entry.weight}';

//           // Skip if already synced
//           if (_syncedEntries.contains(entryId)) {
//             continue;
//           }

//           // Check for existing data before writing weight
//           final existingWeightData = await _checkExistingHealthData(
//             HealthDataType.WEIGHT,
//             preciseStartTime,
//             preciseEndTime,
//             entry.weight!,
//           );

//           bool weightSuccess = true;
//           if (!existingWeightData) {
//             weightSuccess = await _health.writeHealthData(
//               value: entry.weight!,
//               type: HealthDataType.WEIGHT,
//               startTime: preciseStartTime,
//               endTime: preciseEndTime,
//             );

//             if (weightSuccess) {
//               _syncedEntries.add(entryId);
//             }
//           }

//           // Write body fat percentage data if available
//           bool fatSuccess = true;
//           if (entry.fatPercentage != null) {
//             final healthFatPercentage = entry.fatPercentage! * 10;
//             final fatEntryId =
//                 '${DateFormat('yyyy-MM-dd').format(entry.date)}_fat_${entry.fatPercentage}';

//             if (!_syncedEntries.contains(fatEntryId)) {
//               final existingFatData = await _checkExistingHealthData(
//                 HealthDataType.BODY_FAT_PERCENTAGE,
//                 preciseStartTime,
//                 preciseEndTime,
//                 healthFatPercentage,
//               );

//               if (!existingFatData) {
//                 fatSuccess = await _health.writeHealthData(
//                   value: healthFatPercentage,
//                   type: HealthDataType.BODY_FAT_PERCENTAGE,
//                   startTime: preciseStartTime,
//                   endTime: preciseEndTime,
//                 );

//                 if (fatSuccess) {
//                   _syncedEntries.add(fatEntryId);
//                 }
//               }
//             }
//           }

//           // Write BMI data if available
//           bool bmiSuccess = true;
//           if (entry.bmi != null) {
//             final bmiEntryId =
//                 '${DateFormat('yyyy-MM-dd').format(entry.date)}_bmi_${entry.bmi}';

//             if (!_syncedEntries.contains(bmiEntryId)) {
//               final existingBmiData = await _checkExistingHealthData(
//                 HealthDataType.BODY_MASS_INDEX,
//                 preciseStartTime,
//                 preciseEndTime,
//                 entry.bmi!,
//               );

//               if (!existingBmiData) {
//                 bmiSuccess = await _health.writeHealthData(
//                   value: entry.bmi!,
//                   type: HealthDataType.BODY_MASS_INDEX,
//                   startTime: preciseStartTime,
//                   endTime: preciseEndTime,
//                 );

//                 if (bmiSuccess) {
//                   _syncedEntries.add(bmiEntryId);
//                 }
//               }
//             }
//           }

//           allSuccess = allSuccess && weightSuccess && fatSuccess && bmiSuccess;
//         }
//       }

//       return allSuccess;
//     } catch (e) {
//       debugPrint('Error syncing weight data to health: $e');
//       return false;
//     }
//   }

//   /// Check if similar health data already exists in the specified time range
//   /// @param type The health data type to check
//   /// @param startTime Start time for the check
//   /// @param endTime End time for the check
//   /// @param value The value to compare against
//   /// @return Future<bool> True if similar data exists, false otherwise
//   Future<bool> _checkExistingHealthData(
//     HealthDataType type,
//     DateTime startTime,
//     DateTime endTime,
//     double value,
//   ) async {
//     try {
//       // Expand the time range slightly to catch nearby entries
//       final checkStartTime = startTime.subtract(const Duration(minutes: 30));
//       final checkEndTime = endTime.add(const Duration(minutes: 30));

//       final existingData = await _health.getHealthDataFromTypes(
//         types: [type],
//         startTime: checkStartTime,
//         endTime: checkEndTime,
//       );

//       // Check if any existing data has a similar value (within 0.1% tolerance)
//       for (final data in existingData) {
//         double? existingValue;

//         if (data.value is num) {
//           existingValue = (data.value as num).toDouble();
//         } else if (data.value.toString().contains('numericValue:')) {
//           final valueStr = data.value.toString();
//           final regex = RegExp(r'numericValue: (\d+\.?\d*)');
//           final match = regex.firstMatch(valueStr);
//           if (match != null && match.groupCount >= 1) {
//             existingValue = double.tryParse(match.group(1)!);
//           }
//         }

//         if (existingValue != null) {
//           // Check if values are similar (within 0.1% tolerance)
//           final tolerance = value * 0.001; // 0.1% tolerance
//           if ((existingValue - value).abs() <= tolerance) {
//             return true; // Similar data exists
//           }
//         }
//       }

//       return false; // No similar data found
//     } catch (e) {
//       debugPrint('Error checking existing health data: $e');
//       return false; // Assume no existing data on error
//     }
//   }

//   /// Fetch weight data from health services with improved timestamp handling
//   /// @param startDate The start date for fetching data
//   /// @param endDate The end date for fetching data
//   /// @return Future<List<BodyEntry>> List of BodyEntry objects from health services
//   Future<List<BodyEntry>> fetchtDataFromHealth(
//     DateTime startDate,
//     DateTime endDate,
//   ) async {
//     try {
//       //print('Fetching health data from $startDate to $endDate');
//       final authorized = await requestAuthorization();
//       if (!authorized) {
//         //print('Health data authorization failed');
//         return [];
//       }
//       //print('Health data authorization successful');

//       // Fetch weight data
//       //print('Fetching weight data...');
//       final weightData = await _health.getHealthDataFromTypes(
//         types: [HealthDataType.WEIGHT],
//         startTime: startDate,
//         endTime: endDate,
//       );
//       //print('Weight data fetched: ${weightData.length} entries');

//       // Debug weight data
//       for (final data in weightData) {
//         //print('Weight data: date=${data.dateFrom}, value=${data.value}, unit=${data.unit}, sourceId=${data.sourceId}');
//       }

//       // Fetch body fat percentage data
//       //print('Fetching body fat data...');
//       final fatData = await _health.getHealthDataFromTypes(
//         types: [HealthDataType.BODY_FAT_PERCENTAGE],
//         startTime: startDate,
//         endTime: endDate,
//       );
//       //print('Fat data fetched: ${fatData.length} entries');

//       // Fetch BMI data
//       //print('Fetching BMI data...');
//       final bmiData = await _health.getHealthDataFromTypes(
//         types: [HealthDataType.BODY_MASS_INDEX],
//         startTime: startDate,
//         endTime: endDate,
//       );
//       //print('BMI data fetched: ${bmiData.length} entries');

//       // Create a map to organize weight data by date
//       final Map<String, BodyEntry> entriesByDate = {};

//       // Process weight data
//       for (final data in weightData) {
//         final dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);

//         // Extract the numeric value from the HealthDataPoint
//         double? weight;
//         if (data.value is num) {
//           weight = (data.value as num).toDouble();
//         } else if (data.value.toString().contains('numericValue:')) {
//           // Extract the numeric value from the string representation
//           final valueStr = data.value.toString();
//           final regex = RegExp(r'numericValue: (\d+\.?\d*)');
//           final match = regex.firstMatch(valueStr);
//           if (match != null && match.groupCount >= 1) {
//             weight = double.tryParse(match.group(1)!);
//           }
//         }

//         //print('Processing weight: dateKey=$dateKey, weight=$weight');

//         if (weight != null) {
//           final date = DateTime(
//             data.dateFrom.year,
//             data.dateFrom.month,
//             data.dateFrom.day,
//           );
//           //print('Creating BodyEntry with date=$date, weight=$weight');
//           entriesByDate[dateKey] = BodyEntry(date: date, weight: weight);
//         } else {
//           //print('Failed to parse weight value: ${data.value}');
//         }
//       }

//       // Process body fat percentage data
//       for (final data in fatData) {
//         final dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);

//         // Extract the numeric value from the HealthDataPoint
//         double? fatPercentage;
//         if (data.value is num) {
//           fatPercentage = (data.value as num).toDouble();
//           // Divide by 10 to convert from percentage to decimal
//           fatPercentage = fatPercentage / 10;
//         } else if (data.value.toString().contains('numericValue:')) {
//           // Extract the numeric value from the string representation
//           final valueStr = data.value.toString();
//           final regex = RegExp(r'numericValue: (\d+\.?\d*)');
//           final match = regex.firstMatch(valueStr);
//           if (match != null && match.groupCount >= 1) {
//             fatPercentage = double.tryParse(match.group(1)!);
//             // Divide by 10 to convert from percentage to decimal
//             if (fatPercentage != null) {
//               fatPercentage = fatPercentage / 10;
//             }
//           }
//         }

//         //print('Processing fat: dateKey=$dateKey, fatPercentage=$fatPercentage');

//         if (fatPercentage != null && entriesByDate.containsKey(dateKey)) {
//           // Update existing entry with fat percentage
//           final existingEntry = entriesByDate[dateKey]!;
//           entriesByDate[dateKey] = existingEntry.copyWith(
//             fatPercentage: fatPercentage,
//           );
//         } else if (fatPercentage != null) {
//           //print('No matching weight entry found for fat percentage on $dateKey');
//         } else {
//           //print('Failed to parse fat percentage value: ${data.value}');
//         }
//       }

//       // Process BMI data
//       for (final data in bmiData) {
//         final dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);

//         // Extract the numeric value from the HealthDataPoint
//         double? bmi;
//         if (data.value is num) {
//           bmi = (data.value as num).toDouble();
//         } else if (data.value.toString().contains('numericValue:')) {
//           // Extract the numeric value from the string representation
//           final valueStr = data.value.toString();
//           final regex = RegExp(r'numericValue: (\d+\.?\d*)');
//           final match = regex.firstMatch(valueStr);
//           if (match != null && match.groupCount >= 1) {
//             bmi = double.tryParse(match.group(1)!);
//           }
//         }

//         //print('Processing BMI: dateKey=$dateKey, bmi=$bmi');

//         if (bmi != null && entriesByDate.containsKey(dateKey)) {
//           // Update existing entry with BMI
//           final existingEntry = entriesByDate[dateKey]!;
//           entriesByDate[dateKey] = existingEntry.copyWith(bmi: bmi);
//         } else if (bmi != null) {
//           //print('No matching weight entry found for BMI on $dateKey');
//         } else {
//           //print('Failed to parse BMI value: ${data.value}');
//         }
//       }

//       //print('Final processed entries: ${entriesByDate.length}');
//       return entriesByDate.values.toList();
//     } catch (e) {
//       //print('Error fetching weight data from health: $e');
//       //print('Error stack trace: ${StackTrace.current}');
//       return [];
//     }
//   }

//   /// Clear the synced entries cache (useful for testing or manual reset)
//   void clearSyncedEntriesCache() {
//     _syncedEntries.clear();
//   }

//   /// Perform a two-way sync between the app and health services
//   /// @return Future<bool> Whether the sync was successful
//   Future<bool> performTwoWaySync() async {
//     try {
//       debugPrint('Starting two-way sync');
//       final authorized = await requestAuthorization();
//       if (!authorized) {
//         debugPrint('Health data authorization failed during sync');
//         return false;
//       }
//       debugPrint('Health data authorization successful for sync');

//       // Get the date range for syncing - use a wider range to ensure we get all data
//       final earliestDate =
//           await _weightRepository.getEarliestEntry() ??
//           DateTime.now().subtract(
//             const Duration(days: 730),
//           ); // 2 years instead of 1
//       final latestDate = DateTime.now().add(
//         const Duration(days: 1),
//       ); // Include today
//       debugPrint('Sync date range: $earliestDate to $latestDate');

//       // Step 1: Fetch all entries from our app database
//       final appEntries = await _weightRepository.getAllBodyEntries();
//       //print('App entries fetched: ${appEntries.length}');

//       // Step 2: Sync app data to health services
//       //print('Syncing app data to health services...');
//       await syncDataToHealth(appEntries);
//       //print('App data synced to health services');

//       // Step 3: Fetch data from health services
//       //print('Fetching data from health services...');
//       final healthEntries = await fetchtDataFromHealth(
//         earliestDate,
//         latestDate,
//       );
//       //print('Health entries fetched: ${healthEntries.length}');

//       // Step 4: For each health entry, check if we need to add it to our app
//       //print('Processing health entries for database update...');
//       final Database db = await DatabaseHelper().database;
//       bool syncSuccess = true;

//       for (final healthEntry in healthEntries) {
//         // Skip entries that don't have essential data (weight is required)
//         if (healthEntry.weight == null) {
//           debugPrint(
//             'Skipping health entry with null weight for date: ${healthEntry.date}',
//           );
//           continue;
//         }

//         // Check if this entry already exists in our database
//         final existingEntryId = await DatabaseHelper().findEntryIdByDate(
//           healthEntry.date,
//         );

//         if (existingEntryId == null) {
//           // This is a new entry from health services, add it to our database
//           try {
//             final insertResult = await DatabaseHelper().insertBodyEntry(
//               healthEntry,
//             );
//             syncSuccess = syncSuccess && insertResult > 0;
//           } catch (e) {
//             debugPrint('Error inserting health entry: $e');
//             syncSuccess = false;
//           }
//         } else {
//           // This entry already exists, check if values are identical before updating
//           final existingEntry = await DatabaseHelper().findEntryByDate(
//             healthEntry.date,
//           );

//           if (existingEntry != null) {
//             // Check if the values are identical to avoid unnecessary updates
//             bool isDuplicate = _isIdenticalEntry(existingEntry, healthEntry);

//             if (isDuplicate) {
//               continue; // Skip this entry as it's a duplicate
//             }

//             // Create a merged entry that preserves existing data and only updates non-null health data
//             final mergedEntry = existingEntry.copyWith(
//               // Only update weight if health entry has a valid weight
//               weight: healthEntry.weight ?? existingEntry.weight,
//               // Only update fat percentage if health entry has it
//               fatPercentage:
//                   healthEntry.fatPercentage ?? existingEntry.fatPercentage,
//               // Only update BMI if health entry has it
//               bmi: healthEntry.bmi ?? existingEntry.bmi,
//             );

//             // Use DatabaseHelper's updateBodyEntry method
//             try {
//               final updateResult = await DatabaseHelper().updateBodyEntry(
//                 existingEntryId,
//                 mergedEntry,
//               );
//               syncSuccess = syncSuccess && updateResult > 0;
//             } catch (e) {
//               debugPrint('Error updating health entry: $e');
//               syncSuccess = false;
//             }
//           }
//         }
//       }

//       //print('Two-way sync completed with success: $syncSuccess');
//       return syncSuccess;
//     } catch (e) {
//       //print('Error performing two-way sync: $e');
//       //print('Error stack trace: ${StackTrace.current}');
//       return false;
//     }
//   }

//   /// Checks if two BodyEntry objects have identical values for weight, fat percentage, and BMI
//   /// @param entry1 First BodyEntry to compare
//   /// @param entry2 Second BodyEntry to compare
//   /// @return bool True if entries have identical values, false otherwise
//   bool _isIdenticalEntry(BodyEntry entry1, BodyEntry entry2) {
//     // Compare weight values (if both are null or equal)
//     final weightMatch =
//         (entry1.weight == null && entry2.weight == null) ||
//         (entry1.weight != null &&
//             entry2.weight != null &&
//             (entry1.weight! - entry2.weight!).abs() < 0.001);

//     // Compare fat percentage values (if both are null or equal)
//     final fatMatch =
//         (entry1.fatPercentage == null && entry2.fatPercentage == null) ||
//         (entry1.fatPercentage != null &&
//             entry2.fatPercentage != null &&
//             (entry1.fatPercentage! - entry2.fatPercentage!).abs() < 0.001);

//     // Compare BMI values (if both are null or equal)
//     final bmiMatch =
//         (entry1.bmi == null && entry2.bmi == null) ||
//         (entry1.bmi != null &&
//             entry2.bmi != null &&
//             (entry1.bmi! - entry2.bmi!).abs() < 0.001);

//     // Entry is considered identical if all available values match
//     return weightMatch && fatMatch && bmiMatch;
//   }
// }

// /// Extension to simplify platform checks
// extension PlatformExtension on TargetPlatform {
//   bool get isIOS => this == TargetPlatform.iOS;
//   bool get isAndroid => this == TargetPlatform.android;
// }
