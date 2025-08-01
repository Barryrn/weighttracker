import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/model/database_helper.dart';
import 'package:weigthtracker/ViewModel/entry_form_provider.dart';
import 'package:weigthtracker/provider/database_change_provider.dart';

/// A widget that provides a save button for body entry data.
///
/// This widget follows the MVVM pattern by using the bodyEntryProvider to access
/// the current state and saving it to the database through the DatabaseHelper.
class SaveButtonEntryWidget extends ConsumerWidget {
  const SaveButtonEntryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity, // Makes the button full-width
      child: ElevatedButton(
        onPressed: () async {
          print('Button pressed'); // add this line

          // Get the current body entry from the provider
          final bodyEntry = ref.read(bodyEntryProvider);

          // Create database helper instance
          final dbHelper = DatabaseHelper();

          try {
            // Save the entry to the database
            await dbHelper.insertBodyEntry(bodyEntry);
            await dbHelper.printAllBodyEntries();
            print('Test');
            
            // Notify that database has changed
            print('Notifying database change to update TDEE calculation');
            ref.read(databaseChangeProvider.notifier).notifyDatabaseChanged();
            print('Database change notification sent');

            // Show success message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entry saved successfully')),
              );

              // Close the bottom sheet
              Navigator.pop(context);
            }
          } catch (e) {
            // Show error message if save fails
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save entry: ${e.toString()}'),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Blue background from your theme
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
