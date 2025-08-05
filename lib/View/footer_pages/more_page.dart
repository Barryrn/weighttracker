import 'package:flutter/material.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/Widget/more/health_settings_widget.dart';
import 'package:weigthtracker/Widget/more/profile/profile_settings_widget.dart';
import 'package:weigthtracker/Widget/more/tag_settings_widget.dart';
import 'package:weigthtracker/Widget/more/tdee_settings_widget.dart';
import 'package:weigthtracker/Widget/more/unit_conversion_settings_widget.dart';
import 'package:weigthtracker/Widget/test_widget.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/view/image_comparison_view.dart';
import '../../Widget/footer.dart';

class MorePage extends StatelessWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More Settings'),
        automaticallyImplyLeading: false, // This removes the back arrow
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              ProfileSettingsWidget(),
              const SizedBox(height: 16),
              TagsSettingsWidget(),
              const SizedBox(height: 16),
              UnitConversionSettingsWidget(),
              const SizedBox(height: 16),
              const TDEESettingsWidget(),
              const SizedBox(height: 16),
              const HealthSettingsWidget(),

              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => const ImageComparisonView(),
              //       ),
              //     );
              //   },
              //   child: const Text('Image comparison view'),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 4, onTap: (index) {}),
    );
  }
}
