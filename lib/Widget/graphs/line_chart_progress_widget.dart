import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;
import 'dart:ui' as ui;
import '../../ViewModel/date_line_chart.dart';
import '../../theme.dart';
import '../../viewmodel/unit_conversion_provider.dart';
import 'package:intl/intl.dart';

/// A widget that displays a line chart for body measurements over time
/// using the data from the timeAggregationProvider.
class LineChartProgressWidget extends ConsumerStatefulWidget {
  const LineChartProgressWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<LineChartProgressWidget> createState() =>
      _LineChartProgressWidgetState();
}

class _LineChartProgressWidgetState
    extends ConsumerState<LineChartProgressWidget> {
  // Controller for horizontal scrolling
  final ScrollController _scrollController = ScrollController();

  // Currently selected data type to display
  String _selectedDataType = 'Weight'; // This will be initialized in initState

  // Available data types - will be initialized with localized strings
  List<String> _dataTypes = [];

  @override
  void initState() {
    super.initState();
    // Initialize with default, will be updated in build
    _selectedDataType = 'Weight';
  }

  @override
  Widget build(BuildContext context) {
    // Initialize localized data types
    final weight = AppLocalizations.of(context)!.weight;
    final bmi = AppLocalizations.of(context)!.bmi;
    final fatPercentSign = AppLocalizations.of(context)!.fatPercentSign;

    _dataTypes = [weight, bmi, fatPercentSign];

    // Set default selected type if not already set to a localized value
    if (!_dataTypes.contains(_selectedDataType)) {
      _selectedDataType = weight;
    }

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

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.card, // or any other custom color

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimePeriodSelector(selectedTimePeriod),
            const SizedBox(height: 16),
            _buildDataTypeSelector(),
            const SizedBox(height: 16),
            _buildChart(aggregatedData, _selectedDataType),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
            return ElevatedButton(
              onPressed: () {
                ref.read(selectedTimePeriodLineChartProvider.notifier).state =
                    period;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryExtraLight,
                foregroundColor: isSelected
                    ? Colors.white
                    : AppColors.textPrimary,
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              // Fixed: Use 'period' instead of 'selectedTimePeriod'
              child: Text(period.getLocalizedNameCapitalized(context)),
            );
          }).toList(),
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedDataType = type;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryExtraLight,
              foregroundColor: isSelected
                  ? Colors.white
                  : AppColors.textPrimary,
              elevation: isSelected ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(type),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the chart based on the selected data type and time period
  /// Handles empty data cases and ensures proper layout constraints
  Widget _buildChart(List<AggregatedBodyData> data, String selectedDataType) {
    if (data.isEmpty)
      return Text(AppLocalizations.of(context)!.noDataAvailable);

    final reversedData = data.reversed.toList();

    // Get the unit preferences
    final unitPrefs = ref.watch(unitConversionProvider);

    String weight = AppLocalizations.of(context)!.weight;
    String bmi = AppLocalizations.of(context)!.bmi;
    String fat = AppLocalizations.of(context)!.fat;
    String fatPercentSign = AppLocalizations.of(context)!.fatPercentSign;

    // Create a list of data points with their indices
    List<MapEntry<int, double?>> dataPoints = List.generate(
      reversedData.length,
      (i) {
        double? value;
        // Use localized strings for comparison
        if (selectedDataType == weight) {
          value = reversedData[i].avgWeight;
          // Convert weight value based on unit preference
          if (value != null && !unitPrefs.useMetricWeight) {
            value = ref.read(unitConversionProvider.notifier).kgToLb(value);
          }
        } else if (selectedDataType == bmi) {
          value = reversedData[i].avgBmi;
        } else if (selectedDataType == fatPercentSign) {
          value = reversedData[i].avgFatPercentage;
        } else {
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
      return Text(
        AppLocalizations.of(context)!.noDataAvailableForSelectedMetric,
      );
    }

    // Extract valid y-values for min/max calculation
    List<double> yValues = validDataPoints.map((e) => e.value).toList();

    double minY = yValues.reduce((a, b) => a < b ? a : b) - 1;
    double maxY = yValues.reduce((a, b) => a > b ? a : b) + 1;

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

    // Calculate padding for x-axis to prevent data points from being at the edges
    // This adds empty space on each side without showing x-axis values there
    final double xPadding = validDataPoints.isNotEmpty ? 0.5 : 0.0;
    final double minX = validDataPoints.isNotEmpty ? -xPadding : 0.0;
    final double maxX = validDataPoints.isNotEmpty
        ? (validDataPoints.length - 1 + xPadding)
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the available width
        final availableWidth = constraints.maxWidth;

        // Calculate the minimum width needed for the chart based on data points
        final minRequiredWidth = data.length * minSpacePerEntry;

        // Use the larger of available width or minimum required width
        final double chartWidth = max(availableWidth, minRequiredWidth);

        // Get the unit for display
        String unit = '';
        if (selectedDataType == weight) {
          unit = unitPrefs.useMetricWeight ? 'kg' : 'lb';
        } else if (selectedDataType == fatPercentSign) {
          unit = '%';
        }

        // Create a scroll controller to position at the end
        final scrollController = ScrollController();

        // Schedule the scroll to end after the widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          }
        });

        return SizedBox(
          height: 300,
          child: Row(
            children: [
              // Scrollable chart area
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                      child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: displayMin,
                    maxY: displayMax,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        tooltipMargin: 8,
                        getTooltipColor: (spot) => Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.9),
                        tooltipPadding: const EdgeInsets.all(10),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index >= 0 && index < reversedData.length) {
                              final data = reversedData[index];
                              final value = spot.y.toStringAsFixed(1);

                              // Get the unit based on selected data type
                              String unit = '';
                              if (selectedDataType == weight) {
                                final unitPrefs = ref.watch(
                                  unitConversionProvider,
                                );
                                unit = unitPrefs.useMetricWeight ? 'kg' : 'lb';
                              } else if (selectedDataType == bmi) {
                                unit = '';
                              } else if (selectedDataType == fatPercentSign) {
                                unit = '%';
                              }

                              // Include the full date period with year
                              return LineTooltipItem(
                                '$value $unit\n${data.periodLabel}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return null;
                          }).toList();
                        },
                      ),
                      touchSpotThreshold: 20,
                      handleBuiltInTouches: true,
                    ),
                    titlesData: FlTitlesData(
                      // Keep X-axis (bottom) titles unchanged
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 &&
                                value <= validDataPoints.length - 1 &&
                                value == value.roundToDouble()) {
                              int index = value.toInt();
                              if (index < xLabels.length) {
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 8,
                                  child: Transform.translate(
                                    offset: const Offset(0, 8),
                                    child: Text(
                                      xLabels[index],
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      // Hide left Y-axis titles
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      // Hide right Y-axis titles (will be shown separately)
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
                        isCurved: false,
                        curveSmoothness: 0.175,
                        barWidth: 3,
                        color: Theme.of(context).colorScheme.primary,
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
              // Sticky Y-axis on the right
              Container(
                width: 50,
                height: 300,
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: CustomPaint(
                  painter: YAxisPainter(
                    min: displayMin,
                    max: displayMax,
                    step: step,
                    textStyle: Theme.of(context).textTheme.bodySmall!,
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

/// Custom painter for drawing Y-axis labels on the sticky right side
class YAxisPainter extends CustomPainter {
  final double min;
  final double max;
  final double step;
  final TextStyle textStyle;

  YAxisPainter({
    required this.min,
    required this.max,
    required this.step,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the chart area height (excluding padding)
    final chartHeight = size.height - 24; // 16 top + 8 bottom padding
    final chartTop = 16;
    
    // Draw Y-axis labels
    for (double value = min; value <= max; value += step) {
      // Only show labels at step intervals
      if ((value - min) % step < 0.001 || (min + step * (((max - min) ~/ step)) - value) % step < 0.001) {
        // Calculate Y position
        final normalizedY = (max - value) / (max - min);
        final yPos = chartTop + (normalizedY * chartHeight);
        
        // Create text painter
        final textPainter = TextPainter(
          text: TextSpan(
            text: value.toStringAsFixed(0),
            style: textStyle,
          ),
          textDirection: ui.TextDirection.ltr,
        );
        
        textPainter.layout();
        
        // Draw the text
        textPainter.paint(
          canvas,
          Offset(8, yPos - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(YAxisPainter oldDelegate) {
    return oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.step != step ||
        oldDelegate.textStyle != textStyle;
  }
}
