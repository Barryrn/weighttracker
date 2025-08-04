import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../ViewModel/image_timeline_view_model.dart';
import '../theme.dart';

/// A view that displays a timeline of progress images
class ImageTimelineView extends ConsumerWidget {
  const ImageTimelineView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageTimelineProvider);
    final viewModel = ref.read(imageTimelineProvider.notifier);
    final currentEntry = viewModel.getCurrentEntry();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Timeline'),
        backgroundColor: AppColors.primaryVeryLight,
        foregroundColor: AppColors.textPrimary,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : state.entries.isEmpty
                  ? const Center(child: Text('No images available'))
                  : Column(
                      children: [
                        // View selector
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildViewButton(context, 'Front', 'front', state.selectedView, viewModel),
                              _buildViewButton(context, 'Side', 'side', state.selectedView, viewModel),
                              _buildViewButton(context, 'Back', 'back', state.selectedView, viewModel),
                            ],
                          ),
                        ),
                        
                        // Image display
                        Expanded(
                          child: _buildImageDisplay(context, viewModel),
                        ),
                        
                        // Date and weight display
                        if (currentEntry != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('MM/dd/yyyy').format(currentEntry.date),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                if (currentEntry.weight != null)
                                  Text(
                                    'Weight: ${currentEntry.weight!.toStringAsFixed(1)} kg',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                              ],
                            ),
                          ),
                        
                        // Timeline slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                          child: _buildTimelineSlider(context, state, viewModel),
                        ),
                      ],
                    ),
    );
  }

  /// Builds a button for selecting the view type (front, side, back)
  Widget _buildViewButton(BuildContext context, String label, String viewType, 
                          String selectedView, ImageTimelineViewModel viewModel) {
    final isSelected = viewType == selectedView;
    
    return ElevatedButton(
      onPressed: () => viewModel.updateSelectedView(viewType),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }

  /// Builds the image display area
  Widget _buildImageDisplay(BuildContext context, ImageTimelineViewModel viewModel) {
    final imagePath = viewModel.getCurrentImagePath();
    
    if (imagePath == null) {
      return const Center(
        child: Text('No image available for this view'),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Builds the timeline slider
  Widget _buildTimelineSlider(BuildContext context, ImageTimelineState state, 
                             ImageTimelineViewModel viewModel) {
    // Get available dates for the selected view
    final availableDates = viewModel.getAvailableDates();
    
    if (availableDates.isEmpty) {
      return const Text('No images available for this view');
    }
    
    // Find the index of the current entry in the available dates
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
    
    return Column(
      children: [
        Slider(
          min: 0,
          max: availableDates.length - 1.0,
          divisions: availableDates.length - 1,
          value: currentDateIndex.toDouble(),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withOpacity(0.3),
          onChanged: (value) {
            // Find the entry with this date
            final date = availableDates[value.round()];
            for (int i = 0; i < state.entries.length; i++) {
              final entry = state.entries[i];
              if (entry.date.day == date.day &&
                  entry.date.month == date.month &&
                  entry.date.year == date.year) {
                viewModel.updateSelectedIndex(i);
                break;
              }
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MM/dd/yyyy').format(availableDates.last)),
            Text(DateFormat('MM/dd/yyyy').format(availableDates.first)),
          ],
        ),
      ],
    );
  }
}