import 'package:flutter/material.dart';
import 'package:weigthtracker/View/tdee_view.dart';
import 'package:weigthtracker/theme.dart';
import '../../../View/tag_settings_view.dart';
import 'package:heroicons/heroicons.dart';

/// A widget that displays a card for navigating to the TDEE calculator page.
///
/// This widget follows the MVVM pattern by acting as part of the View layer
/// that provides navigation to the TDEE calculator page.
class TDEESettingsWidget extends StatelessWidget {
  /// Creates a TDEESettingsWidget.
  const TDEESettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.card,
        borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: HeroIcon(
            HeroIcons.fire,
            style: HeroIconStyle.solid,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text('TDEE Calculator (Calories)'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TDEEPage()),
          );
        },
      ),
    );
  }
}
