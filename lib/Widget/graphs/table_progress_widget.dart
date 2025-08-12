import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
      color: Theme.of(context).colorScheme.card, // or any other custom color

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time period selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPeriodButton(
                  TimePeriod.day,
                  AppLocalizations.of(context)!.day,
                  selectedPeriod,
                ),
                _buildPeriodButton(
                  TimePeriod.week,
                  AppLocalizations.of(context)!.week,
                  selectedPeriod,
                ),
                _buildPeriodButton(
                  TimePeriod.month,
                  AppLocalizations.of(context)!.month,
                  selectedPeriod,
                ),
                _buildPeriodButton(
                  TimePeriod.year,
                  AppLocalizations.of(context)!.year,
                  selectedPeriod,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data display
            if (aggregatedData.isEmpty)
              Center(child: Text('No data available for this time period'))
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
                        Text(data.periodLabel),
                        const SizedBox(height: 8),

                        // Data rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDataColumn(
                              AppLocalizations.of(context)!.weight,
                              displayWeight != null
                                  ? '${displayWeight.toStringAsFixed(1)} $weightUnit'
                                  : '--',
                            ),
                            _buildDataColumn(
                              AppLocalizations.of(context)!.bmi,
                              data.avgBmi != null
                                  ? data.avgBmi!.toStringAsFixed(1)
                                  : '--',
                            ),
                            _buildDataColumn(
                              AppLocalizations.of(context)!.bodyFat,
                              data.avgFatPercentage != null
                                  ? '${data.avgFatPercentage!.toStringAsFixed(1)}%'
                                  : '--',
                            ),
                          ],
                        ),

                        // Entry count
                        Text(
                          '${AppLocalizations.of(context)!.basedOn} ${data.entryCount} ${data.entryCount == 1 ? AppLocalizations.of(context)!.entry : AppLocalizations.of(context)!.entries}',
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
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primaryExtraLight,
        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  /// Builds a data column with label and value
  Widget _buildDataColumn(String label, String value) {
    return Column(
      children: [Text(label), const SizedBox(height: 4), Text(value)],
    );
  }
}
