import 'package:flutter/material.dart';
import 'Model/database_helper.dart';
import 'package:path_provider/path_provider.dart'; // Add this import

void main() async {
  // Ensure Flutter is initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database
  await DatabaseHelper().database;
  
  // Get the database path and print it
  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  final directory = await getApplicationDocumentsDirectory();
  print('Database path: ${directory.path}/weight_tracker.db');
  
  runApp(MyApp());
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

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weight Tracker')),
      body: Center(child: Text('Hello, Flutter!')),
    );
  }
}
