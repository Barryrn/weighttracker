import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'body_entry.dart';

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
  static const int _databaseVersion = 1;
  
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
  static const String columnImagePath = 'image_path';
  
  /// Get the database instance, creating it if it doesn't exist
  /// @return Future<Database> The database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize the database by creating the database file and tables
  /// @return Future<Database> The initialized database
  Future<Database> _initDatabase() async {
    // Get the directory for the database file
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    
    // Open/create the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  
  /// Create the database tables
  /// @param db The database instance
  /// @param version The database version
  Future<void> _onCreate(Database db, int version) async {
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
        $columnImagePath TEXT
      )
    ''');
  }
  
  /// Insert a new body entry into the database
  /// @param bodyEntry The BodyEntry object to insert
  /// @return Future<int> The ID of the inserted entry
  Future<int> insertBodyEntry(BodyEntry bodyEntry) async {
    Database db = await database;
    
    // Convert the BodyEntry object to a map for database storage
    Map<String, dynamic> row = {
      columnWeight: bodyEntry.weight,
      columnDate: bodyEntry.date.millisecondsSinceEpoch,
      columnFatPercentage: bodyEntry.fatPercentage,
      columnNeckCircumference: bodyEntry.neckCircumference,
      columnWaistCircumference: bodyEntry.waistCircumference,
      columnHipCircumference: bodyEntry.hipCircumference,
      columnTags: bodyEntry.tags?.join(','),
      columnNotes: bodyEntry.notes,
      columnImagePath: bodyEntry.imagePath,
    };
    
    return await db.insert(tableBodyEntries, row);
  }
  
  /// Query all body entries from the database
  /// @return Future<List<BodyEntry>> List of all body entries
  Future<List<BodyEntry>> queryAllBodyEntries() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableBodyEntries, orderBy: '$columnDate DESC');
    
    return List.generate(maps.length, (i) {
      // Create and return a BodyEntry object
      return BodyEntry(
        weight: maps[i][columnWeight],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i][columnDate]),
        fatPercentage: maps[i][columnFatPercentage],
        neckCircumference: maps[i][columnNeckCircumference],
        waistCircumference: maps[i][columnWaistCircumference],
        hipCircumference: maps[i][columnHipCircumference],
        tags: maps[i][columnTags] != null ? maps[i][columnTags].split(',') : null,
        notes: maps[i][columnNotes],
        imagePath: maps[i][columnImagePath],
      );
    });
  }
  
  /// Update an existing body entry in the database
  /// @param id The ID of the entry to update
  /// @param bodyEntry The updated BodyEntry object
  /// @return Future<int> The number of rows affected
  Future<int> updateBodyEntry(int id, BodyEntry bodyEntry) async {
    Database db = await database;
    
    // Convert the BodyEntry object to a map for database storage
    Map<String, dynamic> row = {
      columnWeight: bodyEntry.weight,
      columnDate: bodyEntry.date.millisecondsSinceEpoch,
      columnFatPercentage: bodyEntry.fatPercentage,
      columnNeckCircumference: bodyEntry.neckCircumference,
      columnWaistCircumference: bodyEntry.waistCircumference,
      columnHipCircumference: bodyEntry.hipCircumference,
      columnTags: bodyEntry.tags?.join(','),
      columnNotes: bodyEntry.notes,
      columnImagePath: bodyEntry.imagePath,
    };
    
    return await db.update(
      tableBodyEntries, 
      row,
      where: '$columnId = ?', 
      whereArgs: [id],
    );
  }
  
  /// Delete a body entry from the database
  /// @param id The ID of the entry to delete
  /// @return Future<int> The number of rows affected
  Future<int> deleteBodyEntry(int id) async {
    Database db = await database;
    return await db.delete(
      tableBodyEntries, 
      where: '$columnId = ?', 
      whereArgs: [id],
    );
  }
}