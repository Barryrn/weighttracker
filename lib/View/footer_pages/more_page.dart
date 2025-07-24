import 'package:flutter/material.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/Widget/profile/profile_settings_widget.dart';
import '../../Widget/footer.dart';

class MorePage extends StatelessWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MorePage'),
        automaticallyImplyLeading: false, // This removes the back arrow
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Column(children: [ProfileSettingsWidget()])),
      ),
      bottomNavigationBar: Footer(currentIndex: 3, onTap: (index) {}),
    );
  }
}
