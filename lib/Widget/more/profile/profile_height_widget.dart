import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/Widget/test_widget.dart';
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

  /// Shows a dialog with a slider to adjust height.
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
    if (!useMetric && currentHeight != null) {
      currentHeight = currentHeight * cmToInchFactor;
    }

    // Ensure the current height is within our slider range
    currentHeight = currentHeight.clamp(minHeight, maxHeight);

    // Get the screen width to calculate dialog width
    final screenWidth = MediaQuery.of(context).size.width;

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

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.adjustHeight,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    useMetric
                        ? '${currentHeight.toStringAsFixed(2)} cm'
                        : '${(currentHeight / inchesInFoot).floor()}\' ${(currentHeight % inchesInFoot).toStringAsFixed(2)}"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(
                        context,
                      ).colorScheme.primaryLight,
                      thumbColor: Theme.of(context).colorScheme.primaryLight,
                      overlayColor: Theme.of(
                        context,
                      ).colorScheme.primaryLight.withOpacity(0.2),
                      // Make the track thicker for better visibility
                      trackHeight: 6.0,
                    ),
                    child: Slider(
                      value: currentHeight,
                      min: minHeight,
                      max: maxHeight,
                      divisions: ((maxHeight - minHeight) * 2)
                          .round(), // half-step increments
                      onChanged: (value) {
                        setState(() {
                          // round to nearest 0.5 cm or 0.5 inch depending on unit
                          currentHeight = (value * 2).round() / 2;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          useMetric
                              ? '${minHeight.toInt()} cm'
                              : '${(minHeight / inchesInFoot).floor()}\' ${(minHeight % inchesInFoot).round()}"',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.textPrimary,
                              ),
                        ),
                        Text(
                          useMetric
                              ? '${maxHeight.toInt()} cm'
                              : '${(maxHeight / inchesInFoot).floor()}\' ${(maxHeight % inchesInFoot).round()}"',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.textPrimary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
