import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('TDEE Calculator')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [TDEEWidget()],
          ),
        ),
      ),
    );
  }
}
