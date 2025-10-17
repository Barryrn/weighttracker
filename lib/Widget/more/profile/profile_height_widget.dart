import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../../ViewModel/profile_settings_provider.dart';

/// Conversion constants for height units
const double cmToInchFactor = 0.393701; // 1 cm = 0.393701 inches
const double inchToCmFactor = 2.54; // 1 inch = 2.54 cm
const int inchesInFoot = 12; // 1 foot = 12 inches

/// A widget that displays and allows editing of the user's height.
///
/// This widget shows the current height setting and provides a slider
/// when tapped to allow the user to adjust their height.
class ProfileHeightWidget extends ConsumerWidget {
  /// Creates a ProfileHeightWidget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const ProfileHeightWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current profile settings from the provider
    final profileSettings = ref.watch(profileSettingsProvider);
    final height = profileSettings.height;
    final useMetric = ref.watch(
      heightUnitProvider,
    ); // true = cm, false = inches

    // Format the height based on the selected unit
    String formattedHeight = 'Not set';
    if (height != null) {
      if (useMetric) {
        formattedHeight = '${height.toStringAsFixed(2)} cm';
      } else {
        // Convert cm to inches
        final heightInInches = height * cmToInchFactor;
        // Convert to feet and inches
        final feet = (heightInInches / inchesInFoot).floor();
        final inches = heightInInches % inchesInFoot;
        // Show decimal inches instead of rounding
        formattedHeight = "$feet' ${inches.toStringAsFixed(2)}\"";
      }
    }

    return Column(
      children: [
        // TestWidget(),
        ListTile(
          tileColor: Theme.of(context).colorScheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.height,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(AppLocalizations.of(context)!.height),
          subtitle: Text(formattedHeight),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showHeightSlider(context, ref),
        ),
      ],
    );
  }

  /// Shows a dialog with a wheel selector to adjust height.
  void _showHeightSlider(BuildContext context, WidgetRef ref) {
    final useMetric = ref.read(heightUnitProvider); // true = cm, false = inches

    // Define height range constants based on the unit
    double minHeight, maxHeight;
    if (useMetric) {
      minHeight = 100.0; // 100 cm
      maxHeight = 220.0; // 220 cm
    } else {
      minHeight = 48.0; // 4ft (48 inches)
      maxHeight = 89.0; // 7ft 5in (89 inches)
    }

    // Get current height or use default, converting if necessary
    double currentHeight = ref.read(profileSettingsProvider).height ?? 170.0;

    // Convert to inches if using imperial
    if (!useMetric) {
      currentHeight = currentHeight * cmToInchFactor;
    }

    // Ensure the current height is within our slider range
    currentHeight = currentHeight.clamp(minHeight, maxHeight);

    // Create list of height values (0.5 increments)
    final List<double> heightValues = [];
    for (double i = minHeight; i <= maxHeight; i += 0.5) {
      heightValues.add(i);
    }

    // Find initial index
    int initialIndex = heightValues.indexWhere(
      (h) => (h - currentHeight).abs() < 0.25,
    );
    if (initialIndex == -1) initialIndex = (heightValues.length / 2).floor();

    // Get the screen width to calculate dialog width
    final screenWidth = MediaQuery.of(context).size.width;

    // Controller for the wheel
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: initialIndex);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              // Make the dialog wider by using a percentage of screen width
              insetPadding: EdgeInsets.symmetric(
                horizontal:
                    screenWidth * 0.05, // 10% padding on each side (80% width)
                vertical: 24.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.adjustHeight,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      useMetric
                          ? '${currentHeight.toStringAsFixed(1)} cm'
                          : '${(currentHeight / inchesInFoot).floor()}\' ${(currentHeight % inchesInFoot).toStringAsFixed(1)}"',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Wheel selector
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: ListWheelScrollView.useDelegate(
                        controller: scrollController,
                        itemExtent: 50,
                        perspective: 0.003,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            currentHeight = heightValues[index];
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: heightValues.length,
                          builder: (context, index) {
                            final height = heightValues[index];
                            final isSelected = (height - currentHeight).abs() < 0.25;

                            return Center(
                              child: Text(
                                useMetric
                                    ? '${height.toStringAsFixed(1)} cm'
                                    : '${(height / inchesInFoot).floor()}\' ${(height % inchesInFoot).toStringAsFixed(1)}"',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.textPrimary.withValues(alpha: 0.5),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: isSelected ? 20 : 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            scrollController.dispose();
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            // Convert back to cm if using inches before saving
                            double heightToSave = currentHeight;
                            if (!useMetric) {
                              heightToSave = currentHeight * inchToCmFactor;
                            }

                            // Update provider with selected height
                            ref
                                .read(profileSettingsProvider.notifier)
                                .updateHeight(heightToSave);

                            scrollController.dispose();
                            Navigator.pop(context);
                          },
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
