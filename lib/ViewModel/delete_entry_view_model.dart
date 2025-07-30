import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/database_helper.dart';
import '../provider/database_change_provider.dart';

/// Provider for the DeleteEntryViewModel
final deleteEntryViewModelProvider = Provider((ref) {
  return DeleteEntryViewModel(ref);
});

/// ViewModel for handling the deletion of body entries
/// This follows the MVVM pattern by separating the business logic from the UI
class DeleteEntryViewModel {
  final ProviderRef _ref;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DeleteEntryViewModel(this._ref);

  /// Deletes a body entry for the given date
  /// @param date The date of the entry to delete
  /// @return Future<bool> Whether the deletion was successful
  Future<bool> deleteEntryForDate(DateTime date) async {
    try {
      print('DeleteEntryViewModel: Attempting to delete entry for date: $date');
      
      // Find the entry ID for the given date
      final entryId = await _dbHelper.findEntryIdByDate(date);
      
      // If no entry exists for this date, return false
      if (entryId == null) {
        print('DeleteEntryViewModel: No entry found for date: $date');
        return false;
      }
      
      print('DeleteEntryViewModel: Found entry with ID: $entryId for date: $date');
      
      // Delete the entry
      final rowsAffected = await _dbHelper.deleteBodyEntry(entryId);
      print('DeleteEntryViewModel: Deleted entry, rows affected: $rowsAffected');
      
      // Notify that the database has changed
      print('DeleteEntryViewModel: About to notify database changed');
      _ref.read(databaseChangeProvider.notifier).notifyDatabaseChanged();
      print('DeleteEntryViewModel: Database change notification sent');
      
      // Return true if at least one row was affected
      return rowsAffected > 0;
    } catch (e) {
      print('Error deleting entry: $e');
      return false;
    }
  }

  /// Checks if an entry exists for the given date
  /// @param date The date to check
  /// @return Future<bool> Whether an entry exists for the given date
  Future<bool> hasEntryForDate(DateTime date) async {
    try {
      final entryId = await _dbHelper.findEntryIdByDate(date);
      return entryId != null;
    } catch (e) {
      print('Error checking if entry exists: $e');
      return false;
    }
  }
}