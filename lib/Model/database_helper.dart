import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'body_entry_model.dart';
import 'profile_settings_storage_model.dart';

/// DatabaseHelper class for managing SQLite database operations
/// Follows singleton pattern to ensure only one instance exists
class DatabaseHelper {
  // Singleton pattern implementation
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Database name and version constants
  static const String _databaseName = "weight_tracker.db";
  static const int _databaseVersion =
      4; // Increased version number for schema update

  /// Table and column names
  static const String tableBodyEntries = 'body_entries';
  static const String columnId = 'id';
  static const String columnWeight = 'weight';
  static const String columnDate = 'date';
  static const String columnFatPercentage = 'fat_percentage';
  static const String columnNeckCircumference = 'neck_circumference';
  static const String columnWaistCircumference = 'waist_circumference';
  static const String columnHipCircumference = 'hip_circumference';
  static const String columnTags = 'tags';
  static const String columnNotes = 'notes';
  static const String columnFrontImagePath = 'front_image_path';
  static const String columnSideImagePath = 'side_front_image_path';
  static const String columnBackImagePath = 'back_front_image_path';
  static const String columnBMI = 'bmi'; // Added BMI column

  /// Get the database instance, creating it if it doesn't exist
  /// @return Future<Database> The database instance
  Future<Database> get database async {
    try {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error getting database: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Initialize the database by creating the database file and tables
  /// @return Future<Database> The initialized database
  Future<Database> _initDatabase() async {
    try {
      // Get the directory for the database file
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);

      // Open/create the database
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Error initializing database: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Create the database tables
  /// @param db The database instance
  /// @param version The database version
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $tableBodyEntries (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnWeight REAL NOT NULL,
          $columnDate INTEGER NOT NULL,
          $columnFatPercentage REAL,
          $columnNeckCircumference REAL,
          $columnWaistCircumference REAL,
          $columnHipCircumference REAL,
          $columnTags TEXT,
          $columnNotes TEXT,
          $columnFrontImagePath TEXT,
          $columnSideImagePath TEXT,
          $columnBackImagePath TEXT,
          $columnBMI REAL
        )
      ''');
    } catch (e) {
      print('Error creating database tables: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Handle database upgrades
  /// @param db The database instance
  /// @param oldVersion The old database version
  /// @param newVersion The new database version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 3) {
        // Add BMI column to existing table
        await db.execute('''
          ALTER TABLE $tableBodyEntries ADD COLUMN $columnBMI REAL;
        ''');

        // Update existing records with calculated BMI
        await _updateExistingRecordsWithBMI(db);
      }
    } catch (e) {
      print('Error upgrading database: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Update existing records with calculated BMI values
  /// @param db The database instance
  Future<void> _updateExistingRecordsWithBMI(Database db) async {
    try {
      // Get all existing records
      final List<Map<String, dynamic>> records = await db.query(
        tableBodyEntries,
      );

      // Get user's height from profile settings
      final profileSettings =
          await ProfileSettingsStorage.loadProfileSettings();
      final height = profileSettings.height;

      if (height == null) {
        print(
          'Height not available in profile settings, skipping BMI calculation for existing records',
        );
        return;
      }

      // Calculate and update BMI for each record
      for (var record in records) {
        final weight = record[columnWeight] as double?;

        if (weight != null) {
          // Calculate BMI using the formula: BMI = weight (kg) / [height (cm) ÷ 100]²
          final bmi = calculateBMI(weight, height);

          // Update the record with the calculated BMI
          await db.update(
            tableBodyEntries,
            {columnBMI: bmi},
            where: '$columnId = ?',
            whereArgs: [record[columnId]],
          );
        }
      }
    } catch (e) {
      print('Error updating existing records with BMI: $e');
      // Don't throw here to avoid breaking the upgrade process
    }
  }

  /// Calculate BMI using the formula: BMI = weight (kg) / [height (cm) ÷ 100]²
  /// @param weight Weight in kg
  /// @param height Height in cm
  /// @return Calculated BMI value
  double calculateBMI(double weight, double height) {
    // Convert height from cm to meters
    final heightInMeters = height / 100;
    // Calculate BMI
    return weight / (heightInMeters * heightInMeters);
  }

  /// Insert a new body entry into the database
  /// If an entry already exists for the same day, it will be overwritten
  /// @param bodyEntry The BodyEntry object to insert
  /// @return Future<int> The ID of the inserted or updated entry
  Future<int> insertBodyEntry(BodyEntry bodyEntry) async {
    try {
      Database db = await database;

      // Normalize the date to start of day to ensure consistent comparison
      final normalizedDate = DateTime(
        bodyEntry.date.year,
        bodyEntry.date.month,
        bodyEntry.date.day,
      );

      // Convert the normalized date to milliseconds
      final dateMillis = normalizedDate.millisecondsSinceEpoch;

      // Check if an entry already exists for this day
      final List<Map<String, dynamic>> existingEntries = await db.query(
        tableBodyEntries,
        where: '$columnDate >= ? AND $columnDate < ?',
        whereArgs: [
          dateMillis,
          dateMillis + 86400000, // Add 24 hours in milliseconds
        ],
      );

      // Calculate BMI if weight is available
      double? bmi;
      if (bodyEntry.weight != null) {
        // Get height from profile settings
        final profileSettings =
            await ProfileSettingsStorage.loadProfileSettings();
        final height = profileSettings.height;

        if (height != null) {
          // Calculate BMI
          bmi = calculateBMI(bodyEntry.weight!, height);
        }
      }

      // Convert the BodyEntry object to a map for database storage
      Map<String, dynamic> row = {
        columnWeight: bodyEntry.weight,
        columnDate: dateMillis, // Use normalized date
        columnFatPercentage: bodyEntry.fatPercentage,
        columnNeckCircumference: bodyEntry.neckCircumference,
        columnWaistCircumference: bodyEntry.waistCircumference,
        columnHipCircumference: bodyEntry.hipCircumference,
        columnTags: bodyEntry.tags?.join(','),
        columnNotes: bodyEntry.notes,
        columnFrontImagePath: bodyEntry.frontImagePath,
        columnSideImagePath: bodyEntry.sideImagePath,
        columnBackImagePath: bodyEntry.backImagePath,
        columnBMI: bmi, // Add calculated BMI
      };
      print('Inserting into DB: $bodyEntry with BMI: $bmi');

      // If an entry exists for this day, update it
      if (existingEntries.isNotEmpty) {
        final existingId = existingEntries.first[columnId];
        return await db.update(
          tableBodyEntries,
          row,
          where: '$columnId = ?',
          whereArgs: [existingId],
        );
      }
      // Otherwise, insert a new entry
      else {
        return await db.insert(tableBodyEntries, row);
      }
    } catch (e) {
      print('Error inserting body entry: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  Future<void> printAllBodyEntries() async {
    try {
      final entries = await queryAllBodyEntries();

      if (entries.isEmpty) {
        print('No body entries found.');
        return;
      }

      for (var entry in entries) {
        print(entry); // This uses the toString() method of BodyEntry
      }
    } catch (e) {
      print('Error printing body entries: $e');
      // No need to re-throw as this is a void method for debugging
    }
  }

  /// Query all body entries from the database
  /// @return Future<List<BodyEntry>> List of all body entries
  Future<List<BodyEntry>> queryAllBodyEntries() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        tableBodyEntries,
        orderBy: '$columnDate DESC',
      );

      return List.generate(maps.length, (i) {
        // Create and return a BodyEntry object
        return BodyEntry(
          weight: maps[i][columnWeight],
          date: DateTime.fromMillisecondsSinceEpoch(maps[i][columnDate]),
          fatPercentage: maps[i][columnFatPercentage],
          neckCircumference: maps[i][columnNeckCircumference],
          waistCircumference: maps[i][columnWaistCircumference],
          hipCircumference: maps[i][columnHipCircumference],
          tags: maps[i][columnTags] != null
              ? maps[i][columnTags].split(',')
              : null,
          notes: maps[i][columnNotes],
          frontImagePath: maps[i][columnFrontImagePath],
          sideImagePath: maps[i][columnSideImagePath],
          backImagePath: maps[i][columnBackImagePath],
          bmi: maps[i][columnBMI], // Added BMI field
        );
      });
    } catch (e) {
      print('Error querying all body entries: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Update an existing body entry in the database
  /// @param id The ID of the entry to update
  /// @param bodyEntry The updated BodyEntry object
  /// @return Future<int> The number of rows affected
  Future<int> updateBodyEntry(int id, BodyEntry bodyEntry) async {
    try {
      Database db = await database;

      // Normalize the date to start of day
      final normalizedDate = DateTime(
        bodyEntry.date.year,
        bodyEntry.date.month,
        bodyEntry.date.day,
      );

      // Convert the BodyEntry object to a map for database storage
      Map<String, dynamic> row = {
        columnWeight: bodyEntry.weight,
        columnDate: normalizedDate.millisecondsSinceEpoch,
        columnFatPercentage: bodyEntry.fatPercentage,
        columnNeckCircumference: bodyEntry.neckCircumference,
        columnWaistCircumference: bodyEntry.waistCircumference,
        columnHipCircumference: bodyEntry.hipCircumference,
        columnTags: bodyEntry.tags?.join(','),
        columnNotes: bodyEntry.notes,
        columnFrontImagePath: bodyEntry.frontImagePath,
        columnSideImagePath: bodyEntry.sideImagePath,
        columnBackImagePath: bodyEntry.backImagePath,
      };

      return await db.update(
        tableBodyEntries,
        row,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error updating body entry: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Delete a body entry from the database
  /// @param id The ID of the entry to delete
  /// @return Future<int> The number of rows affected
  Future<int> deleteBodyEntry(int id) async {
    try {
      Database db = await database;
      return await db.delete(
        tableBodyEntries,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting body entry: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Find an entry by date
  /// @param date The date to search for
  /// @return Future<BodyEntry?> The entry for the given date, or null if not found
  Future<BodyEntry?> findEntryByDate(DateTime date) async {
    try {
      Database db = await database;

      // Normalize the date to start of day
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateMillis = normalizedDate.millisecondsSinceEpoch;

      final List<Map<String, dynamic>> result = await db.query(
        tableBodyEntries,
        where: '$columnDate >= ? AND $columnDate < ?',
        whereArgs: [
          dateMillis,
          dateMillis + 86400000, // Add 24 hours in milliseconds
        ],
      );

      if (result.isEmpty) {
        return null;
      }

      return BodyEntry(
        weight: result.first[columnWeight],
        date: DateTime.fromMillisecondsSinceEpoch(result.first[columnDate]),
        fatPercentage: result.first[columnFatPercentage],
        neckCircumference: result.first[columnNeckCircumference],
        waistCircumference: result.first[columnWaistCircumference],
        hipCircumference: result.first[columnHipCircumference],
        tags: result.first[columnTags] != null
            ? result.first[columnTags].split(',')
            : null,
        notes: result.first[columnNotes],
        frontImagePath: result.first[columnFrontImagePath],
        sideImagePath: result.first[columnSideImagePath],
        backImagePath: result.first[columnBackImagePath],
      );
    } catch (e) {
      print('Error finding entry by date: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Get and print the database file path
  /// @return Future<String> The path to the database file
  Future<String> getDatabasePath() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, _databaseName);
      print('Database path: $path');
      return path;
    } catch (e) {
      print('Error getting database path: $e');
      throw e; // Re-throw to allow handling by caller
    }
  }

  /// Print the database file path
  /// Convenience method that just calls getDatabasePath()
  Future<void> printDatabasePath() async {
    try {
      await getDatabasePath();
    } catch (e) {
      print('Error printing database path: $e');
      // No need to re-throw as this is a void method for debugging
    }
  }
}
