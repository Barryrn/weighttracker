import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../Model/database_helper.dart';
import '../Model/body_entry_model.dart';

/// Data class that holds the tag settings information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (TagSettingsView).
class TagSettingsData {
  final List<String> allTags;
  final bool isLoading;
  final String? error;

  TagSettingsData({required this.allTags, this.isLoading = false, this.error});

  /// Creates a copy of this TagSettingsData with the given fields replaced with new values
  TagSettingsData copyWith({
    List<String>? allTags,
    bool? isLoading,
    String? error,
  }) {
    return TagSettingsData(
      allTags: allTags ?? this.allTags,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// A ViewModel that manages tag settings information.
///
/// This class follows the MVVM pattern by processing data from the database
/// and transforming it into a format that's ready for display in the View.
class TagSettingsViewModel extends StateNotifier<TagSettingsData> {
  TagSettingsViewModel(this.ref)
    : super(TagSettingsData(allTags: [], isLoading: true)) {
    loadAllTags();
  }

  final Ref ref;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Logs the current state of the tag settings
  void _logState() {
    developer.log('===== Tag Settings ViewModel State =====');
    developer.log('All Tags: ${state.allTags}');
    developer.log('Is Loading: ${state.isLoading}');
    developer.log('Error: ${state.error}');
    developer.log('===================================');
  }

  /// Loads all unique tags from the database
  Future<void> loadAllTags() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get all body entries from the database
      final entries = await _dbHelper.queryAllBodyEntries();

      // Extract all unique tags
      final Set<String> uniqueTags = {};
      for (final entry in entries) {
        if (entry.tags != null && entry.tags!.isNotEmpty) {
          // Filter out empty tags before adding to the set
          uniqueTags.addAll(entry.tags!.where((tag) => tag.trim().isNotEmpty));
        }
      }

      // Sort tags alphabetically
      final sortedTags = uniqueTags.toList()..sort();

      state = state.copyWith(allTags: sortedTags, isLoading: false);

      _logState();
    } catch (e) {
      developer.log('Error loading tags: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tags: $e',
      );
    }
  }

  /// Deletes a tag from all entries in the database
  Future<void> deleteTag(String tag) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get all body entries from the database
      final entries = await _dbHelper.queryAllBodyEntries();

      // Get the raw database entries to access their IDs
      final db = await _dbHelper.database;
      List<Map<String, dynamic>> rawEntries = await db.query(
        DatabaseHelper.tableBodyEntries,
        orderBy: '${DatabaseHelper.columnDate} DESC',
      );

      // Update entries that contain the tag
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.tags != null) {
          bool tagFound = false;

          // For empty tags, we need to check differently
          if (tag.isEmpty) {
            tagFound = entry.tags!.contains('');
          } else {
            tagFound = entry.tags!.contains(tag);
          }

          if (tagFound) {
            // Create a new list without the tag
            final updatedTags = List<String>.from(entry.tags!)
              ..removeWhere((t) => t == tag);

            // Create updated entry
            final updatedEntry = entry.copyWith(tags: updatedTags);

            // Get the actual database ID from the raw entries
            final dbId = rawEntries[i][DatabaseHelper.columnId];

            // Update in database using the correct ID
            await _dbHelper.updateBodyEntry(dbId, updatedEntry);
          }
        }
      }

      // Reload tags after deletion
      await loadAllTags();
    } catch (e) {
      developer.log('Error deleting tag: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete tag: $e',
      );
    }
  }

  /// Removes all empty tags from database entries
  Future<void> cleanupEmptyTags() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get all body entries from the database
      final entries = await _dbHelper.queryAllBodyEntries();

      // Get the raw database entries to access their IDs
      final db = await _dbHelper.database;
      List<Map<String, dynamic>> rawEntries = await db.query(
        DatabaseHelper.tableBodyEntries,
        orderBy: '${DatabaseHelper.columnDate} DESC',
      );

      // Update entries that contain empty tags
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        if (entry.tags != null && entry.tags!.contains('')) {
          // Create a new list without empty tags
          final updatedTags = List<String>.from(entry.tags!)
            ..removeWhere((t) => t.trim().isEmpty);

          // Create updated entry
          final updatedEntry = entry.copyWith(tags: updatedTags);

          // Get the actual database ID from the raw entries
          final dbId = rawEntries[i][DatabaseHelper.columnId];

          // Update in database using the correct ID
          await _dbHelper.updateBodyEntry(dbId, updatedEntry);
        }
      }

      // Reload tags after cleanup
      await loadAllTags();
    } catch (e) {
      developer.log('Error cleaning up empty tags: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clean up empty tags: $e',
      );
    }
  }
}

/// A provider for accessing the TagSettingsViewModel.
///
/// This provider makes the TagSettingsViewModel available to widgets
/// that need to display and modify tag settings information.
final tagSettingsProvider =
    StateNotifierProvider<TagSettingsViewModel, TagSettingsData>(
      (ref) => TagSettingsViewModel(ref),
    );
