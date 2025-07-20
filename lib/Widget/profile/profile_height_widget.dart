import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/profile_settings_provider.dart';

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

    // Format the height if it exists, otherwise show "Not set"
    final formattedHeight = height != null ? '$height cm' : 'Not set';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.height, color: AppColors.primary),
      ),
      title: const Text('Height'),
      subtitle: Text(formattedHeight),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showHeightSlider(context, ref),
    );
  }

  /// Shows a dialog with a slider to adjust height.
  void _showHeightSlider(BuildContext context, WidgetRef ref) {
    // Define height range constants
    const double minHeight = 100.0; // 100 cm
    const double maxHeight = 220.0; // 220 cm

    // Get current height or use default
    double currentHeight = ref.read(profileSettingsProvider).height ?? 170.0;

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
                    screenWidth * 0.1, // 10% padding on each side (80% width)
                vertical: 24.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Adjust Height',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${currentHeight.toStringAsFixed(1)} cm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryLight,
                        inactiveTrackColor: AppColors.primaryVeryLight,
                        thumbColor: AppColors.primaryLight,
                        overlayColor: AppColors.primaryLight.withOpacity(0.2),
                        // Make the track thicker for better visibility
                        trackHeight: 6.0,
                      ),
                      child: Slider(
                        value: currentHeight,
                        min: minHeight,
                        max: maxHeight,
                        divisions:
                            (maxHeight - minHeight).toInt() *
                            2, // 0.5 cm increments
                        onChanged: (value) {
                          setState(() {
                            currentHeight = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${minHeight.toInt()} cm'),
                          Text('${maxHeight.toInt()} cm'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            // Update provider with selected height
                            ref
                                .read(profileSettingsProvider.notifier)
                                .updateHeight(currentHeight);
                            Navigator.pop(context);
                          },
                          child: const Text('SAVE'),
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
