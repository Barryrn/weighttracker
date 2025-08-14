import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/database_helper.dart';
import '../provider/database_change_provider.dart';

/// Data class to hold the state for the image gallery
class ImageGalleryState {
  final List<BodyEntry> entries;
  final bool isLoading;
  final String? errorMessage;

  ImageGalleryState({
    required this.entries,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  ImageGalleryState copyWith({
    List<BodyEntry>? entries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ImageGalleryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Pattern matching method similar to AsyncValue.when()
  /// Handles different states: loading, error, and data
  T when<T>({
    required T Function() loading,
    required T Function(Object error, StackTrace? stackTrace) error,
    required T Function(List<BodyEntry> entries) data,
  }) {
    if (isLoading) {
      return loading();
    } else if (errorMessage != null) {
      return error(errorMessage!, null);
    } else {
      return data(entries);
    }
  }
}

/// ViewModel for the image gallery feature
/// This follows the MVVM pattern by separating business logic from the UI
class ImageGalleryViewModel extends StateNotifier<ImageGalleryState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Ref ref;
  List<BodyEntry> _allEntries = []; // Store all entries for filtering

  ImageGalleryViewModel(this.ref)
      : super(
          ImageGalleryState(
            entries: [],
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
    ref.listen(imageGalleryFilterProvider, (previous, next) {
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

      // Sort by date (newest first for gallery)
      entriesWithImages.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // newest first

      // Store all entries for filtering
      _allEntries = entriesWithImages;

      // Initialize weight range based on actual data
      ref.read(imageGalleryFilterProvider.notifier).initializeWeightRange(_allEntries);

      // Load all available tags for filtering
      _loadAllTags();

      // Initialize date range based on latest entry
      ref.read(imageGalleryFilterProvider.notifier).initializeDateRange(_allEntries);

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
      // Only include tags from entries that have at least one image
      if (entry.tags != null &&
          (entry.frontImagePath != null ||
              entry.sideImagePath != null ||
              entry.backImagePath != null)) {
        tags.addAll(entry.tags!);
      }
    }
    ref.read(imageGalleryFilterProvider.notifier).setAllTags(tags.toList());
  }

  /// Apply filters to entries
  void _applyFilters() {
    final filterState = ref.read(imageGalleryFilterProvider);

    // If filters aren't active, use all entries
    if (!filterState.filtersActive) {
      state = state.copyWith(
        entries: _allEntries,
        isLoading: false,
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
    );
  }

  /// Get all available images from an entry based on filter settings
  List<Map<String, dynamic>> getAvailableImages(BodyEntry entry) {
    final filterState = ref.read(imageGalleryFilterProvider);
    List<Map<String, dynamic>> images = [];

    if (filterState.showFrontImages && entry.frontImagePath != null) {
      images.add({
        'path': entry.frontImagePath!,
        'type': 'Front',
        'entry': entry,
      });
    }
    if (filterState.showSideImages && entry.sideImagePath != null) {
      images.add({
        'path': entry.sideImagePath!,
        'type': 'Side',
        'entry': entry,
      });
    }
    if (filterState.showBackImages && entry.backImagePath != null) {
      images.add({
        'path': entry.backImagePath!,
        'type': 'Back',
        'entry': entry,
      });
    }

    return images;
  }

  /// Get all images from all filtered entries
  List<Map<String, dynamic>> getAllImages() {
    final allImages = <Map<String, dynamic>>[];
    for (final entry in state.entries) {
      allImages.addAll(getAvailableImages(entry));
    }
    return allImages;
  }

  /// Get filtered entries based on the provided filter state
  /// This method applies filters to the given entries and returns the filtered result
  List<BodyEntry> getFilteredEntries(List<BodyEntry> entries, ImageGalleryFilterState filterState) {
    // If filters aren't active, return all entries
    if (!filterState.filtersActive) {
      return entries;
    }

    // Apply filters
    return entries.where((entry) {
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
  }
}

/// Provider for accessing the ImageGalleryViewModel
final imageGalleryProvider =
    StateNotifierProvider<ImageGalleryViewModel, ImageGalleryState>(
  (ref) => ImageGalleryViewModel(ref),
);

/// Data class to hold the filter state for the image gallery
class ImageGalleryFilterState {
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

  ImageGalleryFilterState({
    this.filtersActive = false, // Start with filters inactive for gallery
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
  ImageGalleryFilterState copyWith({
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
    return ImageGalleryFilterState(
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

/// Notifier for the image gallery filter state
class ImageGalleryFilterNotifier
    extends StateNotifier<ImageGalleryFilterState> {
  ImageGalleryFilterNotifier()
      : super(
          ImageGalleryFilterState(
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

/// Provider for accessing the ImageGalleryViewModel
final imageGalleryViewModelProvider =
    StateNotifierProvider<ImageGalleryViewModel, ImageGalleryState>(
        (ref) => ImageGalleryViewModel(ref));

/// Provider for accessing the ImageGalleryFilterState
final imageGalleryFilterProvider =
    StateNotifierProvider<ImageGalleryFilterNotifier, ImageGalleryFilterState>(
        (ref) => ImageGalleryFilterNotifier());