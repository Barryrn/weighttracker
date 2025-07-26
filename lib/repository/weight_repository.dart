import 'package:sqflite/sqflite.dart';
import '../model/database_helper.dart';
import '../model/weight_entry_model.dart';
import '../model/body_entry_model.dart';

/// Repository class for handling weight entry database operations
class WeightRepository {
  final DatabaseHelper _dbHelper;

  /// Constructor that takes a DatabaseHelper instance
  WeightRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Get the earliest weight entry date
  /// @return Future<DateTime?> The date of the earliest entry, or null if no entries exist
  Future<DateTime?> getEarliestEntry() async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        DatabaseHelper.tableBodyEntries,
        columns: [DatabaseHelper.columnDate],
        where: '${DatabaseHelper.columnWeight} IS NOT NULL',
        orderBy: '${DatabaseHelper.columnDate} ASC',
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(
        result.first[DatabaseHelper.columnDate],
      );
    } catch (e) {
      print('Error getting earliest entry: $e');
      throw e;
    }
  }

  /// Get the latest weight entry date
  /// @return Future<DateTime?> The date of the latest entry, or null if no entries exist
  Future<DateTime?> getLatestEntry() async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        DatabaseHelper.tableBodyEntries,
        columns: [DatabaseHelper.columnDate],
        where: '${DatabaseHelper.columnWeight} IS NOT NULL',
        orderBy: '${DatabaseHelper.columnDate} DESC',
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(
        result.first[DatabaseHelper.columnDate],
      );
    } catch (e) {
      print('Error getting latest entry: $e');
      throw e;
    }
  }

  /// Get weight entries within a date range
  /// @param start The start date of the range (inclusive)
  /// @param end The end date of the range (inclusive)
  /// @return Future<List<WeightEntry>> List of weight entries in the range
  Future<List<WeightEntry>> getWeightEntriesInRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Normalize dates to start of day
      final normalizedStart = DateTime(start.year, start.month, start.day);
      // End date should be end of day
      final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        DatabaseHelper.tableBodyEntries,
        columns: [
          DatabaseHelper.columnDate,
          DatabaseHelper.columnWeight,
        ],
        where:
            '${DatabaseHelper.columnDate} >= ? AND ${DatabaseHelper.columnDate} <= ?',
        whereArgs: [
          normalizedStart.millisecondsSinceEpoch,
          normalizedEnd.millisecondsSinceEpoch,
        ],
        orderBy: '${DatabaseHelper.columnDate} ASC',
      );

      return result.map((map) {
        return WeightEntry(
          date: DateTime.fromMillisecondsSinceEpoch(map[DatabaseHelper.columnDate]),
          weight: map[DatabaseHelper.columnWeight],
        );
      }).toList();
    } catch (e) {
      print('Error getting weight entries in range: $e');
      throw e;
    }
  }

  /// Convert BodyEntry objects to WeightEntry objects
  /// @param bodyEntries List of BodyEntry objects
  /// @return List<WeightEntry> Converted list of WeightEntry objects
  List<WeightEntry> convertBodyEntriesToWeightEntries(List<BodyEntry> bodyEntries) {
    return bodyEntries
        .map((entry) => WeightEntry(
              date: entry.date,
              weight: entry.weight,
            ))
        .toList();
  }

  /// Get all weight entries
  /// @return Future<List<WeightEntry>> List of all weight entries
  Future<List<WeightEntry>> getAllWeightEntries() async {
    try {
      final bodyEntries = await _dbHelper.queryAllBodyEntries();
      return convertBodyEntriesToWeightEntries(bodyEntries);
    } catch (e) {
      print('Error getting all weight entries: $e');
      throw e;
    }
  }
}