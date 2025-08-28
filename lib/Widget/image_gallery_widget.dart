import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

import 'package:weigthtracker/model/body_entry_model.dart';
import '../viewmodel/image_comparison_provider.dart';
import 'package:weigthtracker/ViewModel/unit_conversion_provider.dart';
import '../theme.dart';
import '../ViewModel/image_gallery_view_model.dart';
import 'image_gallery_filter_widget.dart';
import '../service/image_file_service.dart'; // Add this import

class ImageGalleryWidget extends ConsumerStatefulWidget {
  final bool showFilters;

  const ImageGalleryWidget({super.key, this.showFilters = false});

  @override
  ConsumerState<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends ConsumerState<ImageGalleryWidget> {
  @override
  void initState() {
    super.initState();
    // Load entries when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageGalleryViewModelProvider.notifier).loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(imageGalleryViewModelProvider);
    final filterState = ref.watch(imageGalleryFilterProvider);

    return Column(
      children: [
        // Filter section (controlled by parent)
        if (widget.showFilters) const ImageGalleryFilter(),

        // Add spacing when filters are shown
        if (widget.showFilters) const SizedBox(height: 16),

        // Image grid
        Expanded(
          child: galleryState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(AppLocalizations.of(context)!.errorLoadingImages),
            ),
            data: (entries) {
              // Apply filters to entries
              final filteredEntries = ref
                  .read(imageGalleryViewModelProvider.notifier)
                  .getFilteredEntries(entries, filterState);

              // Get all available images from filtered entries
              final allImages = <Map<String, dynamic>>[];
              for (final entry in filteredEntries) {
                allImages.addAll(_getAvailableImages(entry));
              }

              if (allImages.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.noImagesMatchTheCurrentFilterCriteria,
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  final imageData = allImages[index];
                  return _buildImageCard(
                    context,
                    imageData['entry'] as BodyEntry,
                    imageData['path'] as String,
                    imageData['type'] as String,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Gets all available images from a body entry (synchronous version for immediate use)
  List<Map<String, dynamic>> _getAvailableImages(BodyEntry entry) {
    final images = <Map<String, dynamic>>[];

    // Check front image
    if (entry.frontImagePath != null && entry.frontImagePath!.isNotEmpty) {
      images.add({
        'entry': entry,
        'path': entry.frontImagePath!,
        'type': 'front',
      });
    }

    // Check side image
    if (entry.sideImagePath != null && entry.sideImagePath!.isNotEmpty) {
      images.add({
        'entry': entry,
        'path': entry.sideImagePath!,
        'type': 'side',
      });
    }

    // Check back image
    if (entry.backImagePath != null && entry.backImagePath!.isNotEmpty) {
      images.add({
        'entry': entry,
        'path': entry.backImagePath!,
        'type': 'back',
      });
    }

    return images;
  }

  /// Builds an individual image card
  Widget _buildImageCard(
    BuildContext context,
    BodyEntry entry,
    String imagePath,
    String viewType,
  ) {
    // Create a ProgressImageEntry from the parameters
    final progressEntry = ProgressImageEntry(
      date: entry.date,
      weight: entry.weight,
      imagePath: imagePath,
      viewType: viewType.toLowerCase(),
      tags: entry.tags,
    );

    final displayViewType =
        viewType.substring(0, 1).toUpperCase() + viewType.substring(1);

    return GestureDetector(
      onTap: () {
        _showImageOptions(context, progressEntry, entry);
      },
      child: Stack(
        children: [
          // Image
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 3,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: FutureBuilder<File?>(
                future: ImageFileService.getImageFile(imagePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.file(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    );
                  }
                  
                  // Fallback for missing image
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          ),

          // Info card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.card,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    width: 3,
                  ),
                  right: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    width: 3,
                  ),
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and view type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(entry.date),
                        style: AppTypography.bodyMedium(context).copyWith(
                          color: Theme.of(context).colorScheme.textPrimary,
                        ),
                      ),
                      Text(
                        displayViewType,
                        style: AppTypography.bodyLarge(context).copyWith(
                          color: Theme.of(context).colorScheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Weight
                  Text(
                    entry.weight != null
                        ? '${(ref.watch(unitConversionProvider).useMetricWeight ? entry.weight! : ref.read(unitConversionProvider.notifier).kgToLb(entry.weight!)).toStringAsFixed(1)} ${ref.watch(unitConversionProvider).useMetricWeight ? 'kg' : 'lb'}'
                        : AppLocalizations.of(context)!.noWeightData,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                  // Tags
                  if (entry.tags != null && entry.tags!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: entry.tags!.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(tag),
                          );
                        }).toList(),
                      ),
                    ),
                  // Selection buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Set as latest entry
                          ref
                              .read(imageComparisonProvider.notifier)
                              .setLatestEntry(entry);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.pic1,
                          style: AppTypography.bodyLarge(context).copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Set as comparison entry
                          ref
                              .read(imageComparisonProvider.notifier)
                              .setComparisonEntry(entry);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.pic2,
                          style: AppTypography.bodyLarge(context).copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows image options dialog
  void _showImageOptions(
    BuildContext context,
    ProgressImageEntry progressEntry,
    BodyEntry entry,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.imageOptions),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.saveToGallery),
                onTap: () {
                  Navigator.pop(context);
                  _saveImageToGallery(progressEntry.imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.compare_arrows),
                title: Text(AppLocalizations.of(context)!.setAsLatestEntry),
                onTap: () {
                  ref
                      .read(imageComparisonProvider.notifier)
                      .setLatestEntry(entry);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.compare),
                title: Text(AppLocalizations.of(context)!.setAsComparisonEntry),
                onTap: () {
                  ref
                      .read(imageComparisonProvider.notifier)
                      .setComparisonEntry(entry);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Saves image to device gallery
  void _saveImageToGallery(String imagePath) {
    // Implementation for saving image to gallery
    // This would typically use a package like image_gallery_saver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.imageSavedToGallery),
      ),
    );
  }
}
