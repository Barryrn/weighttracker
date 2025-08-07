import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../ViewModel/tdee_provider.dart';

class TDEEWidget extends ConsumerWidget {
  const TDEEWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tdee = ref.watch(tdeeProvider);
    final activityLevels = ref.watch(activityLevelsProvider);
    final currentActivityLevel = ref.read(tdeeProvider.notifier).activityLevel;

    return Card(
      shadowColor: AppColors.primary.withOpacity(0.2),
      color: AppColors.card,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Daily Energy Expenditure (TDEE)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                tdee != null
                    ? '${tdee.toInt()} calories/day'
                    : 'Not calculated',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activity Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ActivityLevel>(
              value: currentActivityLevel,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.background1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true, // expand dropdown width to parent
              dropdownColor: Colors.white,
              items: activityLevels.map((level) {
                return DropdownMenuItem<ActivityLevel>(
                  value: level,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Text(
                      level.description,
                      softWrap: true,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newLevel) {
                if (newLevel != null) {
                  ref.read(tdeeProvider.notifier).updateActivityLevel(newLevel);
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'This is a first estimate of your TDEE based on age, weight, gender, and activity level.\nFor a more precise result, track your body weight and calorie intake for at least 7 continous days.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
