import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/database_helper.dart';
import 'dart:developer' as developer;

/// A provider that fetches the latest weight entry from the database.
///
/// This provider follows the MVVM pattern by acting as the ViewModel that connects
/// the Model (database) with the View (weight progress widget).
class LatestWeightNotifier extends StateNotifier<BodyEntry?> {
  LatestWeightNotifier() : super(null) {
    _loadLatestEntry();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Loads the latest weight entry from the database
  Future<void> _loadLatestEntry() async {
    try {
      final entries = await _dbHelper.queryAllBodyEntries();
      if (entries.isNotEmpty) {
        // The entries are already sorted by date in descending order
        state = entries.first;
        _logState();
      }
    } catch (e) {
      developer.log('Error loading latest weight entry: $e');
    }
  }

  /// Refreshes the latest weight entry from the database
  /// This should be called when a new entry is added
  Future<void> refreshLatestEntry() async {
    await _loadLatestEntry();
  }

  /// Logs the current state of the latest weight entry
  void _logState() {
    developer.log('===== Latest Weight Provider State =====');
    if (state != null) {
      developer.log('Date: ${state!.date}');
      developer.log('Weight: ${state!.weight}');
    } else {
      developer.log('No weight entries found');
    }
    developer.log('===================================');
  }
}

/// A provider for accessing the latest weight entry.
///
/// This provider makes the LatestWeightNotifier available to widgets
/// that need to read the latest weight entry.
final latestWeightProvider = StateNotifierProvider<LatestWeightNotifier, BodyEntry?>(
  (ref) => LatestWeightNotifier(),
);