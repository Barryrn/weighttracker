import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/weight_change_tdee_goal_provider.dart';
import 'package:weigthtracker/ViewModel/unit_conversion_provider.dart';
import 'package:weigthtracker/theme.dart';

class WeightChangeGoalTDEEWidget extends ConsumerStatefulWidget {
  const WeightChangeGoalTDEEWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<WeightChangeGoalTDEEWidget> createState() =>
      _WeightChangeGoalTDEEWidgetState();
}

/// A formatter that limits input to 2 decimal places
class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final regEx = RegExp(r'^\d*\.?\d{0,2}');
    String newString = regEx.stringMatch(newValue.text) ?? '';
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class _WeightChangeGoalTDEEWidgetState
    extends ConsumerState<WeightChangeGoalTDEEWidget> {
  late TextEditingController _weightChangeController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _weightChangeController = TextEditingController();
  }

  @override
  void dispose() {
    _weightChangeController.dispose();
    super.dispose();
  }

  /// Updates the goal settings with the current input value
  void _updateGoalWithCurrentInput(bool isGainingWeight) {
    final notifier = ref.read(weightChangeGoalTDEEProvider.notifier);
    final unitPrefs = ref.read(unitConversionProvider);

    final parsed = double.tryParse(_weightChangeController.text);
    if (parsed != null && parsed >= 0) {
      // Convert to kg if using imperial units
      final standardWeight = unitPrefs.useMetricWeight
          ? parsed
          : parsed * 0.45359237;

      notifier.updateGoalSettings(
        isGainingWeight: isGainingWeight,
        weightChangePerWeek: standardWeight,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(weightChangeGoalTDEEProvider.notifier);
    final goalState = ref.watch(weightChangeGoalTDEEProvider);

    // Watch the unit conversion provider to get the current weight unit
    final unitPrefs = ref.watch(unitConversionProvider);
    final weightUnit = unitPrefs.useMetricWeight ? 'kg' : 'lb';

    final double? baseTDEE = goalState.baseTDEE;
    final double weightChangePerWeek = goalState.weightChangePerWeek;
    final bool isGainingWeight = goalState.isGainingWeight;
    final int days = 7;

    final double calorieAdjustment =
        (weightChangePerWeek * 7700) / days * (isGainingWeight ? 1 : -1);

    final double? goalTDEE = baseTDEE != null
        ? baseTDEE + calorieAdjustment
        : null;

    final theme = Theme.of(context);

    // Sync controller with state only if not currently editing
    if (!_isEditing) {
      // Convert the weight value based on the current unit
      final double displayWeightChange = unitPrefs.useMetricWeight
          ? weightChangePerWeek
          : weightChangePerWeek / 0.45359237;

      // Format to 2 decimal places
      final newText = displayWeightChange.toStringAsFixed(2);
      if (_weightChangeController.text != newText) {
        _weightChangeController.text = newText;
      }
    }

    // Wrap with GestureDetector to dismiss keyboard when tapping outside
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside the text field
        FocusScope.of(context).unfocus();
        setState(() {
          _isEditing = false;
        });
      },
      child: Card(
        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        color: Theme.of(context).colorScheme.card,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Weight Change Goal TDEE',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ),

              const SizedBox(height: 20),

              // Buttons for Gain / Lose Weight
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleButton(
                    context,
                    label: 'Gain Weight',
                    selected: isGainingWeight,
                    color: Colors.green,
                    onTap: () {
                      if (!isGainingWeight) {
                        _updateGoalWithCurrentInput(true);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildToggleButton(
                    context,
                    label: 'Lose Weight',
                    selected: !isGainingWeight,
                    color: Colors.redAccent,
                    onTap: () {
                      if (isGainingWeight) {
                        _updateGoalWithCurrentInput(false);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Weight Change Input
              TextField(
                controller: _weightChangeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                // Add input formatters to limit decimal places
                inputFormatters: [
                  DecimalTextInputFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Weight Change per Week (${weightUnit})',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText:
                      'e.g. ${unitPrefs.useMetricWeight ? "0.50" : "1.10"}',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                // Add onChanged to update in real-time
                onChanged: (value) {
                  setState(() {
                    _isEditing = true;
                  });

                  final parsed = double.tryParse(value);
                  if (parsed != null && parsed >= 0) {
                    // Convert to kg if using imperial units
                    final standardWeight = unitPrefs.useMetricWeight
                        ? parsed
                        : parsed * 0.45359237;

                    notifier.updateGoalSettings(
                      isGainingWeight: isGainingWeight,
                      weightChangePerWeek: standardWeight,
                    );
                  }
                },
                onSubmitted: (value) {
                  setState(() {
                    _isEditing = false;
                  });

                  final parsed = double.tryParse(value);
                  if (parsed != null && parsed >= 0) {
                    // Convert to kg if using imperial units
                    final standardWeight = unitPrefs.useMetricWeight
                        ? parsed
                        : parsed * 0.45359237;

                    notifier.updateGoalSettings(
                      isGainingWeight: isGainingWeight,
                      weightChangePerWeek: standardWeight,
                    );
                  } else {
                    // Convert the weight value based on the current unit
                    final double displayWeightChange = unitPrefs.useMetricWeight
                        ? weightChangePerWeek
                        : weightChangePerWeek / 0.45359237;

                    _weightChangeController.text = displayWeightChange
                        .toStringAsFixed(2);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid positive number'),
                      ),
                    );
                  }
                },
                // Reset editing state when focus is lost
                onEditingComplete: () {
                  setState(() {
                    _isEditing = false;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Minimalistic Calculation Summary
              if (baseTDEE != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background2,

                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryRow(
                        'Base TDEE',
                        '${baseTDEE.toStringAsFixed(0)} kcal/day',
                      ),
                      _buildSummaryRow(
                        'Weight Change',
                        '${(unitPrefs.useMetricWeight ? weightChangePerWeek : weightChangePerWeek / 0.45359237).toStringAsFixed(2)} ${weightUnit}/week',
                      ),
                      _buildSummaryRow(
                        'Calorie Adjustment',
                        '${calorieAdjustment.toStringAsFixed(0)} kcal/day',
                        valueColor: calorieAdjustment >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildSummaryRow(
                        'Goal TDEE',
                        '${goalTDEE?.toStringAsFixed(0) ?? 'N/A'} kcal/day',
                        isBold: true,
                      ),
                    ],
                  ),
                )
              else
                Center(
                  child: Text(
                    'Insufficient data to calculate goal TDEE.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : Colors.grey.shade400,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
