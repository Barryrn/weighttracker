import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/model/body_entry_model.dart';
import 'package:weigthtracker/model/image_comparison_model.dart';
import 'package:weigthtracker/repository/weight_repository.dart';

/// State for the image comparison feature
class ImageComparisonState {
  final List<BodyEntry> allEntries;
  final BodyEntry? latestEntry;
  final BodyEntry? comparisonEntry;
  final bool isLoading;
  final String? errorMessage;
  
  // Filter state
  final RangeValues? weightRange;
  final DateTimeRange? dateRange;
  final List<String>? selectedTags;
  final List<BodyEntry> filteredEntries;
  
  ImageComparisonState({
    required this.allEntries,
    this.latestEntry,
    this.comparisonEntry,
    this.isLoading = false,
    this.errorMessage,
    this.weightRange,
    this.dateRange,
    this.selectedTags,
    List<BodyEntry>? filteredEntries,
  }) : filteredEntries = filteredEntries ?? allEntries;
  
  ImageComparisonState copyWith({
    List<BodyEntry>? allEntries,
    BodyEntry? latestEntry,
    BodyEntry? comparisonEntry,
    bool? isLoading,
    String? errorMessage,
    RangeValues? weightRange,
    DateTimeRange? dateRange,
    List<String>? selectedTags,
    List<BodyEntry>? filteredEntries,
  }) {
    return ImageComparisonState(
      allEntries: allEntries ?? this.allEntries,
      latestEntry: latestEntry ?? this.latestEntry,
      comparisonEntry: comparisonEntry ?? this.comparisonEntry,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      weightRange: weightRange ?? this.weightRange,
      dateRange: dateRange ?? this.dateRange,
      selectedTags: selectedTags ?? this.selectedTags,
      filteredEntries: filteredEntries ?? this.filteredEntries,
    );
  }
}

/// Notifier for managing image comparison state
class ImageComparisonNotifier extends StateNotifier<ImageComparisonState> {
  final WeightRepository _repository;
  
  ImageComparisonNotifier(this._repository) : super(ImageComparisonState(allEntries: <BodyEntry>[]));
  
  /// Loads all body entries and sets up the initial comparison
  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      // Get all body entries from the database helper
      final List<BodyEntry> entries = await _repository.getAllBodyEntries();
      
      // Sort entries by date (newest first)
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      // Find the latest entry with images
      final BodyEntry? latestWithImages = entries.isNotEmpty ? entries.firstWhere(
        (entry) => entry.frontImagePath != null || entry.sideImagePath != null || entry.backImagePath != null,
        orElse: () => entries.first, // Fallback to first entry if none have images
      ) : null;
      
      // Find the closest weight comparison
      final BodyEntry? comparison = latestWithImages != null ? 
        ImageComparisonModel.findClosestWeightImage(latestWithImages, entries) : null;
      
      state = state.copyWith(
        allEntries: entries,
        latestEntry: latestWithImages,
        comparisonEntry: comparison,
        isLoading: false,
        filteredEntries: entries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load entries: ${e.toString()}',
      );
    }
  }
  
  /// Applies filters to the entries
  void applyFilters({
    RangeValues? weightRange,
    DateTimeRange? dateRange,
    List<String>? tags,
  }) {
    final List<BodyEntry> filteredEntries = ImageComparisonModel.filterEntries(
      entries: state.allEntries,
      weightRange: weightRange,
      dateRange: dateRange,
      tags: tags,
    );
    
    state = state.copyWith(
      weightRange: weightRange,
      dateRange: dateRange,
      selectedTags: tags,
      filteredEntries: filteredEntries,
    );
  }
  
  /// Clears all filters
  void clearFilters() {
    state = state.copyWith(
      weightRange: null,
      dateRange: null,
      selectedTags: null,
      filteredEntries: state.allEntries,
    );
  }
  
  /// Sets a specific entry as the comparison entry
  void setComparisonEntry(BodyEntry entry) {
    state = state.copyWith(comparisonEntry: entry);
  }
}

/// Provider for the image comparison feature
final imageComparisonProvider = StateNotifierProvider<ImageComparisonNotifier, ImageComparisonState>((ref) {
  // Create a new repository instance
  final repository = WeightRepository();
  return ImageComparisonNotifier(repository);
});