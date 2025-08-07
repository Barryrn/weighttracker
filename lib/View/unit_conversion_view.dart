import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/Widget/unit_conversion_widget.dart';
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
class UnitConversionSettingsPage extends ConsumerWidget {
  /// Creates a UnitConversionSettingsPage.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const UnitConversionSettingsPage({Key? key}) : super(key: key);

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
          title: Text(
            'Unit Conversion',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.textTertiary,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.textPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background2,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [UnitConversionWidget()]),
          ),
        ),
      ),
    );
  }
}
