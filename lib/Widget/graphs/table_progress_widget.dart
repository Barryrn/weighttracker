import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme.dart';
import '../../viewmodel/time_aggregation_provider.dart';
import '../../viewmodel/unit_conversion_provider.dart';

/// A widget that displays aggregated body data for different time periods.
///
/// This widget follows the MVVM pattern by using the timeAggregationProvider
/// to access the aggregated data and the selectedTimePeriodProvider to manage
/// the currently selected time period.
class TableProgressWidget extends ConsumerStatefulWidget {
  const TableProgressWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<TableProgressWidget> createState() =>
      _TableProgressWidgetState();
}

class _TableProgressWidgetState extends ConsumerState<TableProgressWidget> {
  @override
  void initState() {
    super.initState();
    // Load initial data with the default time period
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedPeriod = ref.read(selectedTimePeriodProvider);
      ref.read(timeAggregationProvider.notifier).aggregateData(selectedPeriod);
    });
  }

  /// Changes the selected time period and fetches new aggregated data
  void _selectTimePeriod(TimePeriod period) {
    ref.read(selectedTimePeriodProvider.notifier).state = period;
    ref.read(timeAggregationProvider.notifier).aggregateData(period);
  }

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(selectedTimePeriodProvider);
    final aggregatedData = ref.watch(timeAggregationProvider);
    final unitPrefs = ref.watch(unitConversionProvider);

    final weightUnit = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time period selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton(TimePeriod.day, 'Day', selectedPeriod),
                _buildPeriodButton(TimePeriod.week, 'Week', selectedPeriod),
                _buildPeriodButton(TimePeriod.month, 'Month', selectedPeriod),
                _buildPeriodButton(TimePeriod.year, 'Year', selectedPeriod),
              ],
            ),
            const SizedBox(height: 24),

            // Data display
            if (aggregatedData.isEmpty)
              const Center(
                child: Text(
                  'No data available for this time period',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aggregatedData.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final data = aggregatedData[index];

                  // Convert weight to display units if needed
                  final displayWeight =
                      data.avgWeight != null && !unitPrefs.useMetricWeight
                      ? data.avgWeight! / 0.45359237
                      : data.avgWeight;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period label
                        Text(
                          data.periodLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Data rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDataColumn(
                              'Weight',
                              displayWeight != null
                                  ? '${displayWeight.toStringAsFixed(1)} $weightUnit'
                                  : '--',
                            ),
                            _buildDataColumn(
                              'BMI',
                              data.avgBmi != null
                                  ? data.avgBmi!.toStringAsFixed(1)
                                  : '--',
                            ),
                            _buildDataColumn(
                              'Body Fat',
                              data.avgFatPercentage != null
                                  ? '${data.avgFatPercentage!.toStringAsFixed(1)}%'
                                  : '--',
                            ),
                          ],
                        ),

                        // Entry count
                        Text(
                          'Based on ${data.entryCount} ${data.entryCount == 1 ? 'entry' : 'entries'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a time period selection button
  Widget _buildPeriodButton(
    TimePeriod period,
    String label,
    TimePeriod selectedPeriod,
  ) {
    final isSelected = period == selectedPeriod;

    return ElevatedButton(
      onPressed: () => _selectTimePeriod(period),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : AppColors.primaryDark,
        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  /// Builds a data column with label and value
  Widget _buildDataColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
