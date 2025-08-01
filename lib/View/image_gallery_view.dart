import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/body_entry_model.dart';
import '../viewmodel/image_comparison_provider.dart';
import '../theme.dart';

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
      });
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

  @override
  Widget build(BuildContext context) {
    final entriesState = ref.watch(imageComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        backgroundColor: AppColors.primaryVeryLight,
        foregroundColor: AppColors.textPrimary,
        actions: [
          // Filter toggle button
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
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
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
              const SizedBox(width: 8),
              // Apply filters button
              // ElevatedButton(
              //   onPressed: () {
              //     setState(() {}); // Trigger rebuild to apply filters
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppColors.primary,
              //     foregroundColor: Colors.white,
              //   ),
              //   child: const Text('Apply Filters'),
              // ),
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
      lastDate: DateTime.now(),
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: FutureBuilder<bool>(
              future: File(imagePath).exists(),
              builder: (context, snapshot) {
                final exists = snapshot.data ?? false;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (exists) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                  );
                } else {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  );
                }
              },
            ),
          ),
          // Metadata
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
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
                    Text(viewType, style: const TextStyle(fontSize: 12)),
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
        ],
      ),
    );
  }
}
