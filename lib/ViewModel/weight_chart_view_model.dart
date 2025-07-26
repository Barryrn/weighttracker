import 'package:flutter/foundation.dart';
import '../model/time_period.dart';
import '../model/weight_entry_model.dart';
import '../repository/weight_repository.dart';

/// ViewModel for the weight chart screen
class WeightChartViewModel extends ChangeNotifier {
  final WeightRepository _repository;

  /// Current time period selected by the user
  TimePeriod _currentTimePeriod = TimePeriod.week;
  TimePeriod get currentTimePeriod => _currentTimePeriod;

  /// Chart data (list of weight entries)
  List<WeightEntry> _chartData = [];
  List<WeightEntry> get chartData => _chartData;

  /// Average weight of currently visible data
  double? _averageWeight;
  double? get averageWeight => _averageWeight;

  /// Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Constructor that takes a WeightRepository instance
  WeightChartViewModel({required WeightRepository repository})
      : _repository = repository {
    // Load initial data
    loadChartData();
  }

  /// Load chart data based on the current time period
  Future<void> loadChartData() async {
    _setLoading(true);
    _clearError();

    try {
      // Get today's date at midnight
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);

      // Calculate start date based on current time period
      late DateTime startDate;
      switch (_currentTimePeriod) {
        case TimePeriod.day:
          // Just today
          startDate = todayMidnight;
          break;
        case TimePeriod.week:
          // Last 7 days (including today)
          startDate = todayMidnight.subtract(const Duration(days: 6));
          break;
        case TimePeriod.month:
          // Last 30 days (including today)
          startDate = todayMidnight.subtract(const Duration(days: 29));
          break;
        case TimePeriod.year:
          // Last 365 days (including today)
          startDate = todayMidnight.subtract(const Duration(days: 364));
          break;
      }

      // Get weight entries in the calculated date range
      final entries = await _repository.getWeightEntriesInRange(
        startDate,
        todayMidnight,
      );

      // Create a complete date range (every single day)
      final List<WeightEntry> completeData = [];

      // For each day in the range, use actual weight or null
      for (int i = 0; i <= todayMidnight.difference(startDate).inDays; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final existingEntry = entries.firstWhere(
          (entry) =>
              entry.date.year == currentDate.year &&
              entry.date.month == currentDate.month &&
              entry.date.day == currentDate.day,
          orElse: () => WeightEntry(date: currentDate, weight: null),
        );

        completeData.add(existingEntry);
      }

      // For yearly overview, group by month and calculate averages
      if (_currentTimePeriod == TimePeriod.year) {
        final Map<String, List<WeightEntry>> monthlyData = {};

        // Group by month
        for (var entry in completeData) {
          final key = '${entry.date.year}-${entry.date.month}';
          if (!monthlyData.containsKey(key)) {
            monthlyData[key] = [];
          }
          monthlyData[key]!.add(entry);
        }

        // Calculate monthly averages
        final List<WeightEntry> monthlyAverages = [];
        monthlyData.forEach((key, entries) {
          final validEntries = entries.where((e) => e.weight != null).toList();
          if (validEntries.isNotEmpty) {
            final totalWeight = validEntries.fold<double>(
                0, (sum, entry) => sum + (entry.weight ?? 0));
            final avgWeight = totalWeight / validEntries.length;

            // Use the middle day of the month as the representative date
            final midMonthDate = entries[entries.length ~/ 2].date;
            monthlyAverages.add(WeightEntry(
              date: midMonthDate,
              weight: avgWeight,
            ));
          } else {
            // If no valid entries, add a null weight entry for this month
            final midMonthDate = entries[entries.length ~/ 2].date;
            monthlyAverages.add(WeightEntry(
              date: midMonthDate,
              weight: null,
            ));
          }
        });

        // Sort by date
        monthlyAverages.sort((a, b) => a.date.compareTo(b.date));
        _chartData = monthlyAverages;
      } else {
        _chartData = completeData;
      }

      // Calculate average weight for all visible data
      calculateVisibleAverage(_chartData);

      notifyListeners();
    } catch (e) {
      _setError('Error loading chart data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Change the current time period and reload data
  Future<void> changeTimePeriod(TimePeriod newPeriod) async {
    if (_currentTimePeriod != newPeriod) {
      _currentTimePeriod = newPeriod;
      await loadChartData();
    }
  }

  /// Calculate the average weight for the visible chart range
  void calculateVisibleAverage(List<WeightEntry> visibleEntries) {
    final entriesWithWeight = visibleEntries.where((e) => e.weight != null);
    if (entriesWithWeight.isEmpty) {
      _averageWeight = null;
    } else {
      final totalWeight = entriesWithWeight.fold<double>(
          0, (sum, entry) => sum + (entry.weight ?? 0));
      _averageWeight = totalWeight / entriesWithWeight.length;
    }
    notifyListeners();
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message and notify listeners
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }
}