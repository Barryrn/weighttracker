import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/time_period.dart';
import '../model/weight_entry_model.dart';
import '../repository/weight_repository.dart';
import '../viewmodel/weight_chart_view_model.dart';

/// Provider for the WeightChartViewModel
final weightChartViewModelProvider =
    ChangeNotifierProvider<WeightChartViewModel>((ref) {
      return WeightChartViewModel(repository: WeightRepository());
    });

/// Provider for the current time period
final selectedTimePeriodProvider = StateProvider<TimePeriod>((ref) {
  return TimePeriod.week; // Default to week view
});

/// Provider for the average weight of visible data
final averageWeightProvider = StateProvider<double?>((ref) {
  return null;
});

/// Provider for the chart data
final chartDataProvider = StateProvider<List<WeightEntry>>((ref) {
  return [];
});
