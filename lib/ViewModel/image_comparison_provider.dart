import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/database_helper.dart';
import '../model/image_comparison_model.dart';
import '../repository/weight_repository.dart';

/// Provider for managing the state of image comparison
class ImageComparisonNotifier extends StateNotifier<AsyncValue<List<BodyEntry>>> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final WeightRepository _repository = WeightRepository();
  BodyEntry? _latestEntry;
  BodyEntry? _comparisonEntry;
  RangeValues? _weightRange;
  DateTimeRange? _dateRange;
  List<String>? _selectedTags;
  bool _showFrontImages = true;
  bool _showSideImages = true;
  bool _showBackImages = true;

  ImageComparisonNotifier() : super(const AsyncValue.loading()) {
    loadEntries();
  }

  /// Get the latest entry with images
  BodyEntry? get latestEntry => _latestEntry;

  /// Get the comparison entry (closest weight)
  BodyEntry? get comparisonEntry => _comparisonEntry;

  /// Get the current weight range filter
  RangeValues? get weightRange => _weightRange;

  /// Get the current date range filter
  DateTimeRange? get dateRange => _dateRange;

  /// Get the current selected tags filter
  List<String>? get selectedTags => _selectedTags;

  /// Load all entries from the database and set up the comparison
  Future<void> loadEntries() async {
    try {
      state = const AsyncValue.loading();
      final entries = await _dbHelper.queryAllBodyEntries(); // Using _dbHelper directly
      
      // Find the latest entry with images
      _latestEntry = _findLatestEntryWithImages(entries);
      
      // Find the comparison entry (closest weight)
      if (_latestEntry != null) {
        _comparisonEntry = ImageComparisonModel.findClosestWeightImage(_latestEntry!, entries);
      }
      
      state = AsyncValue.data(entries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Find the latest entry that has at least one image
  BodyEntry? _findLatestEntryWithImages(List<BodyEntry> entries) {
    // Sort entries by date (newest first)
    final sortedEntries = List<BodyEntry>.from(entries);
    sortedEntries.sort((a, b) => b.date.compareTo(a.date));
    
    // Find the first entry with at least one image
    return sortedEntries.firstWhere(
      (entry) => 
        entry.frontImagePath != null || 
        entry.sideImagePath != null || 
        entry.backImagePath != null,
      orElse: () => sortedEntries.first, // Fallback to the latest entry even if it has no images
    );
  }

  /// Get the current image type filters
  bool get showFrontImages => _showFrontImages;
  bool get showSideImages => _showSideImages;
  bool get showBackImages => _showBackImages;

  /// Apply filters to the entries
  void applyFilters({
    RangeValues? weightRange,
    DateTimeRange? dateRange,
    List<String>? tags,
    bool? showFrontImages,
    bool? showSideImages,
    bool? showBackImages,
  }) {
    _weightRange = weightRange;
    _dateRange = dateRange;
    _selectedTags = tags;
    if (showFrontImages != null) _showFrontImages = showFrontImages;
    if (showSideImages != null) _showSideImages = showSideImages;
    if (showBackImages != null) _showBackImages = showBackImages;
    
    // Reload entries with filters
    loadFilteredEntries();
  }

  /// Clear all filters
  void clearFilters() {
    _weightRange = null;
    _dateRange = null;
    _selectedTags = null;
    _showFrontImages = true;
    _showSideImages = true;
    _showBackImages = true;
    
    // Reload entries without filters
    loadFilteredEntries();
  }

  /// Load filtered entries based on current filter settings
  Future<void> loadFilteredEntries() async {
    try {
      state = const AsyncValue.loading();
      final allEntries = await _dbHelper.queryAllBodyEntries();
      
      final filteredEntries = ImageComparisonModel.filterEntries(
        entries: allEntries,
        weightRange: _weightRange,
        dateRange: _dateRange,
        tags: _selectedTags,
        showFrontImages: _showFrontImages,
        showSideImages: _showSideImages,
        showBackImages: _showBackImages,
      );
      
      state = AsyncValue.data(filteredEntries);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Set a specific entry as the comparison entry
  void setComparisonEntry(BodyEntry entry) {
    _comparisonEntry = entry;
  }
  
  /// Set a specific entry as the latest entry
  void setLatestEntry(BodyEntry entry) {
    _latestEntry = entry;
  }
}

/// Provider for image comparison
final imageComparisonProvider = StateNotifierProvider<ImageComparisonNotifier, AsyncValue<List<BodyEntry>>>(
  (ref) => ImageComparisonNotifier(),
);