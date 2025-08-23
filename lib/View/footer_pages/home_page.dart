import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/View/image_comparison_view%20copy.dart';
import 'package:weigthtracker/View/image_comparison_view.dart';
import 'package:weigthtracker/Widget/goals/energy_expenditure_widget.dart';
import 'package:weigthtracker/Widget/goals/weight_progress_widget_copy.dart';
import 'package:weigthtracker/Widget/more/profile/profile_settings_widget.dart';
import 'package:weigthtracker/Widget/tdee/weight_change_tdee_goal_widget.dart';
import 'package:weigthtracker/Widget/tdee/weight_change_tdee_widget.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/widget/goals/weight_progress_widget.dart';
import '../main_container.dart';
import '../../Widget/footer.dart';
import '../../l10n/app_localizations.dart';

/// Content-only version of HomePage for use in PageView
///
/// This widget contains only the page content without footer,
/// designed to be used within MainContainer's PageView.
class HomePageContent extends StatelessWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside of text fields
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.homePage,
            style: AppTypography.headline2(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.textTertiary),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.textPrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background2,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                WeightProgressWidget(),
                const SizedBox(height: 24),
                EnergyExpenditureWidget(),
                const SizedBox(height: 24),
                ImageComparisonView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Original HomePage that now uses MainContainer
///
/// This maintains backward compatibility while implementing
/// the new static footer navigation system.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainContainer();
  }
}
