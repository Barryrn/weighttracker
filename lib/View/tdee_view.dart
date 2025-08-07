import 'package:flutter/material.dart';
import 'package:weigthtracker/theme.dart';
import '../Widget/tdee_widget.dart';
import '../Widget/tdee/weight_change_tdee_widget.dart';

/// A page that displays the TDEE widget.
///
/// This page follows the MVVM pattern by acting as the View that displays
/// the TDEEWidget, which in turn displays data from the ViewModel (TDEENotifier).
class TDEEPage extends StatelessWidget {
  /// Creates a TDEEPage.
  const TDEEPage({Key? key}) : super(key: key);

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
            'TDEE Calculator',
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background2,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [TDEEWidget()],
            ),
          ),
        ),
      ),
    );
  }
}
