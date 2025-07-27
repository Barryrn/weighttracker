import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/body_entry_model.dart';
import 'dart:developer' as developer;
import 'unit_conversion_provider.dart';

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
    developer.log('Front Image Path: ${state.frontImagePath}');
    developer.log('Side Image Path: ${state.sideImagePath}');
    developer.log('Back Image Path: ${state.backImagePath}');
    developer.log('===================================');
  }

  /// Updates the weight value, converting from display units to standard units (kg)
  /// @param weight The weight value in the current display unit (kg or lb)
  /// @param useMetric Whether the input is in metric units
  void updateWeight(double? weight, {required bool useMetric}) {
    if (weight == null) {
      state = state.copyWith(weight: null);
    } else {
      // Convert to standard unit (kg) if needed
      final standardWeight = useMetric ? weight : weight * 0.45359237;
      state = state.copyWith(weight: standardWeight);
    }
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

  /// Updates the neck circumference, converting from display units to standard units (cm)
  /// @param neckCircumference The neck circumference in the current display unit (cm or inches)
  /// @param useMetric Whether the input is in metric units
  void updateNeckCircumference(
    double? neckCircumference, {
    required bool useMetric,
  }) {
    if (neckCircumference == null) {
      state = state.copyWith(neckCircumference: null);
    } else {
      // Convert to standard unit (cm) if needed
      final standardValue = useMetric
          ? neckCircumference
          : neckCircumference * 2.54;
      state = state.copyWith(neckCircumference: standardValue);
    }
    _logState();
  }

  /// Updates the waist circumference, converting from display units to standard units (cm)
  /// @param waistCircumference The waist circumference in the current display unit (cm or inches)
  /// @param useMetric Whether the input is in metric units
  void updateWaistCircumference(
    double? waistCircumference, {
    required bool useMetric,
  }) {
    if (waistCircumference == null) {
      state = state.copyWith(waistCircumference: null);
    } else {
      // Convert to standard unit (cm) if needed
      final standardValue = useMetric
          ? waistCircumference
          : waistCircumference * 2.54;
      state = state.copyWith(waistCircumference: standardValue);
    }
    _logState();
  }

  /// Updates the hip circumference, converting from display units to standard units (cm)
  /// @param hipCircumference The hip circumference in the current display unit (cm or inches)
  /// @param useMetric Whether the input is in metric units
  void updateHipCircumference(
    double? hipCircumference, {
    required bool useMetric,
  }) {
    if (hipCircumference == null) {
      state = state.copyWith(hipCircumference: null);
    } else {
      // Convert to standard unit (cm) if needed
      final standardValue = useMetric
          ? hipCircumference
          : hipCircumference * 2.54;
      state = state.copyWith(hipCircumference: standardValue);
    }
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

  /// Updates the front image path in the BodyEntry state
  /// @param imagePath The path to the front image file
  void updateFrontImagePath(String? imagePath) {
    state = state.copyWith(
      frontImagePath: imagePath,
      setFrontImagePathNull: imagePath == null,
    );
    _logState();
  }

  /// Updates the side image path in the BodyEntry state
  /// @param imagePath The path to the side image file
  void updateSideImagePath(String? imagePath) {
    state = state.copyWith(
      sideImagePath: imagePath,
      setSideImagePathNull: imagePath == null,
    );
    _logState();
  }

  /// Updates the back image path in the BodyEntry state
  /// @param imagePath The path to the back image file
  void updateBackImagePath(String? imagePath) {
    state = state.copyWith(
      backImagePath: imagePath,
      setBackImagePathNull: imagePath == null,
    );
    _logState();
  }

  void reset() {
    // Preserve the current notes and tags
    final currentNotes = state.notes;
    final currentTags = state.tags;
    
    // Reset to a new BodyEntry with only the preserved fields
    state = BodyEntry(
      date: DateTime.now(),
      notes: currentNotes,
      tags: currentTags,
    );
    _logState();
  }
}

final bodyEntryProvider = StateNotifierProvider<BodyEntryNotifier, BodyEntry>((
  ref,
) {
  return BodyEntryNotifier();
});
