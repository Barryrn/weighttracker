/// Enum for image comparison mode
enum ComparisonMode {
  /// Closest weight with shortest time difference (default)
  closestWeightShortestTime,

  /// Closest weight with longest time difference
  closestWeightLongestTime,
}

/// Extension to provide user-friendly names for comparison modes
extension ComparisonModeExtension on ComparisonMode {
  /// Returns the key for the comparison mode for localization
  String get localizationKey {
    switch (this) {
      case ComparisonMode.closestWeightShortestTime:
        return 'shortestTimeDifference';
      case ComparisonMode.closestWeightLongestTime:
        return 'longestTimeDifference';
    }
  }

  /// Returns the description key for the comparison mode for localization
  String get descriptionKey {
    switch (this) {
      case ComparisonMode.closestWeightShortestTime:
        return 'shortestTimeDifferenceDescription';
      case ComparisonMode.closestWeightLongestTime:
        return 'longestTimeDifferenceDescription';
    }
  }
}
