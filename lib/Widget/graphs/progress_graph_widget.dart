import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'table_progress_widget.dart';
import 'line_chart_progress_widget.dart';
import '../../theme.dart';

/// Provider to manage the graph view type state
///
/// This provider follows the MVVM pattern by separating the UI state
/// from the view implementation.
final graphViewTypeProvider = StateProvider<GraphViewType>(
  (ref) => GraphViewType.chart,
);

/// Enum representing different graph view types
enum GraphViewType { chart, table }

/// A widget that provides a toggle between different graph view types.
///
/// This widget follows the MVVM pattern by using the graphViewTypeProvider
/// to manage the current view state and toggle between different visualizations.
class ProgressGraphWidget extends ConsumerWidget {
  const ProgressGraphWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current view type from the provider
    final viewType = ref.watch(graphViewTypeProvider);

    return Column(
      children: [
        // Toggle button for switching between views
        _buildViewToggle(context, ref, viewType),
        const SizedBox(height: 16),

        // Display the appropriate widget based on the selected view type
        _buildGraphView(viewType),
      ],
    );
  }

  /// Builds the toggle button for switching between chart and table views
  Widget _buildViewToggle(
    BuildContext context,
    WidgetRef ref,
    GraphViewType currentType,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton(
              context,
              ref,
              GraphViewType.chart,
              'Chart View',
              Icons.show_chart,
              currentType,
            ),
            const SizedBox(width: 16),
            _buildToggleButton(
              context,
              ref,
              GraphViewType.table,
              'Table View',
              Icons.table_chart,
              currentType,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual toggle button
  Widget _buildToggleButton(
    BuildContext context,
    WidgetRef ref,
    GraphViewType type,
    String label,
    IconData icon,
    GraphViewType currentType,
  ) {
    final isSelected = type == currentType;

    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {
          // Update the view type when button is pressed
          ref.read(graphViewTypeProvider.notifier).state = type;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primary
              : AppColors.primaryVeryLight,
          foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  /// Returns the appropriate widget based on the selected view type
  Widget _buildGraphView(GraphViewType viewType) {
    switch (viewType) {
      case GraphViewType.chart:
        return const LineChartProgressWidget();
      case GraphViewType.table:
        return const TableProgressWidget();
    }
  }
}
