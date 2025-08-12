import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/delete_entry_view_model.dart';
import 'package:weigthtracker/ViewModel/entry_form_provider.dart';
import 'package:weigthtracker/model/database_helper.dart';
import 'package:weigthtracker/theme.dart';

/// A widget that provides a delete button for body entry data.
///
/// This widget follows the MVVM pattern by using the deleteEntryViewModelProvider
/// to handle the deletion logic and the bodyEntryProvider to access the current date.
class DeleteButtonEntryWidget extends ConsumerWidget {
  const DeleteButtonEntryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyEntry = ref.watch(bodyEntryProvider);
    final deleteViewModel = ref.watch(deleteEntryViewModelProvider);
    final dbHelper = DatabaseHelper();

    // Check if an entry exists for the current date
    return FutureBuilder<bool>(
      future: deleteViewModel.hasEntryForDate(bodyEntry.date),
      builder: (context, snapshot) {
        // If we're still loading or no entry exists, don't show the button
        if (!snapshot.hasData || snapshot.data == false) {
          return const SizedBox.shrink(); // Empty widget
        }

        // If an entry exists, show the delete button
        return SizedBox(
          width: double.infinity, // Makes the button full-width
          child: ElevatedButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldDelete = await _showDeleteConfirmationDialog(context);

              if (shouldDelete && context.mounted) {
                try {
                  // await dbHelper.deleteAllBodyEntries();

                  // Delete the entry
                  final success = await deleteViewModel.deleteEntryForDate(
                    bodyEntry.date,
                  );
                  await dbHelper.deleteAllBodyEntries();

                  if (context.mounted) {
                    if (success) {
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Entry deleted successfully',
                            style: AppTypography.bodyMedium(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                          duration: Duration(seconds: 1),
                        ),
                      );

                      // Close the bottom sheet
                      Navigator.pop(context);
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete entry',
                            style: AppTypography.bodyMedium(
                              context,
                            ).copyWith(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // Show error message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error deleting entry: ${e.toString()}',
                          style: AppTypography.bodyMedium(
                            context,
                          ).copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .error, // Use theme error color instead of hardcoded red
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTypography.subtitle1(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog asking the user if they want to delete the entry
  /// @param context The build context
  /// @return Future<bool> Whether the user confirmed the deletion
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Delete Entry',
                style: AppTypography.subtitle1(context),
              ),
              content: Text(
                'Are you sure you want to delete this entry? This action cannot be undone.',
                style: AppTypography.bodyMedium(context),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: AppTypography.buttonText(context),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(
                    'Delete',
                    style: AppTypography.buttonText(
                      context,
                    ).copyWith(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }
}
