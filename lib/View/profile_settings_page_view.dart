import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
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
    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profil',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: AppColors.background2,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile avatar section
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.card,
                    child: const Icon(
                      Icons.person_outline,
                      size: 50,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Birthday field - using the extracted widget
              ProfileBirthdayWidget(),
              const SizedBox(height: 16),

              // Gender field - using the extracted widget
              ProfileGenderWidget(),
              const SizedBox(height: 16),

              // Height field - using the extracted widget
              const ProfileHeightWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
