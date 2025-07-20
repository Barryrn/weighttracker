import 'package:flutter/material.dart';
import 'package:weigthtracker/View/weight_entry_sheet.dart';
import 'package:weigthtracker/Widget/profile/profile_settings_widget.dart';
import '../Widget/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomePage'), centerTitle: true),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                WeightEntrySheet.show(context: context);
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
            ProfileSettingsWidget(),
          ],
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 0, onTap: (index) {}),
    );
  }
}
