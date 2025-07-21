import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/Widget/body_entry/fat_percentage_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/note_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/tag_entry_widget.dart';
import '../Widget/body_entry/date_time_entry_widget.dart';
import '../Widget/body_entry/weight_entry_widget.dart';

class WeightEntrySheet {
  static Future<void> show({required BuildContext context}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Wrap the Column with SingleChildScrollView to make it scrollable
            child: SingleChildScrollView(
              // Add physics for better scroll behavior
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Make sure the Column doesn't try to be infinite height
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add Weight Entry',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Use the DateTimeEntry widget here
                  const DateTimeEntry(),
                  SizedBox(height: 8),
                  const WeightEntry(),
                  SizedBox(height: 8),
                  const NotesEntry(),
                  SizedBox(height: 8),
                  const TagEntry(),
                  SizedBox(height: 8),
                  const FatPercentageEntry(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
