import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weigthtracker/model/body_entry_model.dart'; // Changed from Model to model
import '../viewmodel/image_comparison_provider.dart';
import '../theme.dart';
import '../ViewModel/image_export_view_model.dart';

/// A view that displays all images in a grid with filtering options
class ImageGalleryView extends ConsumerStatefulWidget {
  const ImageGalleryView({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageGalleryView> createState() => _ImageGalleryViewState();
}

class _ImageGalleryViewState extends ConsumerState<ImageGalleryView> {
  // Filter state
  RangeValues? _weightRange;
  DateTimeRange? _dateRange;
  List<String> _selectedTags = [];
  bool _showFilters = false;

  // Image type filters
  bool _showFrontImages = true;
  bool _showSideImages = true;
  bool _showBackImages = true;

  @override
  void initState() {
    super.initState();
    // Ensure data is loaded when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageComparisonProvider.notifier).loadEntries().then((_) {
        // Load all available tags for filtering
        _loadAllTags();
        // Initialize date range based on latest entry
        _initializeDateRange();
      });
    });
  }

  // Initialize date range based on latest entry
  void _initializeDateRange() {
    final entriesState = ref.read(imageComparisonProvider);
    entriesState.whenData((entries) {
      if (entries.isNotEmpty) {
        // Find the latest entry date
        final latestDate = entries
            .map((e) => e.date)
            .reduce((a, b) => a.isAfter(b) ? a : b);

        setState(() {
          _dateRange = DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 365)),
            end: latestDate.isAfter(DateTime.now())
                ? latestDate
                : DateTime.now(),
          );
        });
      }
    });
  }

  // All available tags for filtering
  List<String> _allTags = [];

  // Load all unique tags from entries
  void _loadAllTags() {
    final entriesState = ref.read(imageComparisonProvider);
    entriesState.whenData((entries) {
      final tags = <String>{};
      for (final entry in entries) {
        if (entry.tags != null) {
          tags.addAll(entry.tags!);
        }
      }
      setState(() {
        _allTags = tags.toList();
      });
    });
  }

  /// Filter entries based on current filter settings
  List<BodyEntry> _filterEntries(List<BodyEntry> entries) {
    // If filters aren't active, return all entries with images
    if (!_filtersActive) {
      return entries.where((entry) {
        return entry.frontImagePath != null ||
            entry.sideImagePath != null ||
            entry.backImagePath != null;
      }).toList();
    }

    // Otherwise apply all filters
    return entries.where((entry) {
      // Weight filter
      if (_weightRange != null && entry.weight != null) {
        if (entry.weight! < _weightRange!.start ||
            entry.weight! > _weightRange!.end) {
          return false;
        }
      }

      // Date filter
      if (_dateRange != null) {
        if (entry.date.isBefore(_dateRange!.start) ||
            entry.date.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      // Tags filter
      if (_selectedTags.isNotEmpty) {
        if (entry.tags == null ||
            !_selectedTags.any((tag) => entry.tags!.contains(tag))) {
          return false;
        }
      }

      // Image type filter - Check if entry has at least one image type that's enabled
      bool hasValidImage = false;

      if (_showFrontImages && entry.frontImagePath != null) {
        hasValidImage = true;
      }
      if (_showSideImages && entry.sideImagePath != null) {
        hasValidImage = true;
      }
      if (_showBackImages && entry.backImagePath != null) {
        hasValidImage = true;
      }

      return hasValidImage;
    }).toList();
  }

  /// Get all available images from an entry based on filter settings
  List<Map<String, dynamic>> _getAvailableImages(BodyEntry entry) {
    List<Map<String, dynamic>> images = [];

    if (_showFrontImages && entry.frontImagePath != null) {
      images.add({
        'path': entry.frontImagePath!,
        'type': 'Front',
        'entry': entry,
      });
    }
    if (_showSideImages && entry.sideImagePath != null) {
      images.add({
        'path': entry.sideImagePath!,
        'type': 'Side',
        'entry': entry,
      });
    }
    if (_showBackImages && entry.backImagePath != null) {
      images.add({
        'path': entry.backImagePath!,
        'type': 'Back',
        'entry': entry,
      });
    }

    return images;
  }

  // Add this flag to track if filters should be applied
  bool _filtersActive = false;

  @override
  Widget build(BuildContext context) {
    final entriesState = ref.watch(imageComparisonProvider);

    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image Gallery',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Filter toggle button
            IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                  // Don't apply filters when just toggling the filter UI visibility
                  if (!_showFilters) {
                    // Reset filters when hiding the filter UI
                    _filtersActive = false;
                    _clearFilters();
                  }
                });
              },
            ),
          ],
        ),
        backgroundColor: AppColors.background2,
        body: Column(
          children: [
            // Filter section
            if (_showFilters) _buildFilterSection(),

            // Gallery grid
            Expanded(
              child: entriesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('Error loading images: $error')),
                data: (entries) {
                  // Filter entries based on current filter settings
                  final filteredEntries = _filterEntries(entries);

                  // Get all available images from filtered entries
                  final allImages = <Map<String, dynamic>>[];
                  for (final entry in filteredEntries) {
                    allImages.addAll(_getAvailableImages(entry));
                  }

                  if (allImages.isEmpty) {
                    return const Center(
                      child: Text('No images match the current filters'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
        ),
      ),
    );
  }

  /// Builds the filter section with weight range, date range, and tag filters
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image type filter
          _buildImageTypeFilter(),
          const SizedBox(height: 16),
          // Weight range filter
          _buildWeightRangeFilter(),
          const SizedBox(height: 16),

          // Date range filter
          _buildDateRangeFilter(),
          const SizedBox(height: 16),

          // Tags filter
          if (_allTags.isNotEmpty) _buildTagsFilter(),
          const SizedBox(height: 16),

          // Filter action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Clear filters button
              TextButton(
                onPressed: () {
                  setState(() {
                    _filtersActive = false;
                    _clearFilters();
                  });
                },
                child: const Text('Clear Filters'),
              ),
              const SizedBox(width: 8),
              // Apply filters button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filtersActive = true; // Activate filters
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the weight range filter
  Widget _buildWeightRangeFilter() {
    // Get min and max weights from entries
    double minWeight = 40.0; // Default min
    double maxWeight = 120.0; // Default max

    final entriesState = ref.read(imageComparisonProvider);
    entriesState.whenData((entries) {
      final weights = entries
          .where((e) => e.weight != null)
          .map((e) => e.weight!)
          .toList();

      if (weights.isNotEmpty) {
        weights.sort();
        minWeight = weights.first;
        maxWeight = weights.last;

        // Apply the formula for min weight: n - (n % 5)
        int minWeightInt = minWeight.toInt();
        minWeight = (minWeightInt - (minWeightInt % 5)).toDouble();
        // Subtract additional 5 if the weight is exactly on a 5 kg interval
        if (minWeight == minWeightInt.toDouble()) {
          minWeight -= 5;
        }

        // Apply the formula for max weight: n + (5 - n % 5) % 5
        int maxWeightInt = maxWeight.toInt();
        maxWeight = (maxWeightInt + (5 - maxWeightInt % 5) % 5).toDouble();
        // Add additional 5 if the weight is exactly on a 5 kg interval
        if (maxWeight == maxWeightInt.toDouble()) {
          maxWeight += 5;
        }
      }
    });

    // Ensure min and max are different to avoid division by zero
    if (minWeight >= maxWeight) {
      maxWeight = minWeight + 5.0;
    }

    // Initialize weight range if not set or ensure it's within bounds
    if (_weightRange == null) {
      _weightRange = RangeValues(minWeight, maxWeight);
    } else {
      // Ensure the range values are within bounds
      double start = _weightRange!.start;
      double end = _weightRange!.end;

      // Clamp values to ensure they're within min and max
      start = start.clamp(minWeight, maxWeight);
      end = end.clamp(minWeight, maxWeight);

      // Ensure start <= end
      if (start > end) {
        start = end;
      }

      _weightRange = RangeValues(start, end);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight Range (kg)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(_weightRange!.start.toStringAsFixed(1)),
            Expanded(
              child: RangeSlider(
                values: _weightRange!,
                min: minWeight,
                max: maxWeight,
                divisions: ((maxWeight - minWeight) * 10).round(),
                labels: RangeLabels(
                  _weightRange!.start.toStringAsFixed(1),
                  _weightRange!.end.toStringAsFixed(1),
                ),
                onChanged: (values) {
                  setState(() {
                    _weightRange = values;
                  });
                },
              ),
            ),
            Text(_weightRange!.end.toStringAsFixed(1)),
          ],
        ),
      ],
    );
  }

  /// Builds the date range filter
  Widget _buildDateRangeFilter() {
    // Initialize date range if not set
    _dateRange ??= DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 365)),
      end: DateTime.now(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _selectDateRange,
                child: Text(
                  _dateRange != null
                      ? '${DateFormat('MMM d, y').format(_dateRange!.start)} - '
                            '${DateFormat('MMM d, y').format(_dateRange!.end)}'
                      : 'Select Date Range',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Shows date range picker
  Future<void> _selectDateRange() async {
    final initialRange =
        _dateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        );

    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2000),
      // Allow selection of future dates (100 years into the future should be enough)
      lastDate: DateTime.now().add(const Duration(days: 36500)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() {
        _dateRange = newRange;
      });
    }
  }

  /// Builds the tags filter
  Widget _buildTagsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the image type filter
  Widget _buildImageTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image Types',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilterChip(
              label: const Text('Front'),
              selected: _showFrontImages,
              onSelected: (selected) {
                setState(() {
                  _showFrontImages = selected;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
            FilterChip(
              label: const Text('Side'),
              selected: _showSideImages,
              onSelected: (selected) {
                setState(() {
                  _showSideImages = selected;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
            FilterChip(
              label: const Text('Back'),
              selected: _showBackImages,
              onSelected: (selected) {
                setState(() {
                  _showBackImages = selected;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _weightRange = null;
      _dateRange = null;
      _selectedTags = [];
      _showFrontImages = true;
      _showSideImages = true;
      _showBackImages = true;
    });
  }

  /// Builds a card displaying an image with metadata
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
                color: AppColors.primary.withOpacity(0.3),
                width: 3,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
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
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(
                  left: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                  right: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                  bottom: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                  // kein BorderSide für top, also keine obere Linie
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
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        displayViewType,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Weight
                  Text(
                    entry.weight != null
                        ? '${entry.weight!.toStringAsFixed(1)} kg'
                        : 'No weight data',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(fontSize: 10),
                            ),
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
                        child: const Text(
                          'Pic 1',
                          style: TextStyle(
                            fontSize: 16,
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
                        child: const Text(
                          'Pic 2',
                          style: TextStyle(
                            fontSize: 16,
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

  /// Shows options for the image when tapped
  void _showImageOptions(
    BuildContext context,
    ProgressImageEntry progressEntry,
    BodyEntry originalEntry,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Export to Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await ref
                      .read(imageExportProvider.notifier)
                      .exportImageToGallery(progressEntry.imagePath);
                  if (context.mounted) {
                    final state = ref.read(imageExportProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.isSuccess
                              ? 'Image saved to gallery'
                              : state.errorMessage ?? 'Failed to save image',
                        ),
                      ),
                    );
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Saves the image to the gallery
  Future<void> _saveImageToGallery(
    BuildContext context,
    String imagePath,
  ) async {
    try {
      // Check if we have permission
      final status = await Permission.photos.request();
      if (status.isGranted) {
        // Read the file
        final file = File(imagePath);
        final bytes = await file.readAsBytes();

        // Save to gallery
        final result = await ImageGallerySaver.saveImage(bytes);

        // Show success message
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to save image')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to save images')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
    }
  }
}
