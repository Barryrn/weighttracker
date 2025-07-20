import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/profile_settings_provider.dart';

/// A widget that displays and allows editing of the user's gender.
///
/// This widget shows the current gender setting and provides a dialog
/// when tapped to allow the user to select a new gender.
class ProfileGenderWidget extends ConsumerWidget {
  /// Creates a ProfileGenderWidget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const ProfileGenderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current profile settings from the provider
    final profileSettings = ref.watch(profileSettingsProvider);
    final gender = profileSettings.gender ?? 'Not set';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.person, color: AppColors.primary),
      ),
      title: const Text('Gender'),
      subtitle: Text(gender),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showGenderPicker(context, ref),
    );
  }

  /// Shows a dialog to select gender.
  void _showGenderPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Male'),
                onTap: () {
                  // Update provider with selected gender
                  ref
                      .read(profileSettingsProvider.notifier)
                      .updateGender('Male');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Female'),
                onTap: () {
                  // Update provider with selected gender
                  ref
                      .read(profileSettingsProvider.notifier)
                      .updateGender('Female');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Other'),
                onTap: () {
                  // Update provider with selected gender
                  ref
                      .read(profileSettingsProvider.notifier)
                      .updateGender('Other');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
