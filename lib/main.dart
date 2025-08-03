import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/health_provider.dart';
import 'package:weigthtracker/ViewModel/weight_progress_view_model.dart';
import 'package:weigthtracker/theme.dart';
import 'model/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'View/body_entry_sheet_view.dart';
import 'model/body_entry_model.dart';
import 'View/footer_pages/home_page.dart';
import 'model/mock_data_importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  await dbHelper.printDatabasePath();

  // Run the app with ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Listen for when the provider is initialized
    ref.listen<HealthState>(healthStateProvider, (previous, current) {
      // Only run once when the provider becomes available and authorized
      if (current.isAvailable &&
          current.isAuthorized &&
          (previous == null ||
              !previous.isAvailable ||
              !previous.isAuthorized)) {
        ref.read(healthStateProvider.notifier).performTwoWaySync();
        ref.watch(weightProgressProvider);
      }
    });

    return MaterialApp(
      title: 'Weight Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const HomePage(),
    );
  }
}
