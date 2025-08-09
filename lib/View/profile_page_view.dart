import 'package:flutter/material.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/theme.dart';
import '../Widget/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.headline3(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textTertiary),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            BodyEntrySheet.show(context: context);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Click Me', style: TextStyle(fontSize: 18)),
        ),
      ),
      bottomNavigationBar: Footer(currentIndex: 0, onTap: (index) {}),
    );
  }
}
