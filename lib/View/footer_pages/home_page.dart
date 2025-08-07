import 'package:flutter/material.dart';
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
import '../../Widget/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Home Page',
            style: AppTypography.headline1(
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
                // const SizedBox(height: 24),
                // WeightProgressWidgetCopy(),
                const SizedBox(height: 24),
                EnergyExpenditureWidget(),
                const SizedBox(height: 24),
                ImageComparisonView(),
                // WeightChangeTDEEWidget(),
                // WeightChangeGoalTDEEWidget(),

                // const SizedBox(height: 24),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const ImageComparisonView(),
                //       ),
                //     );
                //   },
                //   icon: const Icon(Icons.compare),
                //   label: const Text('Compare Progress Pictures'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Theme.of(context).colorScheme.primary,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 16,
                //       vertical: 12,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Footer(currentIndex: 0, onTap: (index) {}),
      ),
    );
  }
}
