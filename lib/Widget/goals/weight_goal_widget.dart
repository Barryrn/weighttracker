import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/weight_goal_view_model.dart';

/// A widget that allows users to set and save their weight goal.
///
/// This widget follows the MVVM pattern by using the weightGoalViewModelProvider
/// to access the ViewModel that manages all business logic and state.
class WeightGoalWidget extends ConsumerWidget {
  const WeightGoalWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the weight goal data from the ViewModel
    final goalData = ref.watch(weightGoalViewModelProvider);
    final viewModel = ref.read(weightGoalViewModelProvider.notifier);

    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.2),
      color: AppColors.card,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Weight Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Unit toggle button
                // TextButton(
                //   onPressed: viewModel.toggleUnit,
                //   child: Text(
                //     'Switch to ${goalData.useMetricWeight ? "lb" : "kg"}',
                //     style: const TextStyle(fontSize: 14, color: AppColors.primary),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),

            // Start weight field
            Text(
              'Set your start weight (${goalData.unitSuffix})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: TextFormField(
                controller: goalData.startController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text.replaceAll(',', '.');
                    try {
                      if (text.isEmpty) return newValue;
                      if (text.split('.').length > 2) return oldValue;
                      if (text.contains('.')) {
                        final decimals = text.split('.')[1];
                        if (decimals.length > 1) return oldValue;
                      }
                      double.parse(text);
                      return newValue.copyWith(text: text);
                    } catch (_) {
                      return oldValue;
                    }
                  }),
                ],
                onChanged: viewModel.onStartWeightChanged,
                decoration: InputDecoration(
                  hintText: '0.0',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      goalData.unitSuffix,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            // Target weight field
            Text(
              'Set your target weight (${goalData.unitSuffix})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: TextFormField(
                controller: goalData.goalController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text.replaceAll(',', '.');
                    try {
                      if (text.isEmpty) return newValue;
                      if (text.split('.').length > 2) return oldValue;
                      if (text.contains('.')) {
                        final decimals = text.split('.')[1];
                        if (decimals.length > 1) return oldValue;
                      }
                      double.parse(text);
                      return newValue.copyWith(text: text);
                    } catch (_) {
                      return oldValue;
                    }
                  }),
                ],
                onChanged: viewModel.onWeightGoalChanged,
                decoration: InputDecoration(
                  hintText: '0.0',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      goalData.unitSuffix,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your progress will be tracked against this goal',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
