import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/weight_entry_view_model.dart';

/// A widget that allows users to enter their weight.
///
/// This widget follows the MVVM pattern by using the weightEntryProvider
/// to access the ViewModel that manages all business logic and state.
class WeightEntry extends ConsumerWidget {
  const WeightEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the weight entry data from the ViewModel
    final entryData = ref.watch(weightEntryProvider);
    final viewModel = ref.read(weightEntryProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weight (${entryData.unitSuffix})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            // Unit toggle button
            TextButton(
              onPressed: viewModel.toggleUnit,
              child: Text(
                'Switch to ${entryData.useMetricWeight ? "lb" : "kg"}',
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
            controller: entryData.weightController,
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
            onChanged: viewModel.onWeightChanged,
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
                  entryData.unitSuffix,
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
