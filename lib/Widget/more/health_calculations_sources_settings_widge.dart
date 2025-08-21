import 'package:flutter/material.dart';
import 'package:weigthtracker/View/health_calculations_sources_view.dart';
import '../../l10n/app_localizations.dart';
import 'package:weigthtracker/theme.dart';
import 'package:heroicons/heroicons.dart';

/// A widget that displays a health calculations settings option in the app.
/// When tapped, it navigates to the health calculations page where users
/// can view BMI, TDEE, and other health-related calculations with sources.
///
/// This widget follows the MVVM pattern by separating the UI (View) from
/// the business logic (ViewModel).
class HealthCalculationsSourcesSettingsWidget extends StatelessWidget {
  /// Creates a HealthCalculationsSourcesSettingsWidget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const HealthCalculationsSourcesSettingsWidget({Key? key}) : super(key: key);

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
          child: HeroIcon(
            HeroIcons.calculator,
            style: HeroIconStyle.solid,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text('Health Calculations & Sources'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HealthCalculationsSourcesView(),
            ),
          );
        },
      ),
    );
  }
}
