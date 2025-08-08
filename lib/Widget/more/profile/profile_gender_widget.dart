import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../../ViewModel/profile_settings_provider.dart';

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
      tileColor: Theme.of(context).colorScheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        'Gender',
        style: TextStyle(color: Theme.of(context).colorScheme.textPrimary),
      ),
      subtitle: Text(
        gender,
        style: TextStyle(color: Theme.of(context).colorScheme.textPrimary),
      ),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.textPrimary),
      onTap: () => _showGenderPicker(context, ref),
    );
  }

  /// Shows a dialog to select gender.
  void _showGenderPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Gender',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.textPrimary,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: SizedBox(
            width: 1000, // Breitere Dialogbox
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGenderOption(
                  context: context,
                  ref: ref,
                  label: 'Male',
                  icon: Icons.male,
                  genderValue: 'Male',
                ),
                const SizedBox(height: 12),
                _buildGenderOption(
                  context: context,
                  ref: ref,
                  label: 'Female',
                  icon: Icons.female,
                  genderValue: 'Female',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderOption({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required String genderValue,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        ref.read(profileSettingsProvider.notifier).updateGender(genderValue);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Text(
              label, 
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
