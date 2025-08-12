import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/Widget/body_entry/calorie_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/fat_percentage_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/image_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/note_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/save_button_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/tag_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/delete_button_entry_widget.dart';
import 'package:weigthtracker/theme.dart';
import '../Widget/body_entry/date_time_entry_widget.dart';
import '../Widget/body_entry/weight_entry_widget.dart';
import '../ViewModel/entry_form_provider.dart';
import '../model/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class BodyEntrySheet {
  static Future<void> show({required BuildContext context}) async {
    // Get the current date and notifier before showing the sheet
    final bodyEntryNotifier = ProviderScope.containerOf(
      context,
    ).read(bodyEntryProvider.notifier);
    final currentDate = DateTime.now(); // This already includes current time

    // Reset the notifier and set the current date with time
    bodyEntryNotifier.reset();
    bodyEntryNotifier.updateDate(currentDate); // Now preserves the current time

    // Load data for the current date
    await _loadEntryForDate(currentDate, bodyEntryNotifier);

    // Show the sheet
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Column(
                    children: [
                      // Sticky Header
                      Container(
                        color: Theme.of(context).colorScheme.card,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Weight Entry',
                              style: AppTypography.headline3(context),
                            ),

                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SizedBox(height: 8),
                                  DateTimeEntry(),
                                  SizedBox(height: 8),
                                  WeightEntry(),
                                  SizedBox(height: 8),
                                  CalorieEntry(),
                                  SizedBox(height: 8),
                                  NotesEntry(),
                                  SizedBox(height: 8),
                                  TagEntry(),
                                  SizedBox(height: 8),
                                  FatPercentageEntry(),
                                  SizedBox(height: 8),
                                  ImageEntry(),
                                  SizedBox(height: 32),
                                  SaveButtonEntryWidget(),
                                  SizedBox(height: 16),
                                  DeleteButtonEntryWidget(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Loads entry data for the specified date from the database and updates the provider
  ///
  /// This method queries the database for an entry matching the given date and
  /// updates the BodyEntryNotifier with all available data fields from the found entry.
  /// If no entry is found for the date, the notifier remains unchanged.
  ///
  /// @param date The date to load data for
  /// @param notifier The notifier to update with the loaded data
  static Future<void> _loadEntryForDate(
    DateTime date,
    BodyEntryNotifier notifier,
  ) async {
    try {
      final dbHelper = DatabaseHelper();
      final entry = await dbHelper.findEntryByDate(date);

      if (entry != null) {
        developer.log(
          'Found entry for ${DateFormat('yyyy-MM-dd').format(date)}',
        );

        // Update all fields in the notifier with the loaded data
        if (entry.weight != null) {
          notifier.updateWeight(
            entry.weight,
            useMetric: true,
          ); // Data is stored in metric units
        }

        if (entry.fatPercentage != null) {
          notifier.updateFatPercentage(entry.fatPercentage);
        }

        if (entry.neckCircumference != null) {
          notifier.updateNeckCircumference(
            entry.neckCircumference,
            useMetric: true,
          );
        }

        if (entry.waistCircumference != null) {
          notifier.updateWaistCircumference(
            entry.waistCircumference,
            useMetric: true,
          );
        }

        if (entry.hipCircumference != null) {
          notifier.updateHipCircumference(
            entry.hipCircumference,
            useMetric: true,
          );
        }

        if (entry.notes != null) {
          notifier.updateNotes(entry.notes);
        }

        if (entry.tags != null) {
          notifier.updateTags(entry.tags!);
        }

        if (entry.frontImagePath != null) {
          notifier.updateFrontImagePath(entry.frontImagePath);
        }

        if (entry.sideImagePath != null) {
          notifier.updateSideImagePath(entry.sideImagePath);
        }

        if (entry.backImagePath != null) {
          notifier.updateBackImagePath(entry.backImagePath);
        }

        if (entry.calorie != null) {
          notifier.updateCalorie(entry.calorie);
        }

        developer.log(
          'Successfully loaded entry data for ${DateFormat('yyyy-MM-dd').format(date)}',
        );
      } else {
        developer.log(
          'No entry found for ${DateFormat('yyyy-MM-dd').format(date)}',
        );
      }
    } catch (e) {
      developer.log('Error loading entry for date: $e');
    }
  }
}
