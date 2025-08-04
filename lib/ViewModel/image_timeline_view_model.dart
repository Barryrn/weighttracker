import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/database_helper.dart';
import '../provider/database_change_provider.dart';

/// Data class to hold the state for the image timeline
class ImageTimelineState {
  final List<BodyEntry> entries;
  final int selectedIndex;
  final String selectedView; // 'front', 'side', or 'back'
  final bool isLoading;
  final String? errorMessage;

  ImageTimelineState({
    required this.entries,
    required this.selectedIndex,
    required this.selectedView,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  ImageTimelineState copyWith({
    List<BodyEntry>? entries,
    int? selectedIndex,
    String? selectedView,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ImageTimelineState(
      entries: entries ?? this.entries,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedView: selectedView ?? this.selectedView,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for the image timeline feature
/// This follows the MVVM pattern by separating business logic from the UI
class ImageTimelineViewModel extends StateNotifier<ImageTimelineState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Ref ref;

  ImageTimelineViewModel(this.ref)
    : super(
        ImageTimelineState(
          entries: [],
          selectedIndex: 0,
          selectedView: 'front',
          isLoading: true,
        ),
      ) {
    // Load entries when the ViewModel is initialized
    loadEntries();

    // Listen for database changes
    ref.listen(databaseChangeProvider, (previous, next) {
      if (previous != next) {
        loadEntries();
      }
    });
  }

  /// Loads all entries with images from the database
  Future<void> loadEntries() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Get all entries from the database
      final allEntries = await _dbHelper.queryAllBodyEntries();

      // Filter entries to only include those with at least one image
      final entriesWithImages = allEntries.where((entry) {
        return entry.frontImagePath != null ||
            entry.sideImagePath != null ||
            entry.backImagePath != null;
      }).toList();

      // Sort by date (oldest first)
      entriesWithImages.sort(
        (a, b) => a.date.compareTo(b.date),
      ); // oldest first

      // Update state with the loaded entries
      state = state.copyWith(
        entries: entriesWithImages,
        isLoading: false,
        selectedIndex: entriesWithImages.isNotEmpty ? 0 : 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading entries: $e',
      );
    }
  }

  /// Updates the selected index (position in the timeline)
  void updateSelectedIndex(int index) {
    if (index >= 0 && index < state.entries.length) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  /// Updates the selected view type (front, side, or back)
  void updateSelectedView(String viewType) {
    if (viewType == 'front' || viewType == 'side' || viewType == 'back') {
      state = state.copyWith(selectedView: viewType);

      // After changing the view type, find the first entry that has an image for this view
      final availableEntries = state.entries.where((entry) {
        switch (viewType) {
          case 'front':
            return entry.frontImagePath != null;
          case 'side':
            return entry.sideImagePath != null;
          case 'back':
            return entry.backImagePath != null;
          default:
            return false;
        }
      }).toList();

      // If there are entries with this view type, select the first one
      if (availableEntries.isNotEmpty) {
        final index = state.entries.indexOf(availableEntries.first);
        if (index >= 0) {
          state = state.copyWith(selectedIndex: index);
        }
      }
    }
  }

  /// Gets the image path for the current selected entry and view type
  String? getCurrentImagePath() {
    if (state.entries.isEmpty || state.selectedIndex >= state.entries.length) {
      return null;
    }

    final entry = state.entries[state.selectedIndex];

    switch (state.selectedView) {
      case 'front':
        return entry.frontImagePath;
      case 'side':
        return entry.sideImagePath;
      case 'back':
        return entry.backImagePath;
      default:
        return null;
    }
  }

  /// Gets all available dates with images for the selected view type
  List<DateTime> getAvailableDates() {
    return state.entries
        .where((entry) {
          switch (state.selectedView) {
            case 'front':
              return entry.frontImagePath != null;
            case 'side':
              return entry.sideImagePath != null;
            case 'back':
              return entry.backImagePath != null;
            default:
              return false;
          }
        })
        .map((entry) => entry.date)
        .toList();
  }

  /// Gets the current entry based on the selected index
  BodyEntry? getCurrentEntry() {
    if (state.entries.isEmpty || state.selectedIndex >= state.entries.length) {
      return null;
    }
    return state.entries[state.selectedIndex];
  }
}

/// Provider for accessing the ImageTimelineViewModel
final imageTimelineProvider =
    StateNotifierProvider<ImageTimelineViewModel, ImageTimelineState>(
      (ref) => ImageTimelineViewModel(ref),
    );
