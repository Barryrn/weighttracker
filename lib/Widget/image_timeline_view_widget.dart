import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/viewmodel/unit_conversion_provider.dart';
import '../ViewModel/image_timeline_view_model.dart';
import '../ViewModel/image_export_view_model.dart';
import '../theme.dart';
import 'image_timeline_filter.dart';

/// A widget that displays the timeline content of progress images.
/// Does NOT include a Scaffold, so you can use it inside any Scaffold.
class ImageTimelineViewWidget extends ConsumerStatefulWidget {
  const ImageTimelineViewWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageTimelineViewWidget> createState() =>
      _ImageTimelineViewWidgetState();
}

class _ImageTimelineViewWidgetState
    extends ConsumerState<ImageTimelineViewWidget> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageTimelineProvider);
    final viewModel = ref.read(imageTimelineProvider.notifier);
    final currentEntry = viewModel.getCurrentEntry();
    // Add this line to get the unit conversion provider
    final unitPreferences = ref.watch(unitConversionProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null) {
      return Center(child: Text(state.errorMessage!));
    }

    // Always show the filter toggle and filter section, even when no entries match
    return Column(
      children: [
        // Filter section - always show if _showFilters is true
        if (_showFilters) const ImageTimelineFilter(),
        const SizedBox(height: 16),

        // Show message when no entries match the filter criteria
        if (state.entries.isEmpty)
          Center(child: Text('No images match the current filter criteria'))
        else
          Column(
            children: [
              // View selector with animated highlight
              _buildAnimatedSegmentedControl(
                context,
                state.selectedView,
                viewModel,
              ),
              const SizedBox(height: 16),
              // Image display - Updated with card-like appearance and fixed height
              Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.5, // Fixed height for image container
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildImageDisplay(context, ref, viewModel),
                ),
              ),

              // Date and weight display - Updated with modern styling
              if (currentEntry != null)
                Container(
                  margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MM/dd/yyyy').format(currentEntry.date),
                        style: AppTypography.bodyLarge(context).copyWith(
                          color: Theme.of(context).colorScheme.textPrimary,
                        ),
                      ),
                      if (currentEntry.weight != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Weight: ${(unitPreferences.useMetricWeight ? currentEntry.weight! : ref.read(unitConversionProvider.notifier).kgToLb(currentEntry.weight!)).toStringAsFixed(1)} ${unitPreferences.useMetricWeight ? 'kg' : 'lb'}',
                            style: AppTypography.subtitle2(context).copyWith(
                              color: Theme.of(context).colorScheme.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              // Navigation buttons
              Container(
                child: _buildNavigationButtons(context, state, viewModel),
              ),
            ],
          ),
      ],
    );
  }

  /// Builds an animated segmented control with a moving highlight
  /// Uses a stable approach with AnimatedPositioned to prevent shaking
  Widget _buildAnimatedSegmentedControl(
    BuildContext context,
    String selectedView,
    ImageTimelineViewModel viewModel,
  ) {
    // Define the segments
    final segments = [
      {'label': 'Front', 'value': 'front'},
      {'label': 'Side', 'value': 'side'},
      {'label': 'Back', 'value': 'back'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate button width based on available space
        final buttonWidth = (constraints.maxWidth - 32) / 3; // 32 for padding
        final buttonHeight = 40.0; // Fixed reasonable height for buttons
        // Find the selected index
        final selectedIndex = segments.indexWhere(
          (segment) => segment['value'] == selectedView,
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Stack(
            children: [
              // Animated highlight
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: 8.0 + (buttonWidth * selectedIndex),
                top: 0,
                height: buttonHeight, // Fixed height for the highlight
                width: buttonWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(segments.length, (index) {
                  final segment = segments[index];
                  final isSelected = segment['value'] == selectedView;

                  return SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: TextButton(
                      onPressed: () =>
                          viewModel.updateSelectedView(segment['value']!),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 0), // keine Mindestgröße
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        // Wichtig: Kein alignment setzen, damit Text natürlich zentriert wird
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        // Center Widget um den Text, für absolute Zentrierung
                        child: Text(
                          segment['label']!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageDisplay(
    BuildContext context,
    WidgetRef ref,
    ImageTimelineViewModel viewModel,
  ) {
    final imagePath = viewModel.getCurrentImagePath();

    if (imagePath == null) {
      return const Center(child: Text('No image available for this view'));
    }

    return GestureDetector(
      onTap: () {
        // Show export options when image is tapped
        ref
            .read(imageExportProvider.notifier)
            .showExportOptions(context, imagePath);
      },
      child: Image.file(File(imagePath), fit: BoxFit.contain),
    );
  }

  /// Builds navigation buttons for moving between entries
  Widget _buildNavigationButtons(
    BuildContext context,
    ImageTimelineState state,
    ImageTimelineViewModel viewModel,
  ) {
    final availableDates = viewModel.getAvailableDates();

    if (availableDates.isEmpty) {
      return const Text('No images available for this view');
    }

    if (availableDates.length == 1) {
      return Column(
        children: [
          Text('Only one image available for this view'),
          const SizedBox(height: 8),
          Text(DateFormat('MM/dd/yyyy').format(availableDates.first)),
        ],
      );
    }

    // Get the current index and total entries count
    final currentEntry = viewModel.getCurrentEntry();
    int currentDateIndex = 0;

    if (currentEntry != null) {
      for (int i = 0; i < availableDates.length; i++) {
        if (availableDates[i].day == currentEntry.date.day &&
            availableDates[i].month == currentEntry.date.month &&
            availableDates[i].year == currentEntry.date.year) {
          currentDateIndex = i;
          break;
        }
      }
    }

    final bool canGoBack = currentDateIndex > 0;
    final bool canGoForward = currentDateIndex < availableDates.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Jump to earliest entry button
        IconButton(
          icon: const Icon(Icons.first_page, size: 45),
          onPressed: canGoBack
              ? () {
                  // Find the entry with the earliest date
                  for (int i = 0; i < state.entries.length; i++) {
                    final entry = state.entries[i];
                    if (entry.date.day == availableDates.first.day &&
                        entry.date.month == availableDates.first.month &&
                        entry.date.year == availableDates.first.year) {
                      viewModel.updateSelectedIndex(i);
                      break;
                    }
                  }
                }
              : null,
          color: Theme.of(context).colorScheme.primary,
          disabledColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),

        // Previous entry button
        IconButton(
          icon: const Icon(Icons.navigate_before, size: 45),
          onPressed: canGoBack
              ? () {
                  // Find the previous entry
                  final previousDate = availableDates[currentDateIndex - 1];
                  for (int i = 0; i < state.entries.length; i++) {
                    final entry = state.entries[i];
                    if (entry.date.day == previousDate.day &&
                        entry.date.month == previousDate.month &&
                        entry.date.year == previousDate.year) {
                      viewModel.updateSelectedIndex(i);
                      break;
                    }
                  }
                }
              : null,
          color: Theme.of(context).colorScheme.primary,
          disabledColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),

        // Display current position
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${currentDateIndex + 1} / ${availableDates.length}',
            style: AppTypography.bodyLarge(context),
          ),
        ),

        // Next entry button
        IconButton(
          icon: const Icon(Icons.navigate_next, size: 45),
          onPressed: canGoForward
              ? () {
                  // Find the next entry
                  final nextDate = availableDates[currentDateIndex + 1];
                  for (int i = 0; i < state.entries.length; i++) {
                    final entry = state.entries[i];
                    if (entry.date.day == nextDate.day &&
                        entry.date.month == nextDate.month &&
                        entry.date.year == nextDate.year) {
                      viewModel.updateSelectedIndex(i);
                      break;
                    }
                  }
                }
              : null,
          color: Theme.of(context).colorScheme.primary,
          disabledColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),

        // Jump to latest entry button
        IconButton(
          icon: const Icon(Icons.last_page, size: 45),
          onPressed: canGoForward
              ? () {
                  // Find the entry with the latest date
                  for (int i = 0; i < state.entries.length; i++) {
                    final entry = state.entries[i];
                    if (entry.date.day == availableDates.last.day &&
                        entry.date.month == availableDates.last.month &&
                        entry.date.year == availableDates.last.year) {
                      viewModel.updateSelectedIndex(i);
                      break;
                    }
                  }
                }
              : null,
          color: Theme.of(context).colorScheme.primary,
          disabledColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ],
    );
  }
}
