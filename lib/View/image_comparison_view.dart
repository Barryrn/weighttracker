import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/View/body_entry_sheet_view.dart';
import 'package:weigthtracker/View/image_timeline_view.dart';
import '../model/body_entry_model.dart';
import '../viewmodel/image_comparison_provider.dart';
import '../viewmodel/unit_conversion_provider.dart'; // Add this import
import '../theme.dart';
import 'image_gallery_view.dart';
import '../service/image_file_service.dart'; // Add this import

/// A view that displays two images side by side for comparison
class ImageComparisonView extends ConsumerStatefulWidget {
  const ImageComparisonView({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageComparisonView> createState() =>
      _ImageComparisonViewState();
}

class _ImageComparisonViewState extends ConsumerState<ImageComparisonView> {
  // Selected image type for each card
  String _leftImageType = 'front';
  String _rightImageType = 'front';

  @override
  Widget build(BuildContext context) {
    final comparisonState = ref.watch(imageComparisonProvider);
    return Card(
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      color: Theme.of(context).colorScheme.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            comparisonState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(AppLocalizations.of(context)!.errorLoadingImages),
              ),
              data: (entries) {
                final latestEntry = ref
                    .read(imageComparisonProvider.notifier)
                    .latestEntry;
                final comparisonEntry = ref
                    .read(imageComparisonProvider.notifier)
                    .comparisonEntry;

                // Check if there are any images available on the device
                final hasAnyImages = entries.any(
                  (entry) =>
                      entry.frontImagePath != null ||
                      entry.sideImagePath != null ||
                      entry.backImagePath != null,
                );

                if (!hasAnyImages) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noImagesAvailable,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.pleaseUploadImagesToTrackYourProgress,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              BodyEntrySheet.show(context: context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.uploadImages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (latestEntry == null) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.uploadImages),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Comparison header
                      Text(
                        AppLocalizations.of(context)!.compareYourProgress,
                        style: AppTypography.headline3(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Image comparison section
                      Row(
                        children: [
                          // Latest image (left side)
                          Expanded(
                            child: _buildImageCard(
                              context: context,
                              entry: latestEntry,
                              title: AppLocalizations.of(context)!.pic1,
                              subtitle: _formatDate(latestEntry.date),
                              weight: latestEntry.weight,
                              imageType: _leftImageType,
                              onImageTypeChanged: (type) {
                                setState(() {
                                  _leftImageType = type;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Comparison image (right side)
                          Expanded(
                            child: comparisonEntry != null
                                ? _buildImageCard(
                                    context: context,
                                    entry: comparisonEntry,
                                    title: AppLocalizations.of(context)!.pic2,
                                    subtitle: _formatDate(comparisonEntry.date),
                                    weight: comparisonEntry.weight,
                                    imageType: _rightImageType,
                                    onImageTypeChanged: (type) {
                                      setState(() {
                                        _rightImageType = type;
                                      });
                                    },
                                  )
                                : _buildNoComparisonCard(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // View all images button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImageGalleryView(),
                            ),
                          ).then((_) {
                            // Refresh the view when returning from gallery
                            setState(() {});
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Square corners
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.viewAllImages,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImageTimelineView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryDark,

                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primaryDark,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.imageTimeline,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card displaying an image with metadata
  Widget _buildImageCard({
    required BuildContext context,
    required BodyEntry entry,
    required String title,
    required String subtitle,
    double? weight,
    required String imageType,
    required Function(String) onImageTypeChanged,
  }) {
    // Determine which image to show based on selected type
    String? imagePath;
    if (imageType == AppLocalizations.of(context)!.frontCapital &&
        entry.frontImagePath != null) {
      imagePath = entry.frontImagePath;
    } else if (imageType == AppLocalizations.of(context)!.sideCapital &&
        entry.sideImagePath != null) {
      imagePath = entry.sideImagePath;
    } else if (imageType == AppLocalizations.of(context)!.backCapital &&
        entry.backImagePath != null) {
      imagePath = entry.backImagePath;
    } else {
      // Fallback to any available image if the selected type is not available
      if (entry.frontImagePath != null) {
        imagePath = entry.frontImagePath;
        imageType = AppLocalizations.of(context)!.frontCapital;
      } else if (entry.sideImagePath != null) {
        imagePath = entry.sideImagePath;
        imageType = AppLocalizations.of(context)!.sideCapital;
      } else if (entry.backImagePath != null) {
        imagePath = entry.backImagePath;
        imageType = AppLocalizations.of(context)!.backCapital;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImageGalleryView()),
        ).then((_) {
          // Refresh the view when returning from gallery
          setState(() {});
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.info.withOpacity(0.3), // subtle blue border
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.zero, // Prevent double padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image header
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    Text(title, style: AppTypography.bodyLarge(context)),
                    Text(subtitle, style: AppTypography.bodyMedium(context)),
                  ],
                ),
              ),
              // Image type selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    _buildImageTypeButton(
                      AppLocalizations.of(context)!.frontCapital,
                      AppLocalizations.of(context)!.front,
                      imageType,
                      entry.frontImagePath != null,
                      onImageTypeChanged,
                    ),
                    _buildImageTypeButton(
                      AppLocalizations.of(context)!.sideCapital,
                      AppLocalizations.of(context)!.side,
                      imageType,
                      entry.sideImagePath != null,
                      onImageTypeChanged,
                    ),
                    _buildImageTypeButton(
                      AppLocalizations.of(context)!.backCapital,
                      AppLocalizations.of(context)!.back,
                      imageType,
                      entry.backImagePath != null,
                      onImageTypeChanged,
                    ),
                  ],
                ),
              ),
              // Image
              if (imagePath != null)
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: FutureBuilder<bool>(
                    future: File(imagePath).exists(),
                    builder: (context, snapshot) {
                      final exists = snapshot.data ?? false;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (exists) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 64),
                        );
                      }
                    },
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    child: const Icon(Icons.no_photography, size: 64),
                  ),
                ),
              // Weight info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  weight != null
                      ? '${(ref.watch(unitConversionProvider).useMetricWeight ? weight : ref.read(unitConversionProvider.notifier).kgToLb(weight)).toStringAsFixed(1)} ${ref.watch(unitConversionProvider).useMetricWeight ? 'kg' : 'lb'}'
                      : AppLocalizations.of(context)!.noWeightData,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a button for selecting image type
  Widget _buildImageTypeButton(
    String label,
    String type,
    String currentType,
    bool isAvailable,
    Function(String) onChanged,
  ) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5,
      child: TextButton(
        onPressed: isAvailable ? () => onChanged(type) : null,
        style: TextButton.styleFrom(
          backgroundColor: currentType == type
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ), // Reduced from 8 to 6
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Square corners
          ),
        ),
        child: Text(
          label, 
          style: AppTypography.bodySmall(context).copyWith(
            color: isAvailable 
                ? Theme.of(context).colorScheme.primary 
                : null, // Use default color for disabled buttons
          ),
        ),
      ),
    );
  }

  /// Builds a card for when no comparison image is available
  Widget _buildNoComparisonCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.noComparison,
                  style: AppTypography.bodyMedium(context),
                ),
                Text(
                  AppLocalizations.of(context)!.addMoreEntries,
                  style: AppTypography.bodySmall(context),
                ),
              ],
            ),
          ),
          // Placeholder
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.add_photo_alternate, size: 64),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.noSimilarWeightEntryFound,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a date as a string
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  /// Preload images to ensure they're available when needed
  Future<void> _preloadImages() async {
    final comparisonNotifier = ref.read(imageComparisonProvider.notifier);
    await comparisonNotifier.loadEntries();

    // Access the entries
    final state = ref.read(imageComparisonProvider);
    state.whenData((entries) {
      // Preload images by accessing them
      for (final entry in entries) {
        if (entry.frontImagePath != null) {
          precacheImage(FileImage(File(entry.frontImagePath!)), context);
        }
        if (entry.sideImagePath != null) {
          precacheImage(FileImage(File(entry.sideImagePath!)), context);
        }
        if (entry.backImagePath != null) {
          precacheImage(FileImage(File(entry.backImagePath!)), context);
        }
      }
    });
  }
}
