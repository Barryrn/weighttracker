import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;
import '../viewmodel/date_line_chart.dart';
import '../theme.dart';
import '../viewmodel/unit_conversion_provider.dart';
import 'package:intl/intl.dart';

/// A widget that displays a line chart for body measurements over time
/// using the data from the timeAggregationProvider.
class TimePeriodLineChartWidget extends ConsumerStatefulWidget {
  const TimePeriodLineChartWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<TimePeriodLineChartWidget> createState() =>
      _TimePeriodLineChartWidgetState();
}

class _TimePeriodLineChartWidgetState
    extends ConsumerState<TimePeriodLineChartWidget> {
  // Controller for horizontal scrolling
  final ScrollController _scrollController = ScrollController();

  // Currently selected data type to display
  String _selectedDataType = 'Weight';

  // Available data types
  final List<String> _dataTypes = ['Weight', 'BMI', 'Fat %'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current time period from the provider
    final selectedTimePeriod = ref.watch(selectedTimePeriodLineChartProvider);

    // Get the aggregated data from the provider
    final aggregatedData = ref.watch(timeAggregationProvider);

    // Load data when the widget is first built or when the time period changes
    ref.listen(selectedTimePeriodLineChartProvider, (previous, next) {
      if (previous != next) {
        _loadData(next);
      }
    });

    // Load data on initial build
    if (aggregatedData.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData(selectedTimePeriod);
      });
    }

    return Column(
      children: [
        _buildTimePeriodSelector(selectedTimePeriod),
        const SizedBox(height: 16),
        _buildDataTypeSelector(),
        const SizedBox(height: 16),
        _buildChart(aggregatedData, _selectedDataType),
      ],
    );
  }

  /// Loads data for the selected time period
  void _loadData(TimePeriodLineChart period) {
    ref.read(timeAggregationProvider.notifier).aggregateData(period);
    print(ref.read(timeAggregationProvider));
  }

  /// Builds the time period selector (day, week, month, year)
  Widget _buildTimePeriodSelector(TimePeriodLineChart selectedPeriod) {
    // Get the aggregated data to display date ranges
    final aggregatedData = ref.watch(timeAggregationProvider);
    String periodRangeText = '';

    if (aggregatedData.isNotEmpty) {
      // Find the earliest and latest dates in the current view
      final firstDate = aggregatedData.last.periodStart;
      final lastDate = aggregatedData.first.periodEnd;

      switch (selectedPeriod) {
        case TimePeriodLineChart.week:
          // Format: Jul XX - Jul YY 2025
          if (firstDate.month == lastDate.month) {
            periodRangeText =
                '${_getMonthName(firstDate.month)} ${firstDate.day} - ${lastDate.day} ${lastDate.year}';
          } else {
            periodRangeText =
                '${_getMonthName(firstDate.month)} ${firstDate.day} - ${_getMonthName(lastDate.month)} ${lastDate.day} ${lastDate.year}';
          }
          break;
        case TimePeriodLineChart.month:
          // Format: Jul XX - Jul YY 2025
          if (firstDate.month == lastDate.month) {
            periodRangeText =
                '${_getMonthName(firstDate.month)} ${firstDate.day} - ${lastDate.day} ${lastDate.year}';
          } else {
            periodRangeText =
                '${_getMonthName(firstDate.month)} ${firstDate.day} - ${_getMonthName(lastDate.month)} ${lastDate.day} ${lastDate.year}';
          }
          break;
        case TimePeriodLineChart.year:
          // Format: Jul 2024 - Jul 2025 (if different years)
          if (firstDate.year == lastDate.year) {
            periodRangeText =
                '${_getMonthName(firstDate.month)} - ${_getMonthName(lastDate.month)} ${lastDate.year}';
          } else {
            periodRangeText =
                '${_getMonthName(firstDate.month)} ${firstDate.year} - ${_getMonthName(lastDate.month)} ${lastDate.year}';
          }
          break;
        default:
          periodRangeText = '';
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TimePeriodLineChart.values.map((period) {
            final isSelected = period == selectedPeriod;
            return GestureDetector(
              onTap: () {
                ref.read(selectedTimePeriodLineChartProvider.notifier).state =
                    period;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    width: 1,
                  ),
                ),
                child: Text(
                  period.name.capitalize(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (periodRangeText.isNotEmpty &&
            selectedPeriod != TimePeriodLineChart.day)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              periodRangeText,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  /// Builds the data type selector (Weight, BMI, Fat %)
  Widget _buildDataTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _dataTypes.map((type) {
        final isSelected = type == _selectedDataType;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDataType = type;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                width: 1,
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the chart based on the selected data type and time period
  /// Handles empty data cases and ensures proper layout constraints
  Widget _buildChart(List<AggregatedBodyData> data, String selectedDataType) {
    if (data.isEmpty) return const Text("No data available");

    final reversedData = data.reversed.toList();

    // Create a list of data points with their indices
    List<MapEntry<int, double?>> dataPoints = List.generate(
      reversedData.length,
      (i) {
        double? value;
        switch (selectedDataType.toLowerCase()) {
          case 'weight':
            value = reversedData[i].avgWeight;
            break;
          case 'bmi':
            value = reversedData[i].avgBmi;
            break;
          case 'fat':
          case 'fat %':
            value = reversedData[i].avgFatPercentage;
            break;
          default:
            value = null;
        }
        return MapEntry(i, value);
      },
    );

    // Filter out null values
    List<MapEntry<int, double>> validDataPoints = dataPoints
        .where((entry) => entry.value != null)
        .map((entry) => MapEntry(entry.key, entry.value!))
        .toList();

    // If no valid data points, show a message
    if (validDataPoints.isEmpty) {
      return const Text("No data available for selected metric");
    }

    // Extract valid y-values for min/max calculation
    List<double> yValues = validDataPoints.map((e) => e.value).toList();

    double minY = yValues.reduce((a, b) => a < b ? a : b);
    double maxY = yValues.reduce((a, b) => a > b ? a : b);

    double range = (maxY - minY).abs();
    if (range == 0) range = 1;
    double step = _chooseStepSize(range);
    double displayMin = (minY / step).floor() * step;
    double displayMax = (maxY / step).ceil() * step;

    final formatter = DateFormat('MMM d');
    List<String> xLabels = reversedData.map((e) {
      String start = formatter.format(e.periodStart);
      String end = formatter.format(e.periodEnd);
      return e.periodStart == e.periodEnd ? start : "$start - $end";
    }).toList();

    // Create spots only for valid data points
    List<FlSpot> spots = validDataPoints
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    // Minimum space between entries to ensure good readability
    const double minSpacePerEntry = 100.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the available width
        final availableWidth = constraints.maxWidth;

        // Calculate the minimum width needed for the chart based on data points
        final minRequiredWidth = data.length * minSpacePerEntry;

        // Use the larger of available width or minimum required width
        final double chartWidth = max(availableWidth, minRequiredWidth);

        return SizedBox(
          height: 300,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Y-Axis
              SizedBox(
                width: 40, // Muss mit reservedSize der Y-Achse übereinstimmen
                child: Column(
                  children: List.generate(
                    ((displayMax - displayMin) ~/ step + 1),
                    (i) {
                      double value = displayMax - (i * step);
                      return Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 4),
                          child: Transform.translate(
                            offset: const Offset(0, -8), // 🔧 Feinjustierung
                            child: Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Scrollable Chart
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
                      child: LineChart(
                        LineChartData(
                          minY: displayMin,
                          maxY: displayMax,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < xLabels.length) {
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 8,
                                      child: Transform.translate(
                                        offset: const Offset(0, 8),
                                        child: Text(
                                          xLabels[index],
                                          style: const TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: const Color(0xff37434d),
                              width: 1,
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: step,
                            drawVerticalLine: true,
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.blueAccent,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                        duration: Duration.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Heuristik für sauberen Schritt auf Y-Achse
  double _chooseStepSize(double range) {
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    return 20;
  }

  /// Calculates an appropriate interval for the Y-axis based on the data range
  double _calculateInterval(double min, double max) {
    final range = max - min;
    if (range <= 5) return 1;
    if (range <= 20) return 2;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    return range / 10;
  }

  /// Gets the appropriate interval for X-axis labels based on time period and data length
  double _getXAxisInterval(TimePeriodLineChart period, int dataLength) {
    switch (period) {
      case TimePeriodLineChart.day:
        // For day view, show fewer labels if we have many data points
        return dataLength > 12 ? 4 : 2;
      case TimePeriodLineChart.week:
        // For week view, ensure we see multiple days
        return dataLength > 14 ? 2 : 1;
      case TimePeriodLineChart.month:
        // For month view, show more evenly distributed labels
        return dataLength > 30 ? 5 : 2;
      case TimePeriodLineChart.year:
        // For year view, show more evenly distributed labels
        return dataLength > 12 ? 3 : 1;
    }
  }

  /// Gets the appropriate X-axis label based on the time period
  String _getXAxisLabel(AggregatedBodyData data, TimePeriodLineChart period) {
    switch (period) {
      case TimePeriodLineChart.day:
        // Format: "10:00 AM/PM DD MMM" to include day and month
        final hour = data.periodStart.hour;
        final minute = data.periodStart.minute.toString().padLeft(2, '0');
        final ampm = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final day = data.periodStart.day;
        final month = _getMonthName(data.periodStart.month);
        return '$displayHour:$minute $ampm\n$day $month';
      case TimePeriodLineChart.week:
        // Format: "Mon DD" with date range in the period range text above
        return '${_getWeekdayName(data.periodStart.weekday)} ${data.periodStart.day}';
      case TimePeriodLineChart.month:
        // Format: "DD MMM" - day first for better scanning
        return '${data.periodStart.day} ${_getMonthName(data.periodStart.month)}';
      case TimePeriodLineChart.year:
        // Format: "MMM 'YY" - include year for clarity
        final yearSuffix = data.periodStart.year.toString().substring(2);
        return '${_getMonthName(data.periodStart.month)} \'$yearSuffix';
    }
  }

  /// Helper method to get month name from month number
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

  /// Helper method to get weekday name from weekday number
  String _getWeekdayName(int weekday) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdayNames[weekday - 1];
  }
}

/// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
