import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum representing different time aggregation periods for data display
enum TimeAggregation {
  day,
  week,
  month,
  year,
  all
}

/// A notifier that manages the current time aggregation selection
///
/// This follows the MVVM pattern by acting as a ViewModel that holds UI state
/// related to time period selection for data visualization.
class TimeAggregationNotifier extends StateNotifier<TimeAggregation> {
  /// Creates a new TimeAggregationNotifier with a default state of week
  TimeAggregationNotifier() : super(TimeAggregation.week);

  /// Updates the time aggregation period
  /// @param aggregation The new TimeAggregation value to set
  void setTimeAggregation(TimeAggregation aggregation) {
    state = aggregation;
  }
}

/// A provider for accessing and modifying the time aggregation period.
///
/// This provider makes the TimeAggregationNotifier available to widgets
/// that need to read or update the time aggregation period.
final timeAggregationProvider = StateNotifierProvider<TimeAggregationNotifier, TimeAggregation>(
  (ref) => TimeAggregationNotifier(),
);