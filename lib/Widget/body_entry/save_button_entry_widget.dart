import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/health_provider.dart';
import 'package:weigthtracker/theme.dart';
import 'package:weigthtracker/model/database_helper.dart';
import 'package:weigthtracker/ViewModel/entry_form_provider.dart';
import 'package:weigthtracker/provider/database_change_provider.dart';
import 'package:weigthtracker/ViewModel/date_line_chart.dart'; // Add this import

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
          print('Button pressed');

          // Get the current body entry from the provider
          final bodyEntry = ref.read(bodyEntryProvider);
          
          // Validate that we have some data to save
          if (bodyEntry.weight == null && 
              bodyEntry.fatPercentage == null && 
              bodyEntry.calorie == null &&
              (bodyEntry.notes == null || bodyEntry.notes!.isEmpty)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Please enter at least one measurement before saving.',
                    style: AppTypography.bodyMedium(context).copyWith(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          // Create database helper instance
          final dbHelper = DatabaseHelper();

          try {
            // Mark this as a manual entry before saving
            final manualEntry = bodyEntry.copyWith(isManualEntry: true);
            
            // Save the entry to the database and check result
            final result = await dbHelper.insertBodyEntry(manualEntry);
            
            // Verify the save was successful (result should be > 0)
            if (result <= 0) {
              throw Exception('Failed to save entry - no rows affected');
            }
            
            // Print all entries for debugging
            await dbHelper.printAllBodyEntries();
            
            // After successful save, verify the data exists
            final savedEntry = await dbHelper.findEntryByDate(bodyEntry.date);
            if (savedEntry == null) {
              throw Exception('Entry was not found after save operation');
            }
            print('Verified saved entry: $savedEntry');
            
            // Perform health sync
            // The health service will now respect manual entries and not overwrite them
            await ref.read(healthStateProvider.notifier).performTwoWaySync();

            // Notify that database has changed
            ref.read(databaseChangeProvider.notifier).notifyDatabaseChanged();

            // Reload the line chart data with the current time period
            final currentTimePeriod = ref.read(selectedTimePeriodLineChartProvider);
            await ref.read(timeAggregationProvider.notifier).aggregateData(currentTimePeriod);

            // Show success message only after confirming save
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.entrySavedSuccessfully,
                    style: AppTypography.bodyMedium(context).copyWith(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.success,
                  duration: Duration(seconds: 1),
                ),
              );

              // Close the bottom sheet
              Navigator.pop(context);
            }
          } catch (e) {
            print('Error saving entry: $e');
            
            // Show specific error message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to save entry: ${e.toString()}',
                    style: AppTypography.bodyMedium(context).copyWith(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary, // Blue background from your theme
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.save,
          style: AppTypography.subtitle1(
            context,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

