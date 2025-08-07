import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/Widget/health_widget.dart';
import 'package:weigthtracker/theme.dart';
import '../ViewModel/health_provider.dart';

/// A widget for displaying and managing health sync settings
class HealthSyncSettings extends ConsumerWidget {
  const HealthSyncSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthStateProvider);
    final healthNotifier = ref.read(healthStateProvider.notifier);

    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('TDEE Calculator'),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [HealthWidget()]),
        ),
      ),
    );
  }
}
