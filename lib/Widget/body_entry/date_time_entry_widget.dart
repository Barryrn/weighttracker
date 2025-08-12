import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/entry_form_provider.dart';
import '../../model/database_helper.dart';
import 'dart:developer' as developer;

/// A widget that displays the current date and allows the user to select a different date
/// using a calendar picker or arrow buttons for day-by-day navigation.
///
/// This widget shows a modern, minimalist date display with navigation arrows and a dropdown icon.
/// Users can tap the left/right arrows to move backward/forward by one day, or tap the date
/// to open a date picker dialog for selecting any date.
class DateTimeEntry extends ConsumerWidget {
  /// Creates a DateTimeEntry widget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const DateTimeEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current date from the provider
    final bodyEntry = ref.watch(bodyEntryProvider);
    final bodyEntryNotifier = ref.read(bodyEntryProvider.notifier);

    // Format the date for display - using a simpler format that matches the design
    final dateFormat = DateFormat('EEEE, d. MMMM');
    final formattedDate = dateFormat.format(bodyEntry.date);

    // Check if the selected date is today
    final isToday = _isToday(bodyEntry.date);
    final displayText = isToday
        ? 'Heute, ${formattedDate.split(", ")[1]}'
        : formattedDate;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left arrow button to decrease date by one day
              _buildArrowButton(
                context: context,
                icon: Icons.arrow_back_ios_rounded,
                onTap: () =>
                    _changeDate(context, bodyEntry.date, bodyEntryNotifier, -1),
              ),

              // Date display with calendar picker
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () =>
                      _selectDate(context, bodyEntry.date, bodyEntryNotifier),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            displayText,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyLarge(context).copyWith(
                              color: Theme.of(context).colorScheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right arrow button to increase date by one day
              _buildArrowButton(
                context: context,
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () =>
                    _changeDate(context, bodyEntry.date, bodyEntryNotifier, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an arrow button for date navigation
  ///
  /// @param icon The icon to display in the button
  /// @param onTap The callback to execute when the button is tapped
  /// @return A widget representing the arrow button
  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
        ),
      ),
    );
  }

  /// Changes the date by the specified number of days and updates the provider
  /// Also loads any existing entry data for the new date from the database
  ///
  /// @param context The build context
  /// @param currentDate The current date
  /// @param notifier The notifier to update with the new date
  /// @param days The number of days to add (positive) or subtract (negative)
  void _changeDate(
    BuildContext context,
    DateTime currentDate,
    BodyEntryNotifier notifier,
    int days,
  ) async {
    // Preserve the current time when changing the date
    final now = DateTime.now();
    final newDate = DateTime(
      currentDate.add(Duration(days: days)).year,
      currentDate.add(Duration(days: days)).month,
      currentDate.add(Duration(days: days)).day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );

    // Reset the bodyEntryProvider by creating a new instance with only the date
    notifier.reset();
    // Update the date after resetting
    notifier.updateDate(newDate);

    // Load data for this date from the database
    await _loadEntryForDate(newDate, notifier);

    // Show a snackbar to inform the user about the date change
    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Switched to ${DateFormat('EEEE, d. MMMM').format(newDate)}'),
    //       duration: const Duration(seconds: 2),
    //     ),
    //   );
    // }
  }

  /// Opens a date picker dialog and updates the provider with the selected date.
  /// Also loads any existing entry data for the selected date from the database.
  ///
  /// @param context The build context
  /// @param initialDate The initial date to show in the picker
  /// @param notifier The notifier to update with the selected date
  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    BodyEntryNotifier notifier,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primaryLight,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialDate) {
      // Preserve the current time when updating the date
      final now = DateTime.now();
      final newDateWithTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );

      // Reset the bodyEntryProvider by creating a new instance with only the date
      notifier.reset();
      // Update the date after resetting
      notifier.updateDate(newDateWithTime);

      // Load data for this date from the database
      await _loadEntryForDate(newDateWithTime, notifier);

      // Show a snackbar to inform the user about the date change
      // if (context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Switched to ${DateFormat('EEEE, d. MMMM').format(picked)}'),
      //       duration: const Duration(seconds: 2),
      //     ),
      //   );
      // }
    }
  }

  /// Loads entry data for the specified date from the database and updates the provider
  ///
  /// @param date The date to load data for
  /// @param notifier The notifier to update with the loaded data
  Future<void> _loadEntryForDate(
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

  /// Checks if the given date is today.
  ///
  /// @param date The date to check
  /// @return True if the date is today, false otherwise
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
