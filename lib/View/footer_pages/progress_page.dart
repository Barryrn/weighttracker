import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/widget/goals/weight_goal_widget.dart';
import 'package:weigthtracker/widget/goals/weight_progress_widget.dart';
import 'package:weigthtracker/widget/graphs/progress_graph_widget.dart';
import '../../Widget/footer.dart';
import '../../theme.dart';

/// Content-only version of ProgressPage for use in PageView
///
/// This widget contains only the page content without footer,
/// designed to be used within MainContainer's PageView.
class ProgressPageContent extends ConsumerWidget {
  const ProgressPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      // Dismiss keyboard when tapping outside of text fields
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.progressPage,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Progress graph widget for displaying user progress
              ProgressGraphWidget(),
              SizedBox(height: 30),
              // Additional progress widgets can be added here in the future
            ],
          ),
        ),
      ),
    );
  }
}

/// Original ProgressPage that displays and manages user progress
///
/// This page follows the MVVM pattern by using providers to access
/// the current state and update it through notifiers.
class ProgressPage extends ConsumerWidget {
  const ProgressPage({Key? key}) : super(key: key);

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
            AppLocalizations.of(context)!.progressPage,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Replace the separate widgets with the new toggle widget
              ProgressGraphWidget(),
              SizedBox(height: 30),

              // Additional goal widgets can be added here in the future
            ],
          ),
        ),
        bottomNavigationBar: Footer(currentIndex: 1, onTap: (index) {}),
      ),
    );
  }
}
