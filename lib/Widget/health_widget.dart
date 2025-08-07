import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/theme.dart';
import '../ViewModel/health_provider.dart';

/// A widget for displaying and managing health sync settings
class HealthWidget extends ConsumerWidget {
  const HealthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthStateProvider);
    final healthNotifier = ref.read(healthStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Health service availability card
        _buildStatusCard(
          context,
          title: 'Health Services',
          subtitle: healthState.isAvailable
              ? 'Available on your device'
              : 'Not available on your device',
          icon: healthState.isAvailable
              ? Icons.check_circle
              : Icons.error_outline,
          iconColor: healthState.isAvailable
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.warning,
        ),

        const SizedBox(height: 12),

        // Authorization status card
        _buildStatusCard(
          context,
          title: 'Authorization',
          subtitle: healthState.isAuthorized
              ? 'Access granted'
              : 'Access not granted',
          icon: healthState.isAuthorized
              ? Icons.check_circle
              : Icons.lock_outline,
          iconColor: healthState.isAuthorized
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.warning,
        ),

        const SizedBox(height: 12),

        // Last sync time card
        _buildStatusCard(
          context,
          title: 'Last Sync',
          subtitle: healthState.lastSyncTime != null
              ? DateFormat(
                  'MMM d, yyyy h:mm a',
                ).format(healthState.lastSyncTime!)
              : 'Never synced',
          icon: Icons.sync,
          iconColor: healthState.lastSyncTime != null
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),

        const SizedBox(height: 12),

        // Error message if any
        if (healthState.errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    healthState.errorMessage!,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Action buttons
        if (healthState.isAvailable && !healthState.isAuthorized)
          _buildActionButton(
            context,
            label: 'Grant Access',
            labelColor: Theme.of(context).colorScheme.textPrimary,
            icon: Icons.vpn_key,
            iconHeight: 24,
            iconWidth: 24,
            labelHeight: 12,
            iconColor: Theme.of(context).colorScheme.primary,
            onPressed: () => healthNotifier.requestAuthorization(),
            isLoading: healthState.isSyncing,
          ),

        if (healthState.isAvailable && healthState.isAuthorized) ...[
          _buildActionButton(
            context,
            label: 'Sync Now',
            labelColor: Theme.of(context).colorScheme.textPrimary,
            icon: Icons.sync,
            iconHeight: 24,
            iconWidth: 24,
            labelHeight: 20,
            iconColor: Theme.of(context).colorScheme.primary,
            onPressed: healthState.isSyncing
                ? null
                : () => healthNotifier.performTwoWaySync(),
            isLoading: healthState.isSyncing,
          ),

          const SizedBox(height: 16),

          // Updated explanation text to include BMI
          Text(
            'Syncing will:\n'
            '• Send your weight, body fat percentage, and BMI data to Apple Health / Google Health Connect\n'
            '• Import weight, body fat percentage, and BMI measurements from health services\n'
            '• Keep both systems up to date',
            style: AppTypography.bodyMedium(context).copyWith(
              color: Theme.of(context).colorScheme.textSecondary,
            ),
          ),
        ],

        if (!healthState.isAvailable) ...[
          const SizedBox(height: 12),
          Text(
            'Health services are not available on your device. This feature requires Apple Health on iOS or Health Connect on Android.',
            style: AppTypography.bodyMedium(context).copyWith(color: Colors.grey),
          ),
        ],
      ],
    );
  }

  /// Build a status card with title, subtitle, and icon
  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.card,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitle1(context).copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.textSecondary,
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

  /// Build an action button with label, icon, and loading state
  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isLoading,
    required Color iconColor,
    required Color labelColor,
    double? iconHeight,
    double? iconWidth,
    double? labelHeight,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: iconColor, size: iconHeight),
        label: Text(
          label,
          style: AppTypography.buttonText(context).copyWith(color: labelColor),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.card,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Weniger rund
          ),
        ),
      ),
    );
  }
}
