import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ViewModel/profile_settings_provider.dart';
import '../Widget/more/profile/profile_birthday_widget.dart';
import '../Widget/more/profile/profile_gender_widget.dart';
import '../Widget/more/profile/profile_height_widget.dart';

/// A page that allows users to enter and edit their profile information
/// including birthday, gender, and height.
///
/// This page follows the MVVM pattern by using a ViewModel (ProfileSettingsProvider)
/// to manage the state and business logic of the profile settings.
class ProfileSettingsPage extends ConsumerWidget {
  /// Creates a ProfileSettingsPage.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile avatar section
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(
                    Icons.person_outline,
                    size: 50,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            // Birthday field - using the extracted widget
            const ProfileBirthdayWidget(),

            // Gender field - using the extracted widget
            const ProfileGenderWidget(),

            // Height field - using the extracted widget
            const ProfileHeightWidget(),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Our BMI calculation is only for persons over 20 years old. The BMI for younger people is measured by a doctor during routine examinations.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
