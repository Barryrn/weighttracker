import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/weight_goal_provider.dart';
import '../../viewmodel/unit_conversion_provider.dart';
import '../../viewmodel/start_weight_provider.dart';

/// A widget that allows users to set and save their weight goal.
///
/// This widget follows the MVVM pattern by using the weightGoalProvider to access
/// the current state and saving it to SharedPreferences through the WeightGoalNotifier.
class WeightGoalWidget extends ConsumerStatefulWidget {
  const WeightGoalWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<WeightGoalWidget> createState() => _WeightGoalWidgetState();
}

class _WeightGoalWidgetState extends ConsumerState<WeightGoalWidget> {
  late TextEditingController _goalController;
  late TextEditingController _startController;

  @override
  void initState() {
    super.initState();
    final unitPrefs = ref.read(unitConversionProvider);
    
    // Initialize with the current weight goal, converting from standard unit (kg) if needed
    final weightGoal = ref.read(weightGoalProvider);
    if (weightGoal != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? weightGoal
          : weightGoal / 0.45359237;
      _goalController = TextEditingController(
        text: displayWeight.toStringAsFixed(1),
      );
    } else {
      _goalController = TextEditingController(text: '');
    }
    
    // Initialize with the current start weight, converting from standard unit (kg) if needed
    final startWeight = ref.read(startWeightProvider);
    if (startWeight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? startWeight
          : startWeight / 0.45359237;
      _startController = TextEditingController(
        text: displayWeight.toStringAsFixed(1),
      );
    } else {
      _startController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _startController.dispose();
    super.dispose();
  }

  void _onWeightGoalChanged(String value) {
    final notifier = ref.read(weightGoalProvider.notifier);
    final unitPrefs = ref.read(unitConversionProvider);

    if (value.isEmpty) {
      notifier.updateWeightGoal(null, useMetric: unitPrefs.useMetricWeight);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateWeightGoal(parsed, useMetric: unitPrefs.useMetricWeight);
    } catch (_) {
      // silently ignore
    }
  }
  
  void _onStartWeightChanged(String value) {
    final notifier = ref.read(startWeightProvider.notifier);
    final unitPrefs = ref.read(unitConversionProvider);

    if (value.isEmpty) {
      notifier.updateStartWeight(null, useMetric: unitPrefs.useMetricWeight);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateStartWeight(parsed, useMetric: unitPrefs.useMetricWeight);
    } catch (_) {
      // silently ignore
    }
  }

  void _toggleUnit() {
    final unitNotifier = ref.read(unitConversionProvider.notifier);
    final currentPrefs = ref.read(unitConversionProvider);
    final currentWeightGoal = ref.read(weightGoalProvider);
    final currentStartWeight = ref.read(startWeightProvider);

    // Toggle the unit preference
    unitNotifier.setWeightUnit(useMetric: !currentPrefs.useMetricWeight);

    // Update the goal text field with the converted value
    if (currentWeightGoal != null) {
      final newUnitPrefs = ref.read(unitConversionProvider);
      final displayWeight = newUnitPrefs.useMetricWeight
          ? currentWeightGoal
          : currentWeightGoal / 0.45359237;

      setState(() {
        _goalController.text = displayWeight.toStringAsFixed(1);
      });
    }
    
    // Update the start weight text field with the converted value
    if (currentStartWeight != null) {
      final newUnitPrefs = ref.read(unitConversionProvider);
      final displayWeight = newUnitPrefs.useMetricWeight
          ? currentStartWeight
          : currentStartWeight / 0.45359237;

      setState(() {
        _startController.text = displayWeight.toStringAsFixed(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitPrefs = ref.watch(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weight Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Unit toggle button
                TextButton(
                  onPressed: _toggleUnit,
                  child: Text(
                    'Switch to ${unitPrefs.useMetricWeight ? "lb" : "kg"}',
                    style: const TextStyle(fontSize: 14, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Start weight field
            Text(
              'Set your start weight ($unitSuffix)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: TextFormField(
                controller: _startController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                onChanged: _onStartWeightChanged,
                decoration: InputDecoration(
                  hintText: 'Enter your starting weight',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      unitSuffix,
                      style: const TextStyle(color: Colors.grey),
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
              'Set your target weight ($unitSuffix)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: TextFormField(
                controller: _goalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                onChanged: _onWeightGoalChanged,
                decoration: InputDecoration(
                  hintText: 'Enter your target weight',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      unitSuffix,
                      style: const TextStyle(color: Colors.grey),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}