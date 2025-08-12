import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
  List<BodyEntry> _allEntries = []; // Store all entries for filtering

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

    // Listen for filter changes
    ref.listen(imageTimelineFilterProvider, (previous, next) {
      if (previous != next) {
        _applyFilters();
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

      // Store all entries for filtering
      _allEntries = entriesWithImages;

      // Load all available tags for filtering
      _loadAllTags();

      // Apply filters
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error loading entries: $e',
      );
    }
  }

  /// Load all unique tags from entries
  void _loadAllTags() {
    final tags = <String>{};
    for (final entry in _allEntries) {
      if (entry.tags != null) {
        tags.addAll(entry.tags!);
      }
    }
    ref.read(imageTimelineFilterProvider.notifier).setAllTags(tags.toList());
  }

  /// Apply filters to entries
  void _applyFilters() {
    final filterState = ref.read(imageTimelineFilterProvider);

    // If filters aren't active, use all entries
    if (!filterState.filtersActive) {
      state = state.copyWith(
        entries: _allEntries,
        isLoading: false,
        selectedIndex: _allEntries.isNotEmpty ? 0 : 0,
      );
      return;
    }

    // Apply filters
    final filteredEntries = _allEntries.where((entry) {
      // Weight filter
      if (filterState.weightRange != null && entry.weight != null) {
        if (entry.weight! < filterState.weightRange.start ||
            entry.weight! > filterState.weightRange.end) {
          return false;
        }
      }

      // Date filter
      if (filterState.dateRange != null) {
        if (entry.date.isBefore(filterState.dateRange!.start) ||
            entry.date.isAfter(filterState.dateRange!.end)) {
          return false;
        }
      }

      // Tags filter
      if (filterState.selectedTags.isNotEmpty) {
        if (entry.tags == null ||
            !filterState.selectedTags.any((tag) => entry.tags!.contains(tag))) {
          return false;
        }
      }

      // Image type filter - Check if entry has at least one image type that's enabled
      bool hasValidImage = false;

      if (filterState.showFrontImages && entry.frontImagePath != null) {
        hasValidImage = true;
      }
      if (filterState.showSideImages && entry.sideImagePath != null) {
        hasValidImage = true;
      }
      if (filterState.showBackImages && entry.backImagePath != null) {
        hasValidImage = true;
      }

      return hasValidImage;
    }).toList();

    // Update state with filtered entries
    state = state.copyWith(
      entries: filteredEntries,
      isLoading: false,
      selectedIndex: filteredEntries.isNotEmpty ? 0 : 0,
    );

    // Update selected view if needed
    if (filteredEntries.isNotEmpty) {
      final entry = filteredEntries[0];
      String? viewToSelect;

      // Select the first available view type for the first entry
      if (filterState.showFrontImages && entry.frontImagePath != null) {
        viewToSelect = 'front';
      } else if (filterState.showSideImages && entry.sideImagePath != null) {
        viewToSelect = 'side';
      } else if (filterState.showBackImages && entry.backImagePath != null) {
        viewToSelect = 'back';
      }

      if (viewToSelect != null && viewToSelect != state.selectedView) {
        state = state.copyWith(selectedView: viewToSelect);
      }
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

/// Data class to hold the filter state for the image timeline
class ImageTimelineFilterState {
  final bool filtersActive;
  final RangeValues weightRange;
  final double minWeight;
  final double maxWeight;
  final DateTimeRange? dateRange;
  final List<String> selectedTags;
  final List<String> allTags;
  final bool showFrontImages;
  final bool showSideImages;
  final bool showBackImages;

  ImageTimelineFilterState({
    this.filtersActive = true,
    required this.weightRange,
    required this.minWeight,
    required this.maxWeight,
    this.dateRange,
    required this.selectedTags,
    required this.allTags,
    this.showFrontImages = true,
    this.showSideImages = true,
    this.showBackImages = true,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  ImageTimelineFilterState copyWith({
    bool? filtersActive,
    RangeValues? weightRange,
    double? minWeight,
    double? maxWeight,
    DateTimeRange? dateRange,
    List<String>? selectedTags,
    List<String>? allTags,
    bool? showFrontImages,
    bool? showSideImages,
    bool? showBackImages,
  }) {
    return ImageTimelineFilterState(
      filtersActive: filtersActive ?? this.filtersActive,
      weightRange: weightRange ?? this.weightRange,
      minWeight: minWeight ?? this.minWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      dateRange: dateRange ?? this.dateRange,
      selectedTags: selectedTags ?? this.selectedTags,
      allTags: allTags ?? this.allTags,
      showFrontImages: showFrontImages ?? this.showFrontImages,
      showSideImages: showSideImages ?? this.showSideImages,
      showBackImages: showBackImages ?? this.showBackImages,
    );
  }
}

/// Notifier for the image timeline filter state
class ImageTimelineFilterNotifier
    extends StateNotifier<ImageTimelineFilterState> {
  ImageTimelineFilterNotifier()
    : super(
        ImageTimelineFilterState(
          weightRange: const RangeValues(40.0, 100.0),
          minWeight: 40.0,
          maxWeight: 100.0,
          selectedTags: [],
          allTags: [],
        ),
      );

  /// Set the weight range
  void setWeightRange(RangeValues range) {
    state = state.copyWith(weightRange: range, filtersActive: true);
  }

  /// Set the date range
  void setDateRange(DateTimeRange range) {
    state = state.copyWith(dateRange: range, filtersActive: true);
  }

  /// Toggle a tag selection
  void toggleTag(String tag) {
    final selectedTags = List<String>.from(state.selectedTags);
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    state = state.copyWith(selectedTags: selectedTags, filtersActive: true);
  }

  /// Set all available tags
  void setAllTags(List<String> tags) {
    state = state.copyWith(allTags: tags);
  }

  /// Set show front images
  void setShowFrontImages(bool show) {
    state = state.copyWith(showFrontImages: show, filtersActive: true);
  }

  /// Set show side images
  void setShowSideImages(bool show) {
    state = state.copyWith(showSideImages: show, filtersActive: true);
  }

  /// Set show back images
  void setShowBackImages(bool show) {
    state = state.copyWith(showBackImages: show, filtersActive: true);
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      filtersActive: false,
      weightRange: RangeValues(state.minWeight, state.maxWeight),
      dateRange: null,
      selectedTags: [],
      showFrontImages: true,
      showSideImages: true,
      showBackImages: true,
    );
  }

  /// Initialize weight range based on entries
  void initializeWeightRange(List<BodyEntry> entries) {
    // Get min and max weights from entries
    double minWeight = 40.0; // Default min
    double maxWeight = 100.0; // Default max

    final weights = entries
        .where((e) => e.weight != null)
        .map((e) => e.weight!)
        .toList();

    if (weights.isNotEmpty) {
      weights.sort();
      minWeight = weights.first;
      maxWeight = weights.last;

      // Apply the formula for min weight: n - (n % 5)
      int minWeightInt = minWeight.toInt();
      minWeight = (minWeightInt - (minWeightInt % 5)).toDouble();
      // Subtract additional 5 if the weight is exactly on a 5 kg interval
      if (minWeight == minWeightInt.toDouble()) {
        minWeight -= 5;
      }

      // Apply the formula for max weight: n + (5 - n % 5) % 5
      int maxWeightInt = maxWeight.toInt();
      maxWeight = (maxWeightInt + (5 - maxWeightInt % 5) % 5).toDouble();
      // Add additional 5 if the weight is exactly on a 5 kg interval
      if (maxWeight == maxWeightInt.toDouble()) {
        maxWeight += 5;
      }
    }

    // Ensure min and max are different to avoid division by zero
    if (minWeight >= maxWeight) {
      maxWeight = minWeight + 5.0;
    }

    state = state.copyWith(
      minWeight: minWeight,
      maxWeight: maxWeight,
      weightRange: RangeValues(minWeight, maxWeight),
    );
  }

  /// Initialize date range based on entries
  void initializeDateRange(List<BodyEntry> entries) {
    if (entries.isNotEmpty) {
      // Find the latest entry date
      final latestDate = entries
          .map((e) => e.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      state = state.copyWith(
        dateRange: DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: latestDate.isAfter(DateTime.now()) ? latestDate : DateTime.now(),
        ),
      );
    }
  }
}

/// Provider for accessing the ImageTimelineFilterState
final imageTimelineFilterProvider =
    StateNotifierProvider<
      ImageTimelineFilterNotifier,
      ImageTimelineFilterState
    >((ref) => ImageTimelineFilterNotifier());
