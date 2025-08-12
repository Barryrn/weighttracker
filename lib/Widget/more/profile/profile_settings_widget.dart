import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:weigthtracker/theme.dart';
import '../../../View/profile_settings_page_view.dart';

/// A widget that displays a profile settings option in the app.
/// When tapped, it navigates to the profile settings page where users
/// can enter their birthday, gender, and height information.
///
/// This widget follows the MVVM pattern by separating the UI (View) from
/// the business logic (ViewModel).
class ProfileSettingsWidget extends StatelessWidget {
  /// Creates a ProfileSettingsWidget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const ProfileSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ), // increases internal height

        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        title: Text(AppLocalizations.of(context)!.profile),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileSettingsPage(),
            ),
          );
        },
      ),
    );
  }
}
