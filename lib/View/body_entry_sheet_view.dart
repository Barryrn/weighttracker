import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/Widget/body_entry/calorie_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/fat_percentage_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/image_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/note_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/save_button_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/tag_entry_widget.dart';
import 'package:weigthtracker/Widget/body_entry/delete_button_entry_widget.dart';
import '../Widget/body_entry/date_time_entry_widget.dart';
import '../Widget/body_entry/weight_entry_widget.dart';

class BodyEntrySheet {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Column(
                    children: [
                      // Sticky Header
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Add Weight Entry',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
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
                                  SizedBox(height: 16),
                                  SaveButtonEntryWidget(),
                                  SizedBox(height: 8),
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
}
