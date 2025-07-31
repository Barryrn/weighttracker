import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ViewModel/weight_loss_goal_provider.dart';

/// A widget that allows users to set a weekly weight goal (loss or gain) and displays
/// the calculated calorie change, adjusted TDEE, and target calorie intake.
///
/// This widget follows the MVVM pattern by acting as the View that displays data
/// from the ViewModel (WeightLossGoalViewModel).
class WeightLossGoalWidget extends ConsumerWidget {
  const WeightLossGoalWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the weight loss goal data from the provider
    final goalData = ref.watch(weightLossGoalViewModelProvider);
    final viewModel = ref.read(weightLossGoalViewModelProvider.notifier);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      goalData.goalType == WeightGoalType.loss
                          ? Icons.trending_down
                          : Icons.trending_up,
                      color: goalData.goalType == WeightGoalType.loss
                          ? Colors.green
                          : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goalData.goalType == WeightGoalType.loss
                          ? 'Weight Loss Goal'
                          : 'Weight Gain Goal',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                // Toggle button for switching between loss and gain
                ElevatedButton.icon(
                  onPressed: viewModel.toggleGoalType,
                  icon: Icon(
                    goalData.goalType == WeightGoalType.loss
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 20,
                  ),
                  label: Text(
                    goalData.goalType == WeightGoalType.loss
                        ? 'Switch to Gain'
                        : 'Switch to Loss',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goalData.goalType == WeightGoalType.loss
                        ? Colors.blue
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              goalData.goalType == WeightGoalType.loss
                  ? 'How much weight do you want to lose per week?'
                  : 'How much weight do you want to gain per week?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildWeeklyGoalInput(context, goalData, viewModel),
            const SizedBox(height: 16),
            _buildCalculationsDisplay(context, goalData),
            const SizedBox(height: 16),
            Text(
              goalData.goalType == WeightGoalType.loss
                  ? 'Based on the formula: 1 kg of weight loss ≈ 7700 kcal'
                  : 'Based on the formula: 1 kg of weight gain ≈ 7700 kcal',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the input field for the weekly weight loss goal
  Widget _buildWeeklyGoalInput(
    BuildContext context,
    WeightLossGoalData goalData,
    WeightLossGoalViewModel viewModel,
  ) {
    return TextFormField(
      controller: goalData.weeklyGoalController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Weekly Goal',
        hintText: 'e.g., 0.5',
        suffixText: goalData.unitSuffix,
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [
        // Allow only numbers, comma, and period
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        // Ensure only one decimal place
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          if (text.isEmpty) return newValue;

          // Replace comma with period for decimal
          String sanitized = text.replaceAll(',', '.');

          // Check if there's more than one period
          if (sanitized.split('.').length > 2) {
            return oldValue;
          }

          // Limit to one decimal place
          final parts = sanitized.split('.');
          if (parts.length == 2 && parts[1].length > 1) {
            sanitized = '${parts[0]}.${parts[1].substring(0, 1)}';
          }

          return TextEditingValue(
            text: sanitized,
            selection: TextSelection.collapsed(offset: sanitized.length),
          );
        }),
      ],
      onChanged: viewModel.onWeeklyGoalChanged,
    );
  }

  /// Builds the display for the calculated values
  Widget _buildCalculationsDisplay(
    BuildContext context,
    WeightLossGoalData goalData,
  ) {
    if (goalData.weeklyGoal == null || goalData.weeklyGoal == 0) {
      return Card(
        color: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              goalData.goalType == WeightGoalType.loss
                  ? 'Enter a weekly weight loss goal to see calculations'
                  : 'Enter a weekly weight gain goal to see calculations',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Card(
      color: goalData.goalType == WeightGoalType.loss
          ? Colors.green.shade50
          : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Calorie Change (Deficit or Surplus)
            _buildInfoRow(
              goalData.goalType == WeightGoalType.loss
                  ? 'Daily Calorie Deficit:'
                  : 'Daily Calorie Surplus:',
              goalData.dailyCalorieChange != null
                  ? '${goalData.dailyCalorieChange!.toStringAsFixed(0)} kcal'
                  : 'N/A',
              goalData.goalType == WeightGoalType.loss
                  ? Colors.orange
                  : Colors.purple,
            ),
            const SizedBox(height: 8),

            // Current TDEE
            _buildInfoRow(
              'Current TDEE:',
              goalData.currentTDEE != null
                  ? '${goalData.currentTDEE!.toStringAsFixed(0)} kcal'
                  : 'Not available',
              Colors.blue,
            ),
            const SizedBox(height: 8),

            // Adjusted TDEE
            _buildInfoRow(
              goalData.goalType == WeightGoalType.loss
                  ? 'Adjusted TDEE for Weight Loss:'
                  : 'Adjusted TDEE for Weight Gain:',
              goalData.adjustedTDEE != null
                  ? '${goalData.adjustedTDEE!.toStringAsFixed(0)} kcal'
                  : 'N/A',
              goalData.goalType == WeightGoalType.loss
                  ? Colors.green
                  : Colors.blue,
            ),
            const SizedBox(height: 16),

            // Target Calorie Intake
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goalData.goalType == WeightGoalType.loss
                    ? Colors.green.shade100
                    : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Suggested Daily Calorie Intake',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goalData.targetCalorieIntake != null
                        ? '${goalData.targetCalorieIntake!.toStringAsFixed(0)} kcal'
                        : 'Not available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: goalData.goalType == WeightGoalType.loss
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row with a label and value
  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
