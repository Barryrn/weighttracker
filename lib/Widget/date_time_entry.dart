import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../ViewModel/entry_form_provider.dart';

/// A widget that displays the current date and allows the user to select a different date
/// using a calendar picker. The selected date is saved to the bodyEntryProvider.
///
/// This widget shows a modern, minimalist date display with a dropdown icon.
/// When tapped, it opens a date picker dialog where the user can select a new date.
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
    final displayText = isToday ? 'Heute, ${formattedDate.split(", ")[1]}' : formattedDate;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _selectDate(context, bodyEntry.date, bodyEntryNotifier),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Opens a date picker dialog and updates the provider with the selected date.
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
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialDate) {
      notifier.updateDate(picked);
    }
  }

  /// Checks if the given date is today.
  ///
  /// @param date The date to check
  /// @return True if the date is today, false otherwise
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}