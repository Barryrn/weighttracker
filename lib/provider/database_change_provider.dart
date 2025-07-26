import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A simple provider to notify listeners when database changes occur.
///
/// This provider follows the MVVM pattern by acting as a communication channel
/// between different parts of the application when database changes happen.
class DatabaseChangeNotifier extends StateNotifier<int> {
  /// Creates a DatabaseChangeNotifier with initial counter value of 0.
  DatabaseChangeNotifier() : super(0);

  /// Notifies listeners that a database change has occurred.
  /// Increments the counter to trigger state changes in listeners.
  void notifyDatabaseChanged() {
    state = state + 1; // Increment to trigger state change
  }
}

/// A provider for accessing the database change notifier.
///
/// This provider makes the DatabaseChangeNotifier available to widgets
/// and other providers that need to be notified of database changes.
final databaseChangeProvider = StateNotifierProvider<DatabaseChangeNotifier, int>(
  (ref) => DatabaseChangeNotifier(),
);