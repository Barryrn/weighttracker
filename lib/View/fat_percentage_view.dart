import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/entry_form_provider.dart';
import '../ViewModel/fat_percentae_calculator.dart';
import '../model/profile_settings_storage_model.dart';
import '../model/profile_settings_model.dart';
import '../ViewModel/unit_conversion_provider.dart';
import '../theme.dart';

/// A view that allows users to calculate their body fat percentage based on measurements.
///
/// This view follows the MVVM pattern by using the fatPercentageCalculatorProvider
/// to perform the calculation logic.
class FatPercentageView extends ConsumerStatefulWidget {
  const FatPercentageView({Key? key}) : super(key: key);

  @override
  ConsumerState<FatPercentageView> createState() => _FatPercentageViewState();
}

class _FatPercentageViewState extends ConsumerState<FatPercentageView> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  final _heightController = TextEditingController();

  // Form values
  String? _gender;
  double? _height;
  double? _neck;
  double? _waist;
  double? _hip;
  double? _calculatedFatPercentage;
  bool _isLoading = false;
  final _manualFatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileSettings();
  }

  @override
  void dispose() {
    _neckController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    _heightController.dispose();
    _manualFatController.dispose();
    super.dispose();
  }

  /// Loads profile settings from storage to pre-fill gender and height
  Future<void> _loadProfileSettings() async {
    setState(() => _isLoading = true);

    try {
      final settings = await ProfileSettingsStorage.loadProfileSettings();
      final unitPrefs = ref.read(unitConversionProvider);

      setState(() {
        _gender = settings.gender;
        if (settings.height != null) {
          _height = settings.height;
          // Convert height from cm to display unit
          final displayHeight = unitPrefs.useMetricHeight
              ? _height
              : _height! / 2.54; // Convert cm to inches
          _heightController.text = displayHeight!.toStringAsFixed(1);
        }
      });
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Calculates the body fat percentage based on the entered measurements
  Future<void> _calculateFatPercentage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final unitPrefs = ref.read(unitConversionProvider);

      // Convert measurements to standard units (cm) if needed
      double? standardHeight = _height;
      double? standardNeck = _neck;
      double? standardWaist = _waist;
      double? standardHip = _hip;

      if (!unitPrefs.useMetricHeight) {
        // Convert from inches to cm
        standardHeight = _height != null ? _height! * 2.54 : null;
        standardNeck = _neck != null ? _neck! * 2.54 : null;
        standardWaist = _waist != null ? _waist! * 2.54 : null;
        standardHip = _hip != null ? _hip! * 2.54 : null;
      }

      final result = await ref
          .read(fatPercentageCalculatorProvider.notifier)
          .calculateFatPercentage(
            gender: _gender,
            height: standardHeight,
            neck: standardNeck,
            waist: standardWaist,
            hip: standardHip,
          );

      setState(() {
        _calculatedFatPercentage = result;
        // Removed notifier updates from here
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error calculating body fat percentage')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Updates the notifier with the current measurements
  void _updateNotifierWithMeasurements() {
    final unitPrefs = ref.read(unitConversionProvider);
    final notifier = ref.read(bodyEntryProvider.notifier);

    notifier.updateFatPercentage(_calculatedFatPercentage);
    notifier.updateHipCircumference(_hip, useMetric: unitPrefs.useMetricHeight);
    notifier.updateNeckCircumference(
      _neck,
      useMetric: unitPrefs.useMetricHeight,
    );
    notifier.updateWaistCircumference(
      _waist,
      useMetric: unitPrefs.useMetricHeight,
    );
  }

  /// Saves the calculated or manually entered fat percentage and returns to previous screen
  void _saveFatPercentage() {
    double? fatPercentage = _calculatedFatPercentage;

    if (fatPercentage != null) {
      // Update the notifier before navigating back
      _updateNotifierWithMeasurements();
      Navigator.pop(context, fatPercentage);
    }
  }

  /// Validates that the input is a valid number
  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
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

  /// Toggles between metric and imperial units for measurements
  void _toggleMeasurementUnits() {
    final unitNotifier = ref.read(unitConversionProvider.notifier);
    final currentPrefs = ref.read(unitConversionProvider);

    // Toggle the unit preference
    unitNotifier.setHeightUnit(useMetric: !currentPrefs.useMetricHeight);

    // Update the text fields with converted values
    final newUnitPrefs = ref.read(unitConversionProvider);

    setState(() {
      // Convert height
      if (_height != null) {
        // Get the current value from the text field
        double currentValue =
            double.tryParse(_heightController.text.replaceAll(',', '.')) ??
            _height!;

        // If we're switching from metric to imperial
        if (!newUnitPrefs.useMetricHeight && currentPrefs.useMetricHeight) {
          // Convert from cm to inches
          currentValue = unitNotifier.cmToInches(currentValue);
        }
        // If we're switching from imperial to metric
        else if (newUnitPrefs.useMetricHeight &&
            !currentPrefs.useMetricHeight) {
          // Convert from inches to cm
          currentValue = unitNotifier.inchesToCm(currentValue);
        }

        _heightController.text = currentValue.toStringAsFixed(1);
        _height = currentValue;
      }

      // Convert neck
      if (_neck != null) {
        // Get the current value from the text field
        double currentValue =
            double.tryParse(_neckController.text.replaceAll(',', '.')) ??
            _neck!;

        // If we're switching from metric to imperial
        if (!newUnitPrefs.useMetricHeight && currentPrefs.useMetricHeight) {
          // Convert from cm to inches
          currentValue = unitNotifier.cmToInches(currentValue);
        }
        // If we're switching from imperial to metric
        else if (newUnitPrefs.useMetricHeight &&
            !currentPrefs.useMetricHeight) {
          // Convert from inches to cm
          currentValue = unitNotifier.inchesToCm(currentValue);
        }

        _neckController.text = currentValue.toStringAsFixed(1);
        _neck = currentValue;
      }

      // Convert waist
      if (_waist != null) {
        // Get the current value from the text field
        double currentValue =
            double.tryParse(_waistController.text.replaceAll(',', '.')) ??
            _waist!;

        // If we're switching from metric to imperial
        if (!newUnitPrefs.useMetricHeight && currentPrefs.useMetricHeight) {
          // Convert from cm to inches
          currentValue = unitNotifier.cmToInches(currentValue);
        }
        // If we're switching from imperial to metric
        else if (newUnitPrefs.useMetricHeight &&
            !currentPrefs.useMetricHeight) {
          // Convert from inches to cm
          currentValue = unitNotifier.inchesToCm(currentValue);
        }

        _waistController.text = currentValue.toStringAsFixed(1);
        _waist = currentValue;
      }

      // Convert hip
      if (_hip != null) {
        // Get the current value from the text field
        double currentValue =
            double.tryParse(_hipController.text.replaceAll(',', '.')) ?? _hip!;

        // If we're switching from metric to imperial
        if (!newUnitPrefs.useMetricHeight && currentPrefs.useMetricHeight) {
          // Convert from cm to inches
          currentValue = unitNotifier.cmToInches(currentValue);
        }
        // If we're switching from imperial to metric
        else if (newUnitPrefs.useMetricHeight &&
            !currentPrefs.useMetricHeight) {
          // Convert from inches to cm
          currentValue = unitNotifier.inchesToCm(currentValue);
        }

        _hipController.text = currentValue.toStringAsFixed(1);
        _hip = currentValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unitPrefs = ref.watch(unitConversionProvider);
    final lengthUnit = unitPrefs.useMetricHeight ? 'cm' : 'inches';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Fat Calculator'),
        backgroundColor: AppColors.primaryVeryLight,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () =>
                  FocusScope.of(context).unfocus(), // dismiss keyboard on tap
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Gender selection
                          const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Height input
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Height ($lengthUnit)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleMeasurementUnits,
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: AppColors.primaryVeryLight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  'Switch to ${unitPrefs.useMetricHeight ? "inches" : "cm"}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _heightController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixText: lengthUnit,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            validator: _validateNumber,
                            onChanged: (value) {
                              try {
                                _height = double.parse(
                                  value.replaceAll(',', '.'),
                                );
                              } catch (_) {}
                            },
                          ),

                          const SizedBox(height: 16),

                          // Neck circumference input
                          Text(
                            'Neck Circumference ($lengthUnit)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _neckController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixText: lengthUnit,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            validator: _validateNumber,
                            onChanged: (value) {
                              try {
                                _neck = double.parse(
                                  value.replaceAll(',', '.'),
                                );
                              } catch (_) {}
                            },
                          ),

                          const SizedBox(height: 16),

                          // Waist circumference input
                          Text(
                            'Waist Circumference ($lengthUnit)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _waistController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixText: lengthUnit,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            validator: _validateNumber,
                            onChanged: (value) {
                              try {
                                _waist = double.parse(
                                  value.replaceAll(',', '.'),
                                );
                              } catch (_) {}
                            },
                          ),

                          const SizedBox(height: 16),

                          // Hip circumference input (only for women)
                          if (_gender == 'Female') ...[
                            Text(
                              'Hip Circumference ($lengthUnit)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _hipController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixText: lengthUnit,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.,]'),
                                ),
                              ],
                              validator: _validateNumber,
                              onChanged: (value) {
                                try {
                                  _hip = double.parse(
                                    value.replaceAll(',', '.'),
                                  );
                                } catch (_) {}
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Calculate button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _calculateFatPercentage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Calculate Body Fat'),
                            ),
                          ),

                          // Display calculated result
                          if (_calculatedFatPercentage != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryVeryLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Calculated Body Fat Percentage',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_calculatedFatPercentage!.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Add a save button below the result
                                  ElevatedButton(
                                    onPressed: _saveFatPercentage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text('Use This Result'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
