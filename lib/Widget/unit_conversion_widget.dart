import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/View/fat_percentage_view.dart';
import 'package:weigthtracker/ViewModel/weight_entry_view_model.dart';
import 'package:weigthtracker/ViewModel/profile_settings_provider.dart';
import 'package:weigthtracker/ViewModel/fat_percentage_view_model.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/weight_goal_view_model.dart';

class UnitConversionWidget extends ConsumerStatefulWidget {
  const UnitConversionWidget({super.key});

  @override
  ConsumerState<UnitConversionWidget> createState() =>
      _UnitConversionWidgetState();
}

class _UnitConversionWidgetState extends ConsumerState<UnitConversionWidget> {
  final GlobalKey<FatPercentageViewState> fatPercentageKey = GlobalKey();

  bool toggleFatUnit = true;

  @override
  Widget build(BuildContext context) {
    final goalData = ref.watch(weightGoalViewModelProvider);
    final goalViewModel = ref.read(weightGoalViewModelProvider.notifier);

    final entryData = ref.watch(weightEntryProvider);
    final entryViewModel = ref.read(weightEntryProvider.notifier);

    // Watch the height unit provider to get updates
    final useMetricHeight = ref.watch(heightUnitProvider);
    final heightUnitNotifier = ref.read(heightUnitProvider.notifier);

    final useMetric = goalData.useMetricWeight && entryData.useMetricWeight;

    // Set toggleFatUnit based on the provider state
    toggleFatUnit = !useMetricHeight;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.card,
            borderRadius: BorderRadius.circular(10), // Abgerundete Ecken
          ),

          padding: const EdgeInsets.all(12),
          child: SwitchListTile(
            title: Text(
              'Use ${useMetric ? "Kilograms (kg)" : "Pounds (lb)"}',
              style: AppTypography.bodyMedium(context).copyWith(
                color: Theme.of(context).colorScheme.textPrimary,
              ),
            ),
            value: useMetric,
            onChanged: (value) {
              goalViewModel.toggleUnit();
              entryViewModel.toggleUnit();
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.card,
            borderRadius: BorderRadius.circular(10), // Abgerundete Ecken
          ),
          padding: const EdgeInsets.all(12),
          child: SwitchListTile(
            title: Text(
              'Use ${toggleFatUnit ? "Inches" : "Centimeters"}',
              style: AppTypography.bodyMedium(context).copyWith(
                color: Theme.of(context).colorScheme.textPrimary,
              ),
            ),
            value: !toggleFatUnit, // Invert the value here
            onChanged: (value) {
              setState(() {
                toggleFatUnit =
                    !value; // Invert again to update the actual variable
              });
              // Update the height unit provider with the new value
              heightUnitNotifier.updateHeightUnit(!toggleFatUnit);
              // Call toggleMeasurementUnits on the ViewModel instead of the ViewState
              ref
                  .read(fatPercentageViewModelProvider.notifier)
                  .toggleMeasurementUnits();
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Offstage(
          offstage: true,
          child: FatPercentageView(key: fatPercentageKey),
        ),
      ],
    );
  }
}
