import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/widget/goals/weight_goal_widget.dart';
import 'package:weigthtracker/widget/goals/weight_progress_widget.dart';
import 'package:weigthtracker/widget/graphs/progress_graph_widget.dart';
import '../../Widget/footer.dart';
import '../../theme.dart';

/// A page that displays and manages user goals.
///
/// This page follows the MVVM pattern by using providers to access
/// the current state and update it through notifiers.
class ProgressPage extends ConsumerWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress Page',
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
    );
  }
}
