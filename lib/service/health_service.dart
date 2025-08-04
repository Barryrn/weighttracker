import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weigthtracker/model/database_helper.dart';
import '../model/body_entry_model.dart';
import '../model/weight_entry_model.dart';
import '../repository/weight_repository.dart';

/// Service class for handling health data integration with Apple Health and Google Health Connect
class HealthService {
  final Health _health = Health();
  Future<void> initialize() async {
    await _health.configure(); // no parameters here anymore
  }

  final WeightRepository _weightRepository;

  // Define the types of data we want to access
  static const List<HealthDataType> _types = [
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX, // Added BMI data type
  ];

  // Define the permissions we need
  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE, // Added permission for BMI
  ];

  /// Constructor that takes a WeightRepository instance
  HealthService({WeightRepository? weightRepository})
    : _weightRepository = weightRepository ?? WeightRepository();

  /// Request authorization to access health data
  /// @return Future<bool> Whether authorization was granted
  Future<bool> requestAuthorization() async {
    try {
      // Request authorization for the specified data types
      final authorized = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      return authorized;
    } catch (e) {
      debugPrint('Error requesting health authorization: $e');
      return false;
    }
  }

  /// Check if Health Connect is available on Android
  /// @return Future<bool> Whether Health Connect is available
  Future<bool> isHealthConnectAvailable() async {
    if (!defaultTargetPlatform.isAndroid) return false;
    try {
      final status = await _health.getHealthConnectSdkStatus();
      return status == HealthConnectSdkStatus.sdkAvailable;
    } catch (e) {
      debugPrint('Error checking Health Connect availability: $e');
      return false;
    }
  }

  /// Check if Health data is available on the device
  /// @return Future<bool> Whether health data is available
  Future<bool> isHealthDataAvailable() async {
    try {
      if (defaultTargetPlatform.isIOS) {
        // On iOS, HealthKit is generally available on all iOS devices running iOS 8 or later
        // We can't directly check for HealthKit availability like we can with Health Connect,
        // but we can assume it's available and then handle any errors during authorization
        // This is a more reliable approach than using hasPermissions() which checks authorization, not availability
        return true;
      } else if (defaultTargetPlatform.isAndroid) {
        // For Android, we check if Health Connect is available
        return await isHealthConnectAvailable();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking health data availability: $e');
      return false;
    }
  }

  /// Sync weight data from the app to health services
  /// @param entries List of BodyEntry objects to sync
  /// @return Future<bool> Whether the sync was successful
  Future<bool> syncWeightDataToHealth(List<BodyEntry> entries) async {
    try {
      final authorized = await requestAuthorization();
      if (!authorized) return false;

      bool allSuccess = true;

      for (final entry in entries) {
        if (entry.weight != null) {
          // Write weight data
          final weightSuccess = await _health.writeHealthData(
            value: entry.weight!, // Required value parameter
            type: HealthDataType.WEIGHT, // Required type parameter
            startTime: entry.date, // Required startTime parameter
            endTime: entry.date, // Required endTime parameter
          );

          // Write body fat percentage data if available
          bool fatSuccess = true;
          if (entry.fatPercentage != null) {
            // Multiply by 10 to convert from decimal to percentage
            final healthFatPercentage = entry.fatPercentage! * 10;
            fatSuccess = await _health.writeHealthData(
              value: healthFatPercentage, // Fat percentage multiplied by 10
              type: HealthDataType.BODY_FAT_PERCENTAGE,
              startTime: entry.date, // Required startTime parameter
              endTime: entry.date, // Required endTime parameter
            );
          }

          // Write BMI data if available
          bool bmiSuccess = true;
          if (entry.bmi != null) {
            bmiSuccess = await _health.writeHealthData(
              value: entry.bmi!, // BMI value
              type: HealthDataType.BODY_MASS_INDEX,
              startTime: entry.date, // Required startTime parameter
              endTime: entry.date, // Required endTime parameter
            );
          }

          allSuccess = allSuccess && weightSuccess && fatSuccess && bmiSuccess;
        }
      }

      return allSuccess;
    } catch (e) {
      debugPrint('Error syncing weight data to health: $e');
      return false;
    }
  }

  /// Fetch weight data from health services
  /// @param startDate The start date for fetching data
  /// @param endDate The end date for fetching data
  /// @return Future<List<BodyEntry>> List of BodyEntry objects from health services
  Future<List<BodyEntry>> fetchWeightDataFromHealth(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      //print('Fetching health data from $startDate to $endDate');
      final authorized = await requestAuthorization();
      if (!authorized) {
        //print('Health data authorization failed');
        return [];
      }
      //print('Health data authorization successful');

      // Fetch weight data
      //print('Fetching weight data...');
      final weightData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: startDate,
        endTime: endDate,
      );
      //print('Weight data fetched: ${weightData.length} entries');

      // Debug weight data
      for (final data in weightData) {
        //print('Weight data: date=${data.dateFrom}, value=${data.value}, unit=${data.unit}, sourceId=${data.sourceId}');
      }

      // Fetch body fat percentage data
      //print('Fetching body fat data...');
      final fatData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BODY_FAT_PERCENTAGE],
        startTime: startDate,
        endTime: endDate,
      );
      //print('Fat data fetched: ${fatData.length} entries');

      // Fetch BMI data
      //print('Fetching BMI data...');
      final bmiData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BODY_MASS_INDEX],
        startTime: startDate,
        endTime: endDate,
      );
      //print('BMI data fetched: ${bmiData.length} entries');

      // Create a map to organize weight data by date
      final Map<String, BodyEntry> entriesByDate = {};

      // Process weight data
      for (final data in weightData) {
        final dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);

        // Extract the numeric value from the HealthDataPoint
        double? weight;
        if (data.value is num) {
          weight = (data.value as num).toDouble();
        } else if (data.value.toString().contains('numericValue:')) {
          // Extract the numeric value from the string representation
          final valueStr = data.value.toString();
          final regex = RegExp(r'numericValue: (\d+\.?\d*)');
          final match = regex.firstMatch(valueStr);
          if (match != null && match.groupCount >= 1) {
            weight = double.tryParse(match.group(1)!);
          }
        }

        //print('Processing weight: dateKey=$dateKey, weight=$weight');

        if (weight != null) {
          final date = DateTime(
            data.dateFrom.year,
            data.dateFrom.month,
            data.dateFrom.day,
          );
          //print('Creating BodyEntry with date=$date, weight=$weight');
          entriesByDate[dateKey] = BodyEntry(date: date, weight: weight);
        } else {
          //print('Failed to parse weight value: ${data.value}');
        }
      }

      // Process body fat percentage data
      for (final data in fatData) {
        final dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);

        // Extract the numeric value from the HealthDataPoint
        double? fatPercentage;
        if (data.value is num) {
          fatPercentage = (data.value as num).toDouble();
          // Divide by 10 to convert from percentage to decimal
          fatPercentage = fatPercentage / 10;
        } else if (data.value.toString().contains('numericValue:')) {
          // Extract the numeric value from the string representation
          final valueStr = data.value.toString();
          final regex = RegExp(r'numericValue: (\d+\.?\d*)');
          final match = regex.firstMatch(valueStr);
          if (match != null && match.groupCount >= 1) {
            fatPercentage = double.tryParse(match.group(1)!);
            // Divide by 10 to convert from percentage to decimal
            if (fatPercentage != null) {
              fatPercentage = fatPercentage / 10;
            }
          }
        }

        //print('Processing fat: dateKey=$dateKey, fatPercentage=$fatPercentage');

        if (fatPercentage != null && entriesByDate.containsKey(dateKey)) {
          // Update existing entry with fat percentage
          final existingEntry = entriesByDate[dateKey]!;
          entriesByDate[dateKey] = existingEntry.copyWith(
            fatPercentage: fatPercentage,
          );
        } else if (fatPercentage != null) {
          //print('No matching weight entry found for fat percentage on $dateKey');
        } else {
          //print('Failed to parse fat percentage value: ${data.value}');
        }
      }

      // Process BMI data
      for (final data in bmiData) {
        final dateKey = DateFormat('yyyy-MM-dd').format(data.dateFrom);

        // Extract the numeric value from the HealthDataPoint
        double? bmi;
        if (data.value is num) {
          bmi = (data.value as num).toDouble();
        } else if (data.value.toString().contains('numericValue:')) {
          // Extract the numeric value from the string representation
          final valueStr = data.value.toString();
          final regex = RegExp(r'numericValue: (\d+\.?\d*)');
          final match = regex.firstMatch(valueStr);
          if (match != null && match.groupCount >= 1) {
            bmi = double.tryParse(match.group(1)!);
          }
        }

        //print('Processing BMI: dateKey=$dateKey, bmi=$bmi');

        if (bmi != null && entriesByDate.containsKey(dateKey)) {
          // Update existing entry with BMI
          final existingEntry = entriesByDate[dateKey]!;
          entriesByDate[dateKey] = existingEntry.copyWith(bmi: bmi);
        } else if (bmi != null) {
          //print('No matching weight entry found for BMI on $dateKey');
        } else {
          //print('Failed to parse BMI value: ${data.value}');
        }
      }

      //print('Final processed entries: ${entriesByDate.length}');
      return entriesByDate.values.toList();
    } catch (e) {
      //print('Error fetching weight data from health: $e');
      //print('Error stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Perform a two-way sync between the app and health services
  /// @return Future<bool> Whether the sync was successful
  Future<bool> performTwoWaySync() async {
    try {
      //print('Starting two-way sync');
      final authorized = await requestAuthorization();
      if (!authorized) {
        //print('Health data authorization failed during sync');
        return false;
      }
      //print('Health data authorization successful for sync');

      // Get the date range for syncing
      final earliestDate =
          await _weightRepository.getEarliestEntry() ??
          DateTime.now().subtract(const Duration(days: 365));
      final latestDate = DateTime.now();
      //print('Sync date range: $earliestDate to $latestDate');

      // Step 1: Fetch all entries from our app database
      final appEntries = await _weightRepository.getAllBodyEntries();
      //print('App entries fetched: ${appEntries.length}');

      // Step 2: Sync app data to health services
      //print('Syncing app data to health services...');
      await syncWeightDataToHealth(appEntries);
      //print('App data synced to health services');

      // Step 3: Fetch data from health services
      //print('Fetching data from health services...');
      final healthEntries = await fetchWeightDataFromHealth(
        earliestDate,
        latestDate,
      );
      //print('Health entries fetched: ${healthEntries.length}');

      // Step 4: For each health entry, check if we need to add it to our app
      //print('Processing health entries for database update...');
      final Database db = await DatabaseHelper().database;
      bool syncSuccess = true;

      for (final healthEntry in healthEntries) {
        //print('Processing health entry: date=${healthEntry.date}, weight=${healthEntry.weight}');
        // Check if this entry already exists in our database
        final existingEntryId = await DatabaseHelper().findEntryIdByDate(
          healthEntry.date,
        );
        //print('Existing entry ID for date ${healthEntry.date}: $existingEntryId');

        if (existingEntryId == null) {
          //print('New entry from health services, adding to database');
          // This is a new entry from health services, add it to our database
          final entryMap = healthEntry.toMap();
          //print('Entry map for insertion: $entryMap');
          final success = await db.insert('body_entries', entryMap);
          //print('Insert result: $success');
          syncSuccess = syncSuccess && success > 0;
        } else {
          //print('Entry exists with ID: $existingEntryId, updating');
          // This entry already exists, update it BUT PRESERVE OTHER FIELDS

          // First, get the existing entry
          final existingEntry = await DatabaseHelper().findEntryByDate(
            healthEntry.date,
          );

          if (existingEntry != null) {
            // Create a merged entry that preserves existing data
            final mergedEntry = existingEntry.copyWith(
              weight: healthEntry.weight,
              fatPercentage: healthEntry.fatPercentage,
              bmi: healthEntry.bmi,
            );

            // Update with the merged data
            final entryMap = mergedEntry.toMap();
            //print('Entry map for update: $entryMap');
            final success = await db.update(
              'body_entries',
              entryMap,
              where: 'id = ?',
              whereArgs: [existingEntryId],
            );
            //print('Update result: $success');
            syncSuccess = syncSuccess && success > 0;
          } else {
            // This shouldn't happen, but just in case
            final entryMap = healthEntry.toMap();
            final success = await db.update(
              'body_entries',
              entryMap,
              where: 'id = ?',
              whereArgs: [existingEntryId],
            );
            syncSuccess = syncSuccess && success > 0;
          }
        }
      }

      //print('Two-way sync completed with success: $syncSuccess');
      return syncSuccess;
    } catch (e) {
      //print('Error performing two-way sync: $e');
      //print('Error stack trace: ${StackTrace.current}');
      return false;
    }
  }
}

/// Extension to simplify platform checks
extension PlatformExtension on TargetPlatform {
  bool get isIOS => this == TargetPlatform.iOS;
  bool get isAndroid => this == TargetPlatform.android;
}
