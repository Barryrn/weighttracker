import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'body_entry_model.dart';

/// Model class for handling image comparison logic
class ImageComparisonModel {
  /// Finds the image with the closest weight to the reference image
  /// @param referenceEntry The reference body entry
  /// @param allEntries List of all body entries
  /// @return The body entry with the closest weight to the reference entry
  static BodyEntry? findClosestWeightImage(
    BodyEntry referenceEntry,
    List<BodyEntry> allEntries,
  ) {
    if (referenceEntry.weight == null || allEntries.isEmpty) {
      return null;
    }

    // Filter entries that have at least one image and a weight value
    final entriesWithImages = allEntries
        .where(
          (entry) =>
              entry.date !=
                  referenceEntry.date && // Exclude the reference entry
              entry.weight != null &&
              (entry.frontImagePath != null ||
                  entry.sideImagePath != null ||
                  entry.backImagePath != null),
        )
        .toList();

    if (entriesWithImages.isEmpty) {
      return null;
    }

    // Sort by weight difference (absolute value)
    entriesWithImages.sort((a, b) {
      final aDiff = (a.weight! - referenceEntry.weight!).abs();
      final bDiff = (b.weight! - referenceEntry.weight!).abs();
      return aDiff.compareTo(bDiff);
    });

    // Return the entry with the closest weight
    return entriesWithImages.first;
  }

  /// Filters body entries based on search criteria
  /// @param entries List of all body entries
  /// @param weightRange Range of weights to filter by (min, max)
  /// @param dateRange Range of dates to filter by (start, end)
  /// @param tags List of tags to filter by
  /// @param showFrontImages Whether to include entries with front images
  /// @param showSideImages Whether to include entries with side images
  /// @param showBackImages Whether to include entries with back images
  /// @return Filtered list of body entries
  static List<BodyEntry> filterEntries({
    required List<BodyEntry> entries,
    RangeValues? weightRange,
    DateTimeRange? dateRange,
    List<String>? tags,
    bool showFrontImages = true,
    bool showSideImages = true,
    bool showBackImages = true,
  }) {
    // Start with entries that have at least one image of the selected types
    var filteredEntries = entries
        .where(
          (entry) =>
              (showFrontImages && entry.frontImagePath != null) ||
              (showSideImages && entry.sideImagePath != null) ||
              (showBackImages && entry.backImagePath != null),
        )
        .toList();

    // Filter by weight range
    if (weightRange != null) {
      filteredEntries = filteredEntries
          .where(
            (entry) =>
                entry.weight != null &&
                entry.weight! >= weightRange.start &&
                entry.weight! <= weightRange.end,
          )
          .toList();
    }

    // Filter by date range
    if (dateRange != null) {
      filteredEntries = filteredEntries
          .where(
            (entry) =>
                entry.date.isAfter(
                  dateRange.start.subtract(const Duration(days: 1)),
                ) &&
                entry.date.isBefore(dateRange.end.add(const Duration(days: 1))),
          )
          .toList();
    }

    // Filter by tags - Only apply tag filtering when tags are selected
    if (tags != null && tags.isNotEmpty) {
      filteredEntries = filteredEntries
          .where(
            (entry) =>
                // Only include entries that have at least one of the selected tags
                entry.tags != null &&
                entry.tags!.any((entryTag) => tags.contains(entryTag)),
          )
          .toList();
    }

    return filteredEntries;
  }
}
