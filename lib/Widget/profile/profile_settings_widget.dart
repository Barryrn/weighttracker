import 'package:flutter/material.dart';
import '../../View/profile_settings_page_view.dart';

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
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.person_outline, color: Colors.black54),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),

      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to the profile settings page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
        );
      },
    );
  }
}
