import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import 'package:heroicons/heroicons.dart';

/// A minimalist widget that displays health and nutrition calculation formulas
/// with educational content and professional sources
class HealthCalculationsSourcesWidget extends StatelessWidget {
  const HealthCalculationsSourcesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalculationCard(
            context,
            title: 'BMI (Body Mass Index)',
            description: 'A measure of body fat based on height and weight.',
            formula: 'BMI = weight (kg) ÷ [height (m)]²',
            interpretation:
                'Classification: Underweight (<18.5), Normal (18.5-24.9), Overweight (25-29.9), Obese (≥30)',
            sourceText: 'About Body Mass Index (BMI)',
            sourceUrl: 'https://www.cdc.gov/bmi/about/index.html',
            color: Theme.of(context).colorScheme.info,
          ),
          const SizedBox(height: 20),
          _buildCalculationCard(
            context,
            title: 'BMR (Basal Metabolic Rate)',
            description: 'The number of calories your body needs at rest.',
            formula: '''
Mifflin-St Jeor (Male): (10 × weight) + (6.25 × height) - (5 × age) + 5
Mifflin-St Jeor (Female): (10 × weight) + (6.25 × height) - (5 × age) - 161''',
            interpretation:
                'Weight in kg, height in cm, age in years. Mifflin-St Jeor is generally more accurate.',
            sourceText:
                'BMR Calculator (Basal Metabolic Rate, Mifflin St Jeor Equation) & Information',
            sourceUrl: 'https://www.omnicalculator.com/health/bmr',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          _buildCalculationCard(
            context,
            title: 'TDEE (Total Daily Energy Expenditure)',
            description: 'Your total daily calorie burn including activity.',
            formula: 'TDEE = BMR × Activity Factor',
            interpretation: '''Activity Factors:
• Sedentary (1.2): Little/no exercise
• Light (1.375): Light exercise 1-3 days/week
• Moderate (1.55): Moderate exercise 3-5 days/week
• Active (1.725): Heavy exercise 6-7 days/week
• Very Active (1.9): Very heavy exercise, physical job''',
            sourceText: 'TDEE Calculator',
            sourceUrl: 'https://tdeecalculator.net/',
            color: Theme.of(context).colorScheme.success,
          ),
          const SizedBox(height: 20),
          //           _buildCalculationCard(
          //             context,
          //             title: 'Caloric Adjustment for Weight Change',
          //             description: 'Daily calorie adjustment needed for weight goals.',
          //             formula:
          //                 '''Daily Calorie Adjustment = (Weight Change Goal × 7700) ÷ 7

          // Target Calories = TDEE ± Daily Adjustment

          // • Add calories for weight gain
          // • Subtract calories for weight loss''',
          //             interpretation:
          //                 '1 kg of body fat ≈ 7700 calories. Safe weight change: 0.5-1 kg per week.',
          //             sourceText: 'NIH Body Weight Planner',
          //             sourceUrl: 'https://www.niddk.nih.gov/bwp',
          //             color: Theme.of(context).colorScheme.warning,
          //           ),
        ],
      ),
    );
  }

  /// Builds a minimalist calculation card with formula and source information
  Widget _buildCalculationCard(
    BuildContext context, {
    required String title,
    required String description,
    required String formula,
    required String interpretation,
    required String sourceText,
    required String sourceUrl,
    required Color color,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with info icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.headline3(
                      context,
                    ).copyWith(color: color),
                  ),
                ),
                IconButton(
                  icon: HeroIcon(
                    HeroIcons.informationCircle,
                    style: HeroIconStyle.outline,
                    color: color,
                    size: 20,
                  ),
                  onPressed: () => _showInfoDialog(context, title, description),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // Formula section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formula',
                    style: AppTypography.subtitle2(
                      context,
                    ).copyWith(color: color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formula,
                    style: AppTypography.bodyMedium(context).copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Interpretation
            Text(
              interpretation,
              style: AppTypography.caption(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textSecondary),
            ),
            const SizedBox(height: 16),

            // Source link
            InkWell(
              onTap: () => _launchURL(sourceUrl),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    HeroIcon(
                      HeroIcons.link,
                      style: HeroIconStyle.outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sourceText,
                        style: AppTypography.caption(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    HeroIcon(
                      HeroIcons.arrowTopRightOnSquare,
                      style: HeroIconStyle.outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows an information dialog with the calculation description
  void _showInfoDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Launches the provided URL in an external browser
  /// Handles iOS platform channel errors gracefully
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback auf In-App-WebView
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: url));
      debugPrint('Launch failed, copied to clipboard: $url, error: $e');
    }
  }
}
