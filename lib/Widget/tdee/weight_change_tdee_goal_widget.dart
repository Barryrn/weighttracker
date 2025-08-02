import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/ViewModel/weight_change_tdee_goal_provider.dart';

class WeightChangeGoalTDEEWidget extends ConsumerStatefulWidget {
  const WeightChangeGoalTDEEWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<WeightChangeGoalTDEEWidget> createState() =>
      _WeightChangeGoalTDEEWidgetState();
}

class _WeightChangeGoalTDEEWidgetState
    extends ConsumerState<WeightChangeGoalTDEEWidget> {
  late TextEditingController _weightChangeController;

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

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(weightChangeGoalTDEEProvider.notifier);
    final goalState = ref.watch(weightChangeGoalTDEEProvider);

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

    // Sync controller with state
    final currentText = _weightChangeController.text;
    final newText = weightChangePerWeek.toString();
    if (currentText != newText) {
      _weightChangeController.text = newText;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 12),
                Text(
                  'Weight Change Goal TDEE',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                      notifier.updateGoalSettings(
                        isGainingWeight: true,
                        weightChangePerWeek: weightChangePerWeek,
                      );
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
                      notifier.updateGoalSettings(
                        isGainingWeight: false,
                        weightChangePerWeek: weightChangePerWeek,
                      );
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
              decoration: InputDecoration(
                labelText: 'Weight Change per Week (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g. 0.5',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
              onSubmitted: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= 0) {
                  notifier.updateGoalSettings(
                    isGainingWeight: isGainingWeight,
                    weightChangePerWeek: parsed,
                  );
                } else {
                  _weightChangeController.text = weightChangePerWeek.toString();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid positive number'),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Minimalistic Calculation Summary
            if (baseTDEE != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
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
                      '${weightChangePerWeek.toStringAsFixed(2)} kg/week',
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
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? color : Colors.grey.shade600,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
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
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: valueColor ?? Colors.black,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
