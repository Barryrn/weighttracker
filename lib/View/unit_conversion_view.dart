import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/Widget/unit_conversion_widget.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Conversion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [UnitConversionWidget()]),
      ),
    );
  }
}
