import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../model/weight_entry_model.dart';
import '../model/time_period.dart';
import '../viewmodel/weight_chart_view_model.dart';
import '../repository/weight_repository.dart';
import '../provider/weight_chart_provider.dart';
import '../viewmodel/unit_conversion_provider.dart';

/// Widget for displaying weight chart with different time period views
class WeightChartView extends ConsumerStatefulWidget {
  const WeightChartView({Key? key}) : super(key: key);

  @override
  ConsumerState<WeightChartView> createState() => _WeightChartViewState();
}

class _WeightChartViewState extends ConsumerState<WeightChartView> {
  // Controller for horizontal scrolling
  final ScrollController _scrollController = ScrollController();

  // Visible range for calculating average
  List<WeightEntry> _visibleEntries = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(weightChartViewModelProvider);

    return _buildBody(context, viewModel);
  }

  Widget _buildBody(BuildContext context, WeightChartViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    if (viewModel.chartData.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noWeightDataAvailable),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time period selector
          _buildTimePeriodSelector(context, viewModel),
          const SizedBox(height: 24),

          // Average weight display
          _buildAverageWeightDisplay(context, viewModel),
          const SizedBox(height: 16),

          // Chart
          Expanded(child: _buildChart(context, viewModel)),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector(
    BuildContext context,
    WeightChartViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPeriodButton(
          context,
          TimePeriod.day,
          AppLocalizations.of(context)!.day,
          viewModel,
        ),
        _buildPeriodButton(
          context,
          TimePeriod.week,
          AppLocalizations.of(context)!.week,
          viewModel,
        ),
        _buildPeriodButton(
          context,
          TimePeriod.month,
          AppLocalizations.of(context)!.month,
          viewModel,
        ),
        _buildPeriodButton(
          context,
          TimePeriod.year,
          AppLocalizations.of(context)!.year,
          viewModel,
        ),
      ],
    );
  }

  Widget _buildPeriodButton(
    BuildContext context,
    TimePeriod period,
    String label,
    WeightChartViewModel viewModel,
  ) {
    final isSelected = viewModel.currentTimePeriod == period;
    return ElevatedButton(
      onPressed: () => viewModel.changeTimePeriod(period),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildAverageWeightDisplay(
    BuildContext context,
    WeightChartViewModel viewModel,
  ) {
    final unitPrefs = ref.watch(unitConversionProvider);
    final weightUnit = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Convert weight to display units if needed
    final displayWeight = viewModel.averageWeight != null
        ? (unitPrefs.useMetricWeight
              ? viewModel.averageWeight!
              : viewModel.averageWeight! / 0.45359237)
        : null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.averageWeight + ':',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              displayWeight != null
                  ? '${displayWeight.toStringAsFixed(2)} $weightUnit'
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, WeightChartViewModel viewModel) {
    final unitPrefs = ref.watch(unitConversionProvider);
    final weightUnit = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    // Set initial visible entries
    if (_visibleEntries.isEmpty) {
      _visibleEntries = viewModel.chartData;
      // Update average for visible entries
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.calculateVisibleAverage(_visibleEntries);
      });
    }

    // For day view, just show a single point
    if (viewModel.currentTimePeriod == TimePeriod.day) {
      return _buildDayChart(context, viewModel, weightUnit);
    }

    // For other views, show scrollable chart
    return _buildScrollableChart(context, viewModel, weightUnit);
  }

  Widget _buildDayChart(
    BuildContext context,
    WeightChartViewModel viewModel,
    String weightUnit,
  ) {
    final entry = viewModel.chartData.first;

    if (entry.weight == null) {
      return Center(child: Text(AppLocalizations.of(context)!.averageWeight));
    }

    final unitPrefs = ref.watch(unitConversionProvider);
    final displayWeight = unitPrefs.useMetricWeight
        ? entry.weight!
        : entry.weight! / 0.45359237;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_formatDate(entry.date), style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          Text('${displayWeight.toStringAsFixed(2)} $weightUnit'),
        ],
      ),
    );
  }

  Widget _buildScrollableChart(
    BuildContext context,
    WeightChartViewModel viewModel,
    String weightUnit,
  ) {
    final unitPrefs = ref.watch(unitConversionProvider);

    // Convert weights to display units
    final spots = viewModel.chartData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final weightEntry = entry.value;

      if (weightEntry.weight == null) {
        return FlSpot(index, double.nan); // Use NaN for null values
      }

      final displayWeight = unitPrefs.useMetricWeight
          ? weightEntry.weight!
          : weightEntry.weight! / 0.45359237;

      return FlSpot(index, displayWeight);
    }).toList();

    // Calculate Y-axis range
    final validSpots = spots.where((spot) => !spot.y.isNaN);
    double minY = 0;
    double maxY = 100;

    if (validSpots.isNotEmpty) {
      minY = validSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = validSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

      // Add padding
      final padding = (maxY - minY) * 0.1;
      minY = (minY - padding).clamp(0, double.infinity);
      maxY = maxY + padding;
    }

    // Set appropriate width based on time period
    double chartWidth;
    switch (viewModel.currentTimePeriod) {
      case TimePeriod.week:
        chartWidth =
            MediaQuery.of(context).size.width *
            1.5; // 1.5x screen width for week
        break;
      case TimePeriod.month:
        chartWidth =
            MediaQuery.of(context).size.width * 3; // 3x screen width for month
        break;
      case TimePeriod.year:
        chartWidth =
            MediaQuery.of(context).size.width *
            2; // 2x screen width for year (monthly averages)
        break;
      default:
        chartWidth =
            MediaQuery.of(context).size.width - 32; // Full width for day
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // Calculate visible range based on scroll position
          _updateVisibleEntries(viewModel);
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: chartWidth,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        if (index >= 0 && index < viewModel.chartData.length) {
                          final entry = viewModel.chartData[index];
                          if (touchedSpot.y.isNaN) return null;

                          return LineTooltipItem(
                            '${_formatDate(entry.date)}\n${touchedSpot.y.toStringAsFixed(2)} $weightUnit',
                            const TextStyle(color: Colors.white),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _getXAxisInterval(
                        viewModel.currentTimePeriod,
                        viewModel.chartData.length,
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < viewModel.chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getXAxisLabel(
                                viewModel.chartData[index].date,
                                viewModel.currentTimePeriod,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(2));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (viewModel.chartData.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (spot.y.isNaN)
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                          );
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Update visible entries based on scroll position
  void _updateVisibleEntries(WeightChartViewModel viewModel) {
    if (_scrollController.positions.isEmpty) return;

    final scrollPosition = _scrollController.position;
    final viewportWidth = scrollPosition.viewportDimension;
    final scrollOffset = scrollPosition.pixels;

    // Calculate visible range
    final startX = scrollOffset;
    final endX = scrollOffset + viewportWidth;

    // Calculate visible indices
    final chartWidth =
        _scrollController.position.maxScrollExtent + viewportWidth;
    final pointWidth = chartWidth / viewModel.chartData.length;

    final startIndex = (startX / pointWidth).floor().clamp(
      0,
      viewModel.chartData.length - 1,
    );
    final endIndex = (endX / pointWidth).ceil().clamp(
      0,
      viewModel.chartData.length - 1,
    );

    // Get visible entries
    final visibleEntries = viewModel.chartData.sublist(
      startIndex,
      endIndex + 1,
    );

    // Update average if visible entries changed
    if (!_areListsEqual(visibleEntries, _visibleEntries)) {
      _visibleEntries = visibleEntries;
      viewModel.calculateVisibleAverage(visibleEntries);
    }
  }

  // Helper to compare two lists of weight entries
  bool _areListsEqual(List<WeightEntry> list1, List<WeightEntry> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].date != list2[i].date ||
          list1[i].weight != list2[i].weight) {
        return false;
      }
    }
    return true;
  }

  // Get appropriate interval for X-axis labels based on time period
  double _getXAxisInterval(TimePeriod period, int dataLength) {
    switch (period) {
      case TimePeriod.week:
        return 1; // Show every day
      case TimePeriod.month:
        return 7; // Show every week
      case TimePeriod.year:
        return 1; // Show every month (already aggregated)
      default:
        return 1;
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Get X-axis label based on time period
  String _getXAxisLabel(DateTime date, TimePeriod period) {
    switch (period) {
      case TimePeriod.week:
      case TimePeriod.month:
        return '${date.month}/${date.day}';
      case TimePeriod.year:
        return _getMonthName(date.month);
      default:
        return '${date.month}/${date.day}';
    }
  }

  // Get month name from month number
  String _getMonthName(int month) {
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
    return monthNames[month - 1];
  }
}
