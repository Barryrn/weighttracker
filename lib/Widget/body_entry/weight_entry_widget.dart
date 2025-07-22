import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../viewmodel/entry_form_provider.dart';
import '../../viewmodel/unit_conversion_provider.dart';

class WeightEntry extends ConsumerStatefulWidget {
  const WeightEntry({Key? key}) : super(key: key);

  @override
  ConsumerState<WeightEntry> createState() => _WeightEntryState();
}

class _WeightEntryState extends ConsumerState<WeightEntry> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize with the current weight, converting from standard unit (kg) if needed
    final weight = ref.read(bodyEntryProvider).weight;
    final unitPrefs = ref.read(unitConversionProvider);

    if (weight != null) {
      final displayWeight = unitPrefs.useMetricWeight
          ? weight
          : weight / 0.45359237;
      _controller = TextEditingController(
        text: displayWeight.toStringAsFixed(1),
      );
    } else {
      _controller = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onWeightChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);
    final unitPrefs = ref.read(unitConversionProvider);

    if (value.isEmpty) {
      notifier.updateWeight(null, useMetric: unitPrefs.useMetricWeight);
      return;
    }

    try {
      final parsed = double.parse(value.replaceAll(',', '.'));
      notifier.updateWeight(parsed, useMetric: unitPrefs.useMetricWeight);
    } catch (_) {
      // silently ignore
    }
  }

  void _toggleUnit() {
    final unitNotifier = ref.read(unitConversionProvider.notifier);
    final currentPrefs = ref.read(unitConversionProvider);
    final currentWeight = ref.read(bodyEntryProvider).weight;

    // Toggle the unit preference
    unitNotifier.setWeightUnit(useMetric: !currentPrefs.useMetricWeight);

    // Update the text field with the converted value
    if (currentWeight != null) {
      final newUnitPrefs = ref.read(unitConversionProvider);
      final displayWeight = newUnitPrefs.useMetricWeight
          ? currentWeight
          : currentWeight / 0.45359237;

      setState(() {
        _controller.text = displayWeight.toStringAsFixed(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitPrefs = ref.watch(unitConversionProvider);
    final unitSuffix = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weight ($unitSuffix)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: _controller,
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
            onChanged: _onWeightChanged,
            decoration: InputDecoration(
              hintText: 'Enter your weight',
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
      ],
    );
  }
}
