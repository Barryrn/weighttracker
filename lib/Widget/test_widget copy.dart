import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/View/fat_percentage_view.dart';
import 'package:weigthtracker/ViewModel/weight_entry_view_model.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/weight_goal_view_model.dart';

class TestWidget extends ConsumerWidget {
  TestWidget({super.key});

  final GlobalKey<FatPercentageViewState> fatPercentageKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalData = ref.watch(weightGoalViewModelProvider);
    final goalViewModel = ref.read(weightGoalViewModelProvider.notifier);

    final entryData = ref.watch(weightEntryProvider);
    final entryViewModel = ref.read(weightEntryProvider.notifier);

    final useMetric = goalData.useMetricWeight && entryData.useMetricWeight;

    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Use ${useMetric ? "Kilograms (kg)" : "Pounds (lb)"}',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          value: useMetric,
          onChanged: (value) {
            goalViewModel.toggleUnit();
            entryViewModel.toggleUnit();
          },
          activeColor: AppColors.primary,
        ),
        FatPercentageView(key: fatPercentageKey),
        ElevatedButton(
          onPressed: () {
            fatPercentageKey.currentState?.toggleMeasurementUnits();
          },
          child: Text("Toggle Units"),
        ),
      ],
    );
  }
}
