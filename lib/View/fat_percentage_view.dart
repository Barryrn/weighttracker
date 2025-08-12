import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/entry_form_provider.dart';
import 'package:weigthtracker/Widget/test_widget.dart';
import '../ViewModel/fat_percentae_calculator.dart';
import '../model/profile_settings_storage_model.dart';
import '../model/profile_settings_model.dart';
import '../ViewModel/unit_conversion_provider.dart';
import '../ViewModel/fat_percentage_view_model.dart';
import '../theme.dart';

/// A view that allows users to calculate their body fat percentage based on measurements.
///
/// This view follows the MVVM pattern by delegating business logic to the
/// FatPercentageViewModel and only handling UI rendering and user interaction.
class FatPercentageView extends ConsumerStatefulWidget {
  const FatPercentageView({Key? key}) : super(key: key);

  @override
  ConsumerState<FatPercentageView> createState() => FatPercentageViewState();
}

class FatPercentageViewState extends ConsumerState<FatPercentageView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load profile settings via the ViewModel
    Future.microtask(
      () => ref
          .read(fatPercentageViewModelProvider.notifier)
          .loadProfileSettings(),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers via the ViewModel
    ref.read(fatPercentageViewModelProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel state and unit preferences
    final viewModelState = ref.watch(fatPercentageViewModelProvider);
    final unitPrefs = ref.watch(unitConversionProvider);
    final lengthUnit = unitPrefs.useMetricHeight ? 'cm' : 'inches';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fat Percentage Calculator',
          style: AppTypography.headline3(context),
        ),

        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.textTertiary,
      ),
      backgroundColor: Theme.of(context).colorScheme.background2,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: viewModelState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gender selection
                          // const Text(
                          //   'Gender',
                          //                             // ),
                          const SizedBox(height: 16),

                          // Height input
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text(
                              //   'Height ($lengthUnit)',
                              //                                 // ),

                              // TextButton(
                              //   onPressed: () {
                              //     ref
                              //         .read(
                              //           fatPercentageViewModelProvider.notifier,
                              //         )
                              //         .toggleMeasurementUnits();
                              //   },
                              //   style: TextButton.styleFrom(
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(10)
                              // ,
                              //     ),
                              //     backgroundColor: Theme.of(context).colorScheme.primaryDark,
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 12,
                              //       vertical: 8,
                              //     ),
                              //   ),
                              //   child: Text(
                              //     'Switch to ${unitPrefs.useMetricHeight ? "inches" : "cm"}',
                              //                                   //   ),
                              // ),
                            ],
                          ),
                          // const SizedBox(height: 8),
                          // TextFormField(
                          //   controller: viewModelState.heightController,
                          //   decoration: InputDecoration(
                          //     filled: true,
                          //     fillColor: Theme.of(context).colorScheme.card, // Hintergrundfarbe
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(10)
                          // ,
                          //     ),
                          //     contentPadding: const EdgeInsets.symmetric(
                          //       horizontal: 16,
                          //       vertical: 12,
                          //     ),
                          //     suffixText: lengthUnit,
                          //   ),
                          //   keyboardType: const TextInputType.numberWithOptions(
                          //     decimal: true,
                          //   ),
                          //   inputFormatters: [
                          //     FilteringTextInputFormatter.allow(
                          //       RegExp(r'[0-9.,]'),
                          //     ),
                          //   ],
                          //   validator: (value) => ref
                          //       .read(fatPercentageViewModelProvider.notifier)
                          //       .validateNumber(value),
                          //   onChanged: (value) {
                          //     ref
                          //         .read(fatPercentageViewModelProvider.notifier)
                          //         .updateHeight(value);
                          //   },
                          // ),
                          // const SizedBox(height: 16),

                          // Neck circumference input
                          Text('Neck Circumference ($lengthUnit)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: viewModelState.neckController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.card, // Hintergrundfarbe
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixText: lengthUnit,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            validator: (value) => ref
                                .read(fatPercentageViewModelProvider.notifier)
                                .validateNumber(value),
                            onChanged: (value) {
                              ref
                                  .read(fatPercentageViewModelProvider.notifier)
                                  .updateNeck(value);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Waist circumference input
                          Text('Waist Circumference ($lengthUnit)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: viewModelState.waistController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.card, // Hintergrundfarbe
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixText: lengthUnit,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            validator: (value) => ref
                                .read(fatPercentageViewModelProvider.notifier)
                                .validateNumber(value),
                            onChanged: (value) {
                              ref
                                  .read(fatPercentageViewModelProvider.notifier)
                                  .updateWaist(value);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Hip circumference input (only for women)
                          if (viewModelState.gender == 'Female') ...[
                            Text('Hip Circumference ($lengthUnit)'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: viewModelState.hipController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.card, // Hintergrundfarbe
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixText: lengthUnit,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              validator: (value) => ref
                                  .read(fatPercentageViewModelProvider.notifier)
                                  .validateNumber(value),
                              onChanged: (value) {
                                ref
                                    .read(
                                      fatPercentageViewModelProvider.notifier,
                                    )
                                    .updateHip(value);
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Add this after the gender dropdown
                          if (viewModelState.gender?.toLowerCase() ==
                              'other') ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Calculation formula:'),
                                const Spacer(),
                                ToggleButtons(
                                  isSelected: [
                                    !viewModelState.useFemaleFomula,
                                    viewModelState.useFemaleFomula,
                                  ],
                                  onPressed: (index) {
                                    ref
                                        .read(
                                          fatPercentageViewModelProvider
                                              .notifier,
                                        )
                                        .toggleFormulaType(index == 1);
                                  },
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text('Male'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text('Female'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],

                          // Calculate button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(
                                        fatPercentageViewModelProvider.notifier,
                                      )
                                      .calculateFatPercentage(_formKey);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Error calculating body fat percentage',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.card,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Calculate Body Fat'),
                            ),
                          ),

                          // Display calculated result
                          if (viewModelState.calculatedFatPercentage !=
                              null) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const Text('Calculated Body Fat Percentage'),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${viewModelState.calculatedFatPercentage!.toStringAsFixed(1)}%',
                                  ),
                                  const SizedBox(height: 16),
                                  // Add a save button below the result
                                  ElevatedButton(
                                    onPressed: () {
                                      final fatPercentage = ref
                                          .read(
                                            fatPercentageViewModelProvider
                                                .notifier,
                                          )
                                          .saveFatPercentage();
                                      Navigator.pop(context, fatPercentage);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.card,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('Use This Result'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
