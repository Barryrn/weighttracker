import 'package:flutter/material.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/View/image_comparison_view%20copy.dart';
import 'package:weigthtracker/View/image_comparison_view.dart';
import 'package:weigthtracker/Widget/profile/profile_settings_widget.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/widget/goals/weight_progress_widget.dart';
import '../../Widget/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.primaryVeryLight,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              WeightProgressWidget(),
              const SizedBox(height: 24),
              ImageComparisonViews(),
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
