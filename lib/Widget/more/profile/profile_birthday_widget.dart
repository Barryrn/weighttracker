import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../../ViewModel/profile_settings_provider.dart';
import 'package:intl/intl.dart';

/// A widget that displays and allows editing of the user's birthday.
///
/// This widget shows the current birthday setting and provides a date picker
/// when tapped to allow the user to select a new birthday.
class ProfileBirthdayWidget extends ConsumerWidget {
  /// Creates a ProfileBirthdayWidget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const ProfileBirthdayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current profile settings from the provider
    final profileSettings = ref.watch(profileSettingsProvider);
    final birthday = profileSettings.birthday;

    // Format the birthday if it exists, otherwise show "Not set"
    final formattedBirthday = birthday != null
        ? DateFormat('MMM d, yyyy').format(birthday)
        : 'Not set';

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
        child: Icon(
          Icons.calendar_today,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        'Birthday',
        style: TextStyle(color: Theme.of(context).colorScheme.textPrimary),
      ),
      subtitle: Text(
        formattedBirthday,
        style: TextStyle(color: Theme.of(context).colorScheme.textPrimary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.textPrimary,
      ),
      onTap: () => _showDatePicker(context, ref),
    );
  }

  /// Shows a date picker dialog to select birthday.
  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          ref.read(profileSettingsProvider).birthday ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primaryLight,
              onPrimary: Theme.of(context).colorScheme.textPrimary,
              onSurface: Theme.of(context).colorScheme.textPrimary,
              surface: Theme.of(context).colorScheme.card,
              background: Theme.of(context).colorScheme.card,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith((states) {
                  // Use error color for cancel button, primary color for OK button
                  if (states.contains(MaterialState.pressed)) {
                    return Theme.of(context).colorScheme.error;
                  }
                  return null; // Use default color from theme
                }),
              ),
            ),
            // Fix: Change DialogTheme to DialogThemeData
            dialogTheme: DialogThemeData(
              // Apply styles to the dialog
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Update the provider with the selected date
      ref.read(profileSettingsProvider.notifier).updateBirthday(picked);
    }
  }
}
