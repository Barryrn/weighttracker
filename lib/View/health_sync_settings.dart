import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../ViewModel/health_provider.dart';

/// A widget for displaying and managing health sync settings
class HealthSyncSettings extends ConsumerWidget {
  const HealthSyncSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthStateProvider);
    final healthNotifier = ref.read(healthStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Integration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              iconColor: healthState.isAvailable ? Colors.green : Colors.orange,
            ),

            const SizedBox(height: 16),

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
                  ? Colors.green
                  : Colors.orange,
            ),

            const SizedBox(height: 16),

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
                  ? Colors.blue
                  : Colors.grey,
            ),

            const SizedBox(height: 24),

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
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        healthState.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            if (healthState.isAvailable && !healthState.isAuthorized)
              _buildActionButton(
                context,
                label: 'Grant Access',
                icon: Icons.vpn_key,
                onPressed: () => healthNotifier.requestAuthorization(),
                isLoading: healthState.isSyncing,
              ),

            if (healthState.isAvailable && healthState.isAuthorized) ...[
              _buildActionButton(
                context,
                label: 'Sync Now',
                icon: Icons.sync,
                onPressed: healthState.isSyncing
                    ? null
                    : () => healthNotifier.performTwoWaySync(),
                isLoading: healthState.isSyncing,
              ),

              const SizedBox(height: 12),

              // Explanation text
              const Text(
                'Syncing will:\n'
                '• Send your weight data to Apple Health / Google Health Connect\n'
                '• Import weight measurements from health services\n'
                '• Keep both systems up to date',
                style: TextStyle(color: Colors.grey),
              ),
            ],

            if (!healthState.isAvailable) ...[
              const SizedBox(height: 12),
              const Text(
                'Health services are not available on your device. This feature requires Apple Health on iOS or Health Connect on Android.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
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
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
