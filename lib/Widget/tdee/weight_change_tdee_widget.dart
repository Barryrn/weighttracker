import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ViewModel/weight_change_tdee_provider.dart';

/// A widget that displays the TDEE calculated based on weight change and calorie intake.
///
/// This widget follows the MVVM pattern by acting as the View that displays data
/// from the ViewModel (WeightChangeTDEENotifier).
class WeightChangeTDEEWidget extends ConsumerWidget {
  const WeightChangeTDEEWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the calculated TDEE from the provider
    final tdee = ref.watch(weightChangeTDEEProvider);
    
    // Debug log when widget rebuilds with new TDEE value
    print('WeightChangeTDEEWidget rebuilding with TDEE: $tdee');

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
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Weight Change TDEE',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Based on your weight change and calorie intake over time:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildTDEEDisplay(context, tdee),
            const SizedBox(height: 16),
            const Text(
              'This calculation uses the formula: TDEE = (CaloriesConsumed + (WeightChange_kg × 7700)) / Days',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            _buildRequirementsText(tdee),
          ],
        ),
      ),
    );
  }

  /// Builds the display for the calculated TDEE value
  Widget _buildTDEEDisplay(BuildContext context, double? tdee) {
    if (tdee == null) {
      return const Card(
        color: Colors.grey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Insufficient data for TDEE calculation. Please track your weight and calories for at least 7 consecutive days.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Text(
                '${tdee.toStringAsFixed(0)} calories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your estimated daily calorie needs',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the requirements text based on whether TDEE is calculated
  Widget _buildRequirementsText(double? tdee) {
    if (tdee == null) {
      return const Text(
        'Note: This calculation requires at least 7 consecutive days of weight and calorie data. It will use up to 14 days of continuous data for more accuracy.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    } else {
      return const Text(
        'This calculation automatically updates when you add new entries.',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
  }
}
