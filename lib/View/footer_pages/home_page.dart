import 'package:flutter/material.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
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
              ElevatedButton(
                onPressed: () {
                  BodyEntrySheet.show(context: context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Click Me', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 0, onTap: (index) {}),
    );
  }
}
