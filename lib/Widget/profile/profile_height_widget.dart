import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/profile_settings_provider.dart';

/// A widget that displays and allows editing of the user's height.
///
/// This widget shows the current height setting and provides a dialog
/// when tapped to allow the user to enter a new height.
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
      onTap: () => _showHeightPicker(context, ref),
    );
  }

  /// Shows a dialog to enter height.
  void _showHeightPicker(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController();

    // Pre-fill with existing height if available
    final currentHeight = ref.read(profileSettingsProvider).height;
    if (currentHeight != null) {
      controller.text = currentHeight.toString();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Height (cm)'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Height in centimeters',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                // Update provider with entered height
                if (controller.text.isNotEmpty) {
                  final double? height = double.tryParse(controller.text);
                  if (height != null) {
                    ref
                        .read(profileSettingsProvider.notifier)
                        .updateHeight(height);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }
}
