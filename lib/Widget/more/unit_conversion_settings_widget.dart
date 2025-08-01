import 'package:flutter/material.dart';
import 'package:weigthtracker/View/unit_conversion_view.dart';
import 'package:weigthtracker/theme.dart';
import '../../../View/tag_settings_view.dart';
import 'package:heroicons/heroicons.dart';

/// A widget that displays a tag settings option in the app.
/// When tapped, it navigates to the tag settings page where users
/// can view and manage all tags in the database.
///
/// This widget follows the MVVM pattern by separating the UI (View) from
/// the business logic (ViewModel).
class UnitConversionSettingsWidget extends StatelessWidget {
  /// Creates a UnitConversionSettingsWidget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const UnitConversionSettingsWidget({Key? key}) : super(key: key);

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
        child: const HeroIcon(
          HeroIcons.scale,
          style: HeroIconStyle.outline,
          size: 30,
        ),
      ),
      title: const Text(
        'Unit Conversion',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),

      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to the tag settings page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UnitConversionSettingsPage(),
          ),
        );
      },
    );
  }
}
