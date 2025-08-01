import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'entry_form_provider.dart';

/// A data class that holds all the note entry information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (NotesEntryWidget).
class NoteEntryData {
  final String? notes;
  final TextEditingController notesController;

  NoteEntryData({this.notes, required this.notesController});
}

/// A ViewModel that manages note entry information.
///
/// This class follows the MVVM pattern by processing data from the bodyEntryProvider
/// and transforming it into a format that's ready for display in the View.
class NoteEntryViewModel extends StateNotifier<NoteEntryData> {
  NoteEntryViewModel(this.ref)
    : super(
        NoteEntryData(notes: null, notesController: TextEditingController()),
      ) {
    _initializeData();

    // Listen for changes in the bodyEntryProvider that affect notes
    ref.listen(
      bodyEntryProvider,
      (_, next) => _updateData(
        NoteEntryData(
          notes: next.notes,
          notesController: state.notesController,
        ),
      ),
    );
  }

  final Ref ref;

  @override
  void dispose() {
    state.notesController.dispose();
    super.dispose();
  }

  /// Logs the current state of the note entry
  void _logState() {
    developer.log('===== Note Entry ViewModel State =====');
    developer.log('Notes: ${state.notes}');
    developer.log('===================================');
  }

  /// Initializes the data with current values from bodyEntryProvider
  void _initializeData() {
    final bodyEntry = ref.read(bodyEntryProvider);
    final currentNotes = bodyEntry.notes;

    // Initialize notes controller
    state.notesController.text = currentNotes ?? '';

    // Update state
    state = NoteEntryData(
      notes: currentNotes,
      notesController: state.notesController,
    );

    _logState();
  }

  /// Updates the data when the underlying bodyEntry changes
  void _updateData(NoteEntryData bodyEntry) {
    final currentNotes = bodyEntry.notes;

    // Only update controller if the notes have changed
    if (currentNotes != state.notesController.text) {
      state.notesController.text = currentNotes ?? '';
    }

    // Update state
    state = NoteEntryData(
      notes: currentNotes,
      notesController: state.notesController,
    );

    _logState();
  }

  /// Handles note text changes
  void onNotesChanged(String value) {
    final notifier = ref.read(bodyEntryProvider.notifier);

    if (value.isEmpty) {
      notifier.updateNotes(null);
      return;
    }

    try {
      notifier.updateNotes(value);
    } catch (_) {
      // silently ignore
    }
  }
}

/// A provider for accessing the NoteEntryViewModel.
///
/// This provider makes the NoteEntryViewModel available to widgets
/// that need to display and modify note entry information.
final noteEntryProvider =
    StateNotifierProvider<NoteEntryViewModel, NoteEntryData>(
      (ref) => NoteEntryViewModel(ref),
    );
