import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
              AppLocalizations.of(context)!.weight +
                  ' (${entryData.unitSuffix})',
              style: AppTypography.bodyLarge(context),
            ),
            // Unit toggle button
            // TextButton(
            //   onPressed: viewModel.toggleUnit,
            //   child: Text(
            //     'Switch to ${entryData.useMetricWeight ? "lb" : "kg"}',
            //                 //   ),
            // ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: TextFormField(
            controller: entryData.weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              TextInputFormatter.withFunction((oldValue, newValue) {
                // ALWAYS allow empty values - this is crucial for null handling
                if (newValue.text.isEmpty) {
                  return newValue;
                }

                // Replace comma with period for consistency
                String text = newValue.text.replaceAll(',', '.');

                // Handle multiple decimal points
                if (text.split('.').length > 2) {
                  return oldValue;
                }

                // Limit to two decimal places
                if (text.contains('.')) {
                  final parts = text.split('.');
                  if (parts[1].length > 2) {
                    // Truncate to two decimal places
                    text = '${parts[0]}.${parts[1].substring(0, 2)}';
                    return newValue.copyWith(
                      text: text,
                      selection: TextSelection.collapsed(offset: text.length),
                    );
                  }
                }

                // Allow standalone decimal point or number followed by decimal
                if (text == '.' || text.endsWith('.')) {
                  return newValue.copyWith(text: text);
                }

                // Validate that it's a proper number
                if (RegExp(r'^\d+\.?\d*$').hasMatch(text)) {
                  try {
                    double.parse(text);
                    return newValue.copyWith(text: text);
                  } catch (_) {
                    return oldValue;
                  }
                } else {
                  return oldValue;
                }
              }),
            ],
            onChanged: (value) {
              // DEBUG: Let's see what's happening
              print(
                '🔍 Widget onChanged called with: "$value" (isEmpty: ${value.isEmpty})',
              );

              // Handle empty string explicitly to ensure null state
              if (value.isEmpty) {
                print('🔍 Calling viewModel.onWeightChanged with empty string');
                viewModel.onWeightChanged('');
              } else {
                print('🔍 Calling viewModel.onWeightChanged with: "$value"');
                viewModel.onWeightChanged(value);
              }
            },
            decoration: InputDecoration(
              hintText: '0.00',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Text(
                  entryData.unitSuffix,
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.textDisabled),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
            style: AppTypography.subtitle2(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
