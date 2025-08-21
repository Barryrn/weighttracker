import 'package:flutter/material.dart';
import '../Widget/health_calculations_sources_widge.dart';
import '../theme.dart';

/// A view that displays comprehensive health calculations and their sources
///
/// This view presents educational content about BMI, TDEE, and caloric adjustments
/// with step-by-step formulas and professional sources for credibility.
class HealthCalculationsSourcesView extends StatelessWidget {
  const HealthCalculationsSourcesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background1,
      appBar: AppBar(
        title: Text(
          'Calculations & Sources',
          style: AppTypography.headline3(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const HealthCalculationsSourcesWidget(
        // In a real app, these values would come from user profile/settings
      ),
    );
  }
}
