import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/body_entry.dart';
import 'dart:developer' as developer;

class BodyEntryNotifier extends StateNotifier<BodyEntry> {
  BodyEntryNotifier() : super(BodyEntry(date: DateTime.now()));

  /// Logs the current state of the BodyEntry
  /// This is called after each state update to help with debugging
  void _logState() {
    developer.log('===== BodyEntry Provider State =====');
    developer.log('Date: ${state.date}');
    developer.log('Weight: ${state.weight}');
    developer.log('Fat Percentage: ${state.fatPercentage}');
    developer.log('Neck Circumference: ${state.neckCircumference}');
    developer.log('Waist Circumference: ${state.waistCircumference}');
    developer.log('Hip Circumference: ${state.hipCircumference}');
    developer.log('Tags: ${state.tags}');
    developer.log('Notes: ${state.notes}');
    developer.log('Image Path: ${state.imagePath}');
    developer.log('===================================');
  }

  void updateWeight(double? weight) {
    state = state.copyWith(weight: weight);
    _logState();
  }

  void updateDate(DateTime date) {
    state = state.copyWith(date: date);
    _logState();
  }

  void updateFatPercentage(double? fatPercentage) {
    state = state.copyWith(fatPercentage: fatPercentage);
    _logState();
  }

  void updateNeckCircumference(double? neckCircumference) {
    state = state.copyWith(neckCircumference: neckCircumference);
    _logState();
  }

  void updateWaistCircumference(double? waistCircumference) {
    state = state.copyWith(waistCircumference: waistCircumference);
    _logState();
  }

  void updateHipCircumference(double? hipCircumference) {
    state = state.copyWith(hipCircumference: hipCircumference);
    _logState();
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
    _logState();
  }

  void updateNotes(String? notes) {
    state = state.copyWith(notes: notes);
    _logState();
  }

  void reset() {
    state = BodyEntry(date: DateTime.now(), tags: []);
    _logState();
  }
}

final bodyEntryProvider = StateNotifierProvider<BodyEntryNotifier, BodyEntry>((ref) {
  return BodyEntryNotifier();
});
