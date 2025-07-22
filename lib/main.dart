import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this import
import 'Model/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'View/body_entry_sheet_view.dart';
import 'Model/body_entry_model.dart';
import 'View/footer_pages/home_page.dart';

void main() async {
  // Ensure Flutter is initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseHelper().database;
  await DatabaseHelper().printDatabasePath();

  // Get the database path and print it
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  final directory = await getApplicationDocumentsDirectory();
  print('Database path: ${directory.path}/weight_tracker.db');

  // Wrap the app with ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weight Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
