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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'More Settingdss',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background2,
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
              //     backgroundColor: AppColors.primary,
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
    );
  }
}
