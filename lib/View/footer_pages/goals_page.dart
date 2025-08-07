import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/ViewModel/weight_change_tdee_provider.dart';
import 'package:weigthtracker/Widget/tdee/weight_change_tdee_goal_widget.dart';
import 'package:weigthtracker/Widget/tdee/weight_change_tdee_widget.dart';
import 'package:weigthtracker/Widget/test_widget.dart';
import 'package:weigthtracker/widget/goals/weight_goal_widget.dart';
import 'package:weigthtracker/widget/goals/weight_progress_widget.dart';
import '../../Widget/footer.dart';
import '../../theme.dart';

/// A page that displays and manages user goals.
///
/// This page follows the MVVM pattern by using providers to access
/// the current state and update it through notifiers.
class GoalsPage extends ConsumerWidget {
  const GoalsPage({Key? key}) : super(key: key);

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
            'My Goals',
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
        ),
        backgroundColor: Theme.of(context).colorScheme.background2,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeightGoalWidget(),
              const SizedBox(height: 20),
              WeightChangeGoalTDEEWidget(),

              // WeightChangeTDEEWidget(),
              // const SizedBox(height: 20),
              // WeightLossGoalWidget(),
              // const SizedBox(height: 20),
              // TestWidget(),
              // Additional goal widgets can be added here in the future
            ],
          ),
        ),
        bottomNavigationBar: Footer(currentIndex: 3, onTap: (index) {}),
      ),
    );
  }
}
