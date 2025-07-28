import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/note_entry_view_model.dart';

/// A widget that allows users to enter notes.
///
/// This widget follows the MVVM pattern by using the noteEntryProvider
/// to access the ViewModel that manages all business logic and state.
class NotesEntry extends ConsumerWidget {
  const NotesEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the note entry data from the ViewModel
    final noteEntryData = ref.watch(noteEntryProvider);
    final viewModel = ref.read(noteEntryProvider.notifier);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Notes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: noteEntryData.notesController,
            onChanged: viewModel.onNotesChanged,
            decoration: InputDecoration(
              hintText: 'Enter your Note',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: InputBorder.none,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
