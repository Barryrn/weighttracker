import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import '../model/database_helper.dart';
import 'dart:developer' as developer;

/// Enum representing different time periods for data aggregation
enum TimePeriodLineChart { day, week, month, year }

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

  String get periodLabel {
    if (periodStart.difference(periodEnd).inDays == 0) {
      return '${_getWeekdayName(periodStart.weekday)}, ${_getMonthName(periodStart.month)} ${periodStart.day}, ${periodStart.year}';
    }

    if (periodStart.difference(periodEnd).inDays <= 7) {
      if (periodStart.year == periodEnd.year) {
        return '${_getMonthName(periodStart.month)} ${periodStart.day} - ${_getMonthName(periodEnd.month)} ${periodEnd.day}, ${periodStart.year}';
      } else {
        return '${_getMonthName(periodStart.month)} ${periodStart.day}, ${periodStart.year} - ${_getMonthName(periodEnd.month)} ${periodEnd.day}, ${periodEnd.year}';
      }
    }

    if (periodStart.month == periodEnd.month &&
        periodStart.year == periodEnd.year) {
      return '${_getMonthName(periodStart.month, full: true)} ${periodStart.year}';
    }

    if (periodStart.year == periodEnd.year) {
      return '${periodStart.year}';
    }

    return '${_getMonthName(periodStart.month)} ${periodStart.day}, ${periodStart.year} - ${_getMonthName(periodEnd.month)} ${periodEnd.day}, ${periodEnd.year}';
  }

  String _getMonthName(int month, {bool full = false}) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    const fullMonthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return full ? fullMonthNames[month - 1] : monthNames[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdayNames[weekday - 1];
  }

  @override
  String toString() {
    return 'AggregatedBodyData(period: $periodLabel, weight: ${avgWeight?.toStringAsFixed(1)}, bmi: ${avgBmi?.toStringAsFixed(1)}, fat: ${avgFatPercentage?.toStringAsFixed(1)}, entries: $entryCount)';
  }
}

/// A notifier that manages time-based aggregation of body entry data
class TimeAggregationNotifier extends StateNotifier<List<AggregatedBodyData>> {
  TimeAggregationNotifier() : super([]);

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Fetches and aggregates body entry data based on the specified time period
  Future<void> aggregateData(TimePeriodLineChart period) async {
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
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      // Find the earliest and latest dates in the entries
      final latestDate = entries.first.date;
      final earliestDate = entries.last.date;

      // For day view, only include days with actual entries
      if (period == TimePeriodLineChart.day) {
        final List<AggregatedBodyData> filledData = [];

        // Create a map of existing entries by date string
        final Map<String, List<BodyEntry>> entriesByDate = {};
        for (var entry in entries) {
          final dateKey =
              '${entry.date.year}-${entry.date.month}-${entry.date.day}';
          if (!entriesByDate.containsKey(dateKey)) {
            entriesByDate[dateKey] = [];
          }
          entriesByDate[dateKey]!.add(entry);
        }

        // Only process days that have entries
        entriesByDate.forEach((dateKey, entriesForDay) {
          // Get the date from the first entry in this group
          final currentDate = DateTime(
            entriesForDay.first.date.year,
            entriesForDay.first.date.month,
            entriesForDay.first.date.day,
          );
          
          // Calculate averages
          double? avgWeight;
          double? avgBmi;
          double? avgFatPercentage;

          // Weight average
          final weightsWithValues = entriesForDay
              .where((e) => e.weight != null)
              .map((e) => e.weight!)
              .toList();
          if (weightsWithValues.isNotEmpty) {
            avgWeight =
                weightsWithValues.reduce((a, b) => a + b) /
                weightsWithValues.length;
          }

          // BMI average
          final bmisWithValues = entriesForDay
              .where((e) => e.bmi != null)
              .map((e) => e.bmi!)
              .toList();
          if (bmisWithValues.isNotEmpty) {
            avgBmi =
                bmisWithValues.reduce((a, b) => a + b) /
                bmisWithValues.length;
          }

          // Fat percentage average
          final fatPercentagesWithValues = entriesForDay
              .where((e) => e.fatPercentage != null)
              .map((e) => e.fatPercentage!)
              .toList();
          if (fatPercentagesWithValues.isNotEmpty) {
            avgFatPercentage =
                fatPercentagesWithValues.reduce((a, b) => a + b) /
                fatPercentagesWithValues.length;
          }

          filledData.add(
            AggregatedBodyData(
              periodStart: currentDate,
              periodEnd: currentDate,
              avgWeight: avgWeight,
              avgBmi: avgBmi,
              avgFatPercentage: avgFatPercentage,
              entryCount: entriesForDay.length,
            ),
          );
        });

        // Sort by date (newest first)
        filledData.sort((a, b) => b.periodStart.compareTo(a.periodStart));

        // Update state
        state = filledData;
      } else {
        // For other time periods, use the existing grouping logic
        // Group entries based on the selected time period
        final Map<String, List<BodyEntry>> groupedEntries = {};

        for (var entry in entries) {
          String key;

          switch (period) {
            case TimePeriodLineChart.day:
              // This case is handled above
              key = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
              break;
            case TimePeriodLineChart.week:
              // Group by week (starting from today and going back in 7-day chunks)
              final daysFromToday = today.difference(entry.date).inDays;
              final weekNumber = daysFromToday ~/ 7;
              key = 'week-$weekNumber';
              break;
            case TimePeriodLineChart.month:
              // Group by month
              final daysFromToday = today.difference(entry.date).inDays;
              final monthNumber = daysFromToday ~/ 30;
              key = 'month-$monthNumber';
              break;
            case TimePeriodLineChart.year:
              final daysFromToday = today.difference(entry.date).inDays;
              final yearNumber = daysFromToday ~/ 365;
              key = 'year-$yearNumber';
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
          DateTime minDate = entriesInGroup
              .map((e) => e.date)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          DateTime maxDate = entriesInGroup
              .map((e) => e.date)
              .reduce((a, b) => a.isAfter(b) ? a : b);

          // Calculate averages
          double? avgWeight;
          double? avgBmi;
          double? avgFatPercentage;

          // Weight average
          final weightsWithValues = entriesInGroup
              .where((e) => e.weight != null)
              .map((e) => e.weight!)
              .toList();
          if (weightsWithValues.isNotEmpty) {
            avgWeight =
                weightsWithValues.reduce((a, b) => a + b) /
                weightsWithValues.length;
          }

          // BMI average
          final bmisWithValues = entriesInGroup
              .where((e) => e.bmi != null)
              .map((e) => e.bmi!)
              .toList();
          if (bmisWithValues.isNotEmpty) {
            avgBmi =
                bmisWithValues.reduce((a, b) => a + b) / bmisWithValues.length;
          }

          // Fat percentage average
          final fatPercentagesWithValues = entriesInGroup
              .where((e) => e.fatPercentage != null)
              .map((e) => e.fatPercentage!)
              .toList();
          if (fatPercentagesWithValues.isNotEmpty) {
            avgFatPercentage =
                fatPercentagesWithValues.reduce((a, b) => a + b) /
                fatPercentagesWithValues.length;
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
      }

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
final timeAggregationProvider =
    StateNotifierProvider<TimeAggregationNotifier, List<AggregatedBodyData>>(
      (ref) => TimeAggregationNotifier(),
    );

/// Provider for the currently selected time period
final selectedTimePeriodLineChartProvider = StateProvider<TimePeriodLineChart>(
  (ref) => TimePeriodLineChart.week, // Default to week view
);
