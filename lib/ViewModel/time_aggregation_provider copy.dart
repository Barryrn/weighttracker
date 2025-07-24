import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/database_helper.dart';
import 'dart:developer' as developer;

/// Enum representing different time periods for data aggregation
enum TimePeriod {
  day,
  week,
  month,
  year,
}

/// Class representing aggregated body data for a specific time period
class AggregatedBodyData {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double? avgWeight;
  final double? avgBmi;
  final double? avgFatPercentage;
  final int entryCount;

  AggregatedBodyData({
    required this.periodStart,
    required this.periodEnd,
    this.avgWeight,
    this.avgBmi,
    this.avgFatPercentage,
    required this.entryCount,
  });

  /// Returns a formatted string representation of the time period
  String get periodLabel {
    // For day: "Mon, Jan 1"
    if (periodStart.difference(periodEnd).inDays == 0) {
      return '${_getWeekdayName(periodStart.weekday)}, ${_getMonthName(periodStart.month)} ${periodStart.day}';
    }
    
    // For week: "Jan 1 - Jan 7"
    if (periodStart.difference(periodEnd).inDays <= 7) {
      return '${_getMonthName(periodStart.month)} ${periodStart.day} - ${_getMonthName(periodEnd.month)} ${periodEnd.day}';
    }
    
    // For month: "January 2023"
    if (periodStart.month == periodEnd.month && periodStart.year == periodEnd.year) {
      return '${_getMonthName(periodStart.month, full: true)} ${periodStart.year}';
    }
    
    // For year: "2023"
    if (periodStart.year == periodEnd.year) {
      return '${periodStart.year}';
    }
    
    // Default
    return '${_getMonthName(periodStart.month)} ${periodStart.day} - ${_getMonthName(periodEnd.month)} ${periodEnd.day}';
  }
  
  /// Helper method to get month name from month number
  String _getMonthName(int month, {bool full = false}) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    const fullMonthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return full ? fullMonthNames[month - 1] : monthNames[month - 1];
  }
  
  /// Helper method to get weekday name from weekday number
  String _getWeekdayName(int weekday) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdayNames[weekday - 1];
  }
}

/// A notifier that manages time-based aggregation of body entry data
class TimeAggregationNotifier extends StateNotifier<List<AggregatedBodyData>> {
  TimeAggregationNotifier() : super([]);
  
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  /// Fetches and aggregates body entry data based on the specified time period
  Future<void> aggregateData(TimePeriod period) async {
    try {
      // Get all entries
      final entries = await _dbHelper.queryAllBodyEntries();
      
      if (entries.isEmpty) {
        state = [];
        return;
      }
      
      // Sort entries by date (newest first)
      entries.sort((a, b) => b.date.compareTo(a.date));
      
      // Get today's date at midnight
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      
      // Group entries based on the selected time period
      final Map<String, List<BodyEntry>> groupedEntries = {};
      
      for (var entry in entries) {
        String key;
        
        switch (period) {
          case TimePeriod.day:
            // Group by individual days
            key = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
            break;
          case TimePeriod.week:
            // Group by week (starting from today and going back in 7-day chunks)
            final daysFromToday = today.difference(entry.date).inDays;
            final weekNumber = daysFromToday ~/ 7;
            key = 'week-$weekNumber';
            break;
          case TimePeriod.month:
            // Group by month
            key = '${entry.date.year}-${entry.date.month}';
            break;
          case TimePeriod.year:
            // Group by year
            key = '${entry.date.year}';
            break;
        }
        
        if (!groupedEntries.containsKey(key)) {
          groupedEntries[key] = [];
        }
        
        groupedEntries[key]!.add(entry);
      }
      
      // Calculate aggregated data for each group
      final List<AggregatedBodyData> aggregatedData = [];
      
      groupedEntries.forEach((key, entriesInGroup) {
        // Find min and max dates in the group
        DateTime minDate = entriesInGroup.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
        DateTime maxDate = entriesInGroup.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
        
        // Calculate averages
        double? avgWeight;
        double? avgBmi;
        double? avgFatPercentage;
        
        // Weight average
        final weightsWithValues = entriesInGroup.where((e) => e.weight != null).map((e) => e.weight!).toList();
        if (weightsWithValues.isNotEmpty) {
          avgWeight = weightsWithValues.reduce((a, b) => a + b) / weightsWithValues.length;
        }
        
        // BMI average
        final bmisWithValues = entriesInGroup.where((e) => e.bmi != null).map((e) => e.bmi!).toList();
        if (bmisWithValues.isNotEmpty) {
          avgBmi = bmisWithValues.reduce((a, b) => a + b) / bmisWithValues.length;
        }
        
        // Fat percentage average
        final fatPercentagesWithValues = entriesInGroup.where((e) => e.fatPercentage != null).map((e) => e.fatPercentage!).toList();
        if (fatPercentagesWithValues.isNotEmpty) {
          avgFatPercentage = fatPercentagesWithValues.reduce((a, b) => a + b) / fatPercentagesWithValues.length;
        }
        
        // Create aggregated data object
        final aggregated = AggregatedBodyData(
          periodStart: minDate,
          periodEnd: maxDate,
          avgWeight: avgWeight,
          avgBmi: avgBmi,
          avgFatPercentage: avgFatPercentage,
          entryCount: entriesInGroup.length,
        );
        
        aggregatedData.add(aggregated);
      });
      
      // Sort by date (newest first)
      aggregatedData.sort((a, b) => b.periodStart.compareTo(a.periodStart));
      
      // Update state
      state = aggregatedData;
      
      _logState();
    } catch (e) {
      developer.log('Error aggregating data: $e');
      state = [];
    }
  }
  
  /// Logs the current state for debugging
  void _logState() {
    developer.log('===== Time Aggregation Provider State =====');
    developer.log('Number of periods: ${state.length}');
    for (var i = 0; i < state.length; i++) {
      final data = state[i];
      developer.log('Period $i: ${data.periodLabel}');
      developer.log('  Avg Weight: ${data.avgWeight}');
      developer.log('  Avg BMI: ${data.avgBmi}');
      developer.log('  Avg Fat %: ${data.avgFatPercentage}');
      developer.log('  Entry Count: ${data.entryCount}');
    }
    developer.log('=========================================');
  }
}

/// Provider for time-based aggregation of body entry data
final timeAggregationProvider = StateNotifierProvider<TimeAggregationNotifier, List<AggregatedBodyData>>(
  (ref) => TimeAggregationNotifier(),
);

/// Provider for the currently selected time period
final selectedTimePeriodProvider = StateProvider<TimePeriod>(
  (ref) => TimePeriod.week, // Default to week view
);