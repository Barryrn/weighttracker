import 'package:flutter/material.dart';  
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import '../model/profile_settings_storage_model.dart';  
import 'unit_conversion_provider.dart';  
import 'fat_percentae_calculator.dart';  
import 'entry_form_provider.dart';  
  
/// A ViewModel that manages the state and business logic for the Fat Percentage View.  
///  
/// This class follows the MVVM pattern by separating business logic and state management  
/// from the UI layer. It handles data loading, validation, calculation, and unit conversion.  
class FatPercentageViewModel extends StateNotifier<FatPercentageState> {  
  final Ref ref;  
  
  FatPercentageViewModel(this.ref) : super(FatPercentageState());  
  
  /// Loads profile settings to pre-fill form fields  
  Future<void> loadProfileSettings() async {  
    final profileSettings = await ProfileSettingsStorage.loadProfileSettings();  
    
    // Update gender from profile settings  
    if (profileSettings.gender != null) {  
      state = state.copyWith(gender: profileSettings.gender);  
    }  
    
    // Update height from profile settings  
    if (profileSettings.height != null) {  
      final unitPrefs = ref.read(unitConversionProvider);  
      final unitNotifier = ref.read(unitConversionProvider.notifier);  
      
      double displayHeight = profileSettings.height!;  
      if (!unitPrefs.useMetricHeight) {  
        // Convert from cm to inches for display  
        displayHeight = unitNotifier.cmToInches(displayHeight);  
      }  
      
      state = state.copyWith(
        height: displayHeight,
        heightText: displayHeight.toStringAsFixed(1)
      );  
    }  
    
    // Initialize controllers with current state values  
    updateControllerValues();  
  }  
  
  /// Updates the text controllers with the current state values  
  void updateControllerValues() {  
    if (state.height != null) {  
      state.heightController.text = state.heightText;  
    }  
    
    if (state.neck != null) {  
      state.neckController.text = state.neckText;  
    }  
    
    if (state.waist != null) {  
      state.waistController.text = state.waistText;  
    }  
    
    if (state.hip != null) {  
      state.hipController.text = state.hipText;  
    }  
  }  
  
  /// Validates a numeric input  
  String? validateNumber(String? value) {  
    if (value == null || value.isEmpty) {  
      return 'Please enter a value';  
    }  
    
    try {  
      final number = double.parse(value.replaceAll(',', '.'));  
      if (number <= 0) {  
        return 'Value must be greater than 0';  
      }  
    } catch (_) {  
      return 'Please enter a valid number';  
    }  
    
    return null;  
  }  
  
  /// Updates the gender value  
  void updateGender(String? gender) {  
    state = state.copyWith(gender: gender);  
  }  
  
  /// Updates the height value from text input  
  void updateHeight(String value) {  
    try {  
      final height = double.parse(value.replaceAll(',', '.'));  
      state = state.copyWith(height: height, heightText: value);  
    } catch (_) {}  
  }  
  
  /// Updates the neck circumference value from text input  
  void updateNeck(String value) {  
    try {  
      final neck = double.parse(value.replaceAll(',', '.'));  
      state = state.copyWith(neck: neck, neckText: value);  
    } catch (_) {}  
  }  
  
  /// Updates the waist circumference value from text input  
  void updateWaist(String value) {  
    try {  
      final waist = double.parse(value.replaceAll(',', '.'));  
      state = state.copyWith(waist: waist, waistText: value);  
    } catch (_) {}  
  }  
  
  /// Updates the hip circumference value from text input  
  void updateHip(String value) {  
    try {  
      final hip = double.parse(value.replaceAll(',', '.'));  
      state = state.copyWith(hip: hip, hipText: value);  
    } catch (_) {}  
  }  
  
  /// Toggles the formula type for 'Other' gender  
  void toggleFormulaType(bool useFemaleFomula) {  
    state = state.copyWith(useFemaleFomula: useFemaleFomula);  
  }  
  
  /// Toggles between metric and imperial measurement units  
  void toggleMeasurementUnits() {  
    final unitPrefs = ref.read(unitConversionProvider);  
    final unitNotifier = ref.read(unitConversionProvider.notifier);  
    
    // Toggle the height unit preference  
    unitNotifier.setHeightUnit(useMetric: !unitPrefs.useMetricHeight);  
    
    // Get the updated preferences after toggling  
    final newUnitPrefs = ref.read(unitConversionProvider);  
    
    // Convert height if it exists  
    if (state.height != null) {  
      double currentValue = state.height!;  
      
      // If we're switching from metric to imperial  
      if (!newUnitPrefs.useMetricHeight && unitPrefs.useMetricHeight) {  
        // Convert from cm to inches  
        currentValue = unitNotifier.cmToInches(currentValue);  
      }  
      // If we're switching from imperial to metric  
      else if (newUnitPrefs.useMetricHeight && !unitPrefs.useMetricHeight) {  
        // Convert from inches to cm  
        currentValue = unitNotifier.inchesToCm(currentValue);  
      }  
      
      state = state.copyWith(
        height: currentValue,
        heightText: currentValue.toStringAsFixed(1)
      );  
    }  
    
    // Convert neck if it exists  
    if (state.neck != null) {  
      double currentValue = state.neck!;  
      
      // If we're switching from metric to imperial  
      if (!newUnitPrefs.useMetricHeight && unitPrefs.useMetricHeight) {  
        // Convert from cm to inches  
        currentValue = unitNotifier.cmToInches(currentValue);  
      }  
      // If we're switching from imperial to metric  
      else if (newUnitPrefs.useMetricHeight && !unitPrefs.useMetricHeight) {  
        // Convert from inches to cm  
        currentValue = unitNotifier.inchesToCm(currentValue);  
      }  
      
      state = state.copyWith(
        neck: currentValue,
        neckText: currentValue.toStringAsFixed(1)
      );  
    }  
    
    // Convert waist if it exists  
    if (state.waist != null) {  
      double currentValue = state.waist!;  
      
      // If we're switching from metric to imperial  
      if (!newUnitPrefs.useMetricHeight && unitPrefs.useMetricHeight) {  
        // Convert from cm to inches  
        currentValue = unitNotifier.cmToInches(currentValue);  
      }  
      // If we're switching from imperial to metric  
      else if (newUnitPrefs.useMetricHeight && !unitPrefs.useMetricHeight) {  
        // Convert from inches to cm  
        currentValue = unitNotifier.inchesToCm(currentValue);  
      }  
      
      state = state.copyWith(
        waist: currentValue,
        waistText: currentValue.toStringAsFixed(1)
      );  
    }  
    
    // Convert hip if it exists  
    if (state.hip != null) {  
      double currentValue = state.hip!;  
      
      // If we're switching from metric to imperial  
      if (!newUnitPrefs.useMetricHeight && unitPrefs.useMetricHeight) {  
        // Convert from cm to inches  
        currentValue = unitNotifier.cmToInches(currentValue);  
      }  
      // If we're switching from imperial to metric  
      else if (newUnitPrefs.useMetricHeight && !unitPrefs.useMetricHeight) {  
        // Convert from inches to cm  
        currentValue = unitNotifier.inchesToCm(currentValue);  
      }  
      
      state = state.copyWith(
        hip: currentValue,
        hipText: currentValue.toStringAsFixed(1)
      );  
    }  
    
    // Update the text controllers with the new values  
    updateControllerValues();  
  }  
  
  /// Calculates the body fat percentage based on the entered measurements  
  Future<void> calculateFatPercentage(GlobalKey<FormState> formKey) async {  
    if (!formKey.currentState!.validate()) return;  
    
    state = state.copyWith(isLoading: true);  
    
    try {  
      final unitPrefs = ref.read(unitConversionProvider);  
      
      // Convert measurements to standard units (cm) if needed  
      double? standardHeight = state.height;  
      double? standardNeck = state.neck;  
      double? standardWaist = state.waist;  
      double? standardHip = state.hip;  
      
      if (!unitPrefs.useMetricHeight) {  
        // Convert from inches to cm  
        standardHeight = state.height != null ? state.height! * 2.54 : null;  
        standardNeck = state.neck != null ? state.neck! * 2.54 : null;  
        standardWaist = state.waist != null ? state.waist! * 2.54 : null;  
        standardHip = state.hip != null ? state.hip! * 2.54 : null;  
      }  
      
      final result = await ref  
          .read(fatPercentageCalculatorProvider.notifier)  
          .calculateFatPercentage(  
            gender: state.gender,  
            height: standardHeight,  
            neck: standardNeck,  
            waist: standardWaist,  
            hip: standardHip,  
            useFemaleFomula: state.gender?.toLowerCase() == 'other'  
                ? state.useFemaleFomula  
                : null,  
          );  
      
      state = state.copyWith(calculatedFatPercentage: result);  
    } catch (e) {  
      // Error will be handled by the View  
      rethrow;  
    } finally {  
      state = state.copyWith(isLoading: false);  
    }  
  }  
  
  /// Updates the notifier with the current measurements  
  void updateNotifierWithMeasurements() {  
    final unitPrefs = ref.read(unitConversionProvider);  
    final notifier = ref.read(bodyEntryProvider.notifier);  
    
    notifier.updateFatPercentage(state.calculatedFatPercentage);  
    notifier.updateHipCircumference(state.hip, useMetric: unitPrefs.useMetricHeight);  
    notifier.updateNeckCircumference(  
      state.neck,  
      useMetric: unitPrefs.useMetricHeight,  
    );  
    notifier.updateWaistCircumference(  
      state.waist,  
      useMetric: unitPrefs.useMetricHeight,  
    );  
  }  
  
  /// Saves the calculated fat percentage and returns the value  
  double? saveFatPercentage() {  
    double? fatPercentage = state.calculatedFatPercentage;  
    
    if (fatPercentage != null) {  
      // Round to one decimal place  
      fatPercentage = (fatPercentage * 10).round() / 10;  
      
      // Update the notifier before returning  
      updateNotifierWithMeasurements();  
    }  
    
    return fatPercentage;  
  }  
  
  /// Disposes of the controllers when the ViewModel is no longer needed  
  void dispose() {  
    state.neckController.dispose();  
    state.waistController.dispose();  
    state.hipController.dispose();  
    state.heightController.dispose();  
    state.manualFatController.dispose();  
  }  
}  
  
/// State class for the Fat Percentage ViewModel  
class FatPercentageState {  
  final String? gender;  
  final double? height;  
  final String heightText;  
  final double? neck;  
  final String neckText;  
  final double? waist;  
  final String waistText;  
  final double? hip;  
  final String hipText;  
  final double? calculatedFatPercentage;  
  final bool isLoading;  
  final bool useFemaleFomula;  
  
  // Controllers  
  final TextEditingController neckController;  
  final TextEditingController waistController;  
  final TextEditingController hipController;  
  final TextEditingController heightController;  
  final TextEditingController manualFatController;  
  
  FatPercentageState({  
    this.gender,  
    this.height,  
    this.heightText = '',  
    this.neck,  
    this.neckText = '',  
    this.waist,  
    this.waistText = '',  
    this.hip,  
    this.hipText = '',  
    this.calculatedFatPercentage,  
    this.isLoading = false,  
    this.useFemaleFomula = false,  
    TextEditingController? neckController,  
    TextEditingController? waistController,  
    TextEditingController? hipController,  
    TextEditingController? heightController,  
    TextEditingController? manualFatController,  
  }) : neckController = neckController ?? TextEditingController(),  
       waistController = waistController ?? TextEditingController(),  
       hipController = hipController ?? TextEditingController(),  
       heightController = heightController ?? TextEditingController(),  
       manualFatController = manualFatController ?? TextEditingController();  
  
  FatPercentageState copyWith({  
    String? gender,  
    double? height,  
    String? heightText,  
    double? neck,  
    String? neckText,  
    double? waist,  
    String? waistText,  
    double? hip,  
    String? hipText,  
    double? calculatedFatPercentage,  
    bool? isLoading,  
    bool? useFemaleFomula,  
  }) {  
    return FatPercentageState(  
      gender: gender ?? this.gender,  
      height: height ?? this.height,  
      heightText: heightText ?? this.heightText,  
      neck: neck ?? this.neck,  
      neckText: neckText ?? this.neckText,  
      waist: waist ?? this.waist,  
      waistText: waistText ?? this.waistText,  
      hip: hip ?? this.hip,  
      hipText: hipText ?? this.hipText,  
      calculatedFatPercentage: calculatedFatPercentage ?? this.calculatedFatPercentage,  
      isLoading: isLoading ?? this.isLoading,  
      useFemaleFomula: useFemaleFomula ?? this.useFemaleFomula,  
      neckController: this.neckController,  
      waistController: this.waistController,  
      hipController: this.hipController,  
      heightController: this.heightController,  
      manualFatController: this.manualFatController,  
    );  
  }  
}  
  
/// Provider for the Fat Percentage ViewModel  
final fatPercentageViewModelProvider = StateNotifierProvider.autoDispose<FatPercentageViewModel, FatPercentageState>((ref) {  
  final viewModel = FatPercentageViewModel(ref);  
  return viewModel;  
});