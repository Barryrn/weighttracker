import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/weight_entry_view_model.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/weight_goal_view_model.dart';

class TestWidget extends ConsumerWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalData = ref.watch(weightGoalViewModelProvider);
    final goalViewModel = ref.read(weightGoalViewModelProvider.notifier);

    final entryData = ref.watch(weightEntryProvider);
    final entryViewModel = ref.read(weightEntryProvider.notifier);

    final useMetric = goalData.useMetricWeight && entryData.useMetricWeight;

    return SwitchListTile(
      title: Text(
        'Use ${useMetric ? "Kilograms (kg)" : "Pounds (lb)"}',
        style: const TextStyle(color: AppColors.primary, fontSize: 14),
      ),
      value: useMetric,
      onChanged: (value) {
        goalViewModel.toggleUnit();
        entryViewModel.toggleUnit();
      },
      activeColor: AppColors.primary,
    );
  }
}
