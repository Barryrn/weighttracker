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
    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'More Settings',
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
      ),
    );
  }
}
