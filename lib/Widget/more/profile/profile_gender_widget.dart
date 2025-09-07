import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
    final storedGender = profileSettings.gender;
    
    // Convert stored gender to localized display string
    String displayGender;
    if (storedGender == 'Male') {
      displayGender = AppLocalizations.of(context)!.male;
    } else if (storedGender == 'Female') {
      displayGender = AppLocalizations.of(context)!.female;
    } else {
      displayGender = AppLocalizations.of(context)!.notSet;
    }

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
        AppLocalizations.of(context)!.gender,
        style: TextStyle(color: Theme.of(context).colorScheme.textPrimary),
      ),
      subtitle: Text(
        displayGender,
        style: TextStyle(color: Theme.of(context).colorScheme.textPrimary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.textPrimary,
      ),
      onTap: () => _showGenderPicker(context, ref),
    );
  }

  /// Shows a dialog to select gender.
  void _showGenderPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.selectGender,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showGenderInfoDialog(context),
                icon: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                tooltip: 'Information',
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: 1000, // Breitere Dialogbox
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGenderOption(
                  context: context,
                  ref: ref,
                  label: AppLocalizations.of(context)!.male,
                  icon: Icons.male,
                  localizedGender: AppLocalizations.of(context)!.male,
                ),
                const SizedBox(height: 12),
                _buildGenderOption(
                  context: context,
                  ref: ref,
                  label: AppLocalizations.of(context)!.female,
                  icon: Icons.female,
                  localizedGender: AppLocalizations.of(context)!.female,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Converts localized gender string to standard storage value
  String _getStandardGenderValue(BuildContext context, String localizedGender) {
    if (localizedGender == AppLocalizations.of(context)!.male) {
      return 'Male';
    } else if (localizedGender == AppLocalizations.of(context)!.female) {
      return 'Female';
    }
    return localizedGender; // fallback
  }

  /// Shows an information dialog explaining why only two genders are available.
  void _showGenderInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.genderSelection,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.textPrimary,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Text(
            AppLocalizations.of(context)!.genderSelectionInfo,
            style: TextStyle(
              color: Theme.of(context).colorScheme.textPrimary,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenderOption({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required String localizedGender,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        final standardGenderValue = _getStandardGenderValue(context, localizedGender);
        ref.read(profileSettingsProvider.notifier).updateGender(standardGenderValue);
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
