import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/calorie_entry_view_model.dart';

/// A widget that allows users to enter their calorie intake.
///
/// This widget follows the MVVM pattern by using the calorieEntryProvider
/// to access the ViewModel that manages all business logic and state.
class CalorieEntry extends ConsumerWidget {
  const CalorieEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the calorie entry data from the ViewModel
    final entryData = ref.watch(calorieEntryProvider);
    final viewModel = ref.read(calorieEntryProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.caloriesKcal,
              style: AppTypography.bodyLarge(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
            ),
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
            controller: entryData.calorieController,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [
              // Only allow digits
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            onChanged: viewModel.onCalorieChanged,
            decoration: InputDecoration(
              hintText: '0',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text(
                  'kcal',
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.textDisabled),
                ),
              ),
              suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
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
