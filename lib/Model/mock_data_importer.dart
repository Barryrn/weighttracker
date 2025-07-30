import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'database_helper.dart';
import 'body_entry_model.dart';

/// Utility class for importing mock data from JSON file into SQLite database
class MockDataImporter {
  /// Singleton pattern implementation
  static final MockDataImporter _instance = MockDataImporter._internal();
  factory MockDataImporter() => _instance;
  MockDataImporter._internal();

  /// Database helper instance
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Safely converts a value to double, handling "nan" and null values
  /// @param value The value to convert
  /// @return double? The converted value or null if conversion fails
  double? _safeParseDouble(dynamic value) {
    if (value == null || value == "nan" || value == "null" || value == "None") {
      return null;
    }
    return double.tryParse(value.toString());
  }

  /// Import mock data from the JSON file into the database
  /// @return Future<int> The number of entries imported
  Future<int> importMockData() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(
        'assets/mock_data.json',
      );

      // Parse the JSON string into a list of maps
      final List<dynamic> jsonList = json.decode(jsonString);

      int importedCount = 0;

      // Process each entry in the JSON list
      for (var jsonEntry in jsonList) {
        // Handle tags - in JSON it's a string, but in model it's a list
        List<String>? tags;
        if (jsonEntry['tags'] != null &&
            jsonEntry['tags'] != "None" &&
            jsonEntry['tags'] != "null") {
          tags = [jsonEntry['tags']]; // Convert single tag to list
        }

        // Handle image paths - convert "None" strings to null
        String? frontImagePath = jsonEntry['front_image_path'];
        if (frontImagePath == "None" || frontImagePath == "null") {
          frontImagePath = null;
        }

        String? sideImagePath = jsonEntry['side_front_image_path'];
        if (sideImagePath == "None" || sideImagePath == "null") {
          sideImagePath = null;
        }

        String? backImagePath = jsonEntry['back_front_image_path'];
        if (backImagePath == "None" || backImagePath == "null") {
          backImagePath = null;
        }

        // Create a BodyEntry object from the JSON data
        final bodyEntry = BodyEntry(
          date: DateTime.fromMillisecondsSinceEpoch(jsonEntry['date']),
          weight: _safeParseDouble(jsonEntry['weight']),
          fatPercentage: _safeParseDouble(jsonEntry['fat_percentage']),
          neckCircumference: _safeParseDouble(jsonEntry['neck_circumference']),
          waistCircumference: _safeParseDouble(
            jsonEntry['waist_circumference'],
          ),
          hipCircumference: _safeParseDouble(jsonEntry['hip_circumference']),
          tags: tags,
          notes: jsonEntry['notes'] == "None" ? null : jsonEntry['notes'],
          frontImagePath: frontImagePath,
          sideImagePath: sideImagePath,
          backImagePath: backImagePath,
          calorie: _safeParseDouble(jsonEntry['calorie']),
        );

        // Insert the entry into the database
        await _dbHelper.insertBodyEntry(bodyEntry);
        importedCount++;
      }

      print('Successfully imported $importedCount entries from mock data');
      return importedCount;
    } catch (e) {
      print('Error importing mock data: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }
}
