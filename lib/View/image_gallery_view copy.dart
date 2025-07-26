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
  String? _selectedImageType; // null means show all image types

  @override
  void initState() {
    super.initState();

    // Use addPostFrameCallback to delay provider modifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force refresh data from database
      _refreshDataFromDatabase();
      // Load all available tags for filtering
      _loadAllTags();
      // Initialize weight range min/max values
    });
  }

  /// Refreshes data from the database
  Future<void> _refreshDataFromDatabase() async {
    // Trigger a reload of all entries from the database
    await ref.read(imageComparisonProvider.notifier).loadEntries();
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
                // Filter entries with images
                var entriesWithImages = entries.where((entry) {
                  if (_selectedImageType == null) {
                    // Show all entries with any image
                    return entry.frontImagePath != null ||
                        entry.sideImagePath != null ||
                        entry.backImagePath != null;
                  } else if (_selectedImageType == 'front') {
                    // Show only entries with front images
                    return entry.frontImagePath != null;
                  } else if (_selectedImageType == 'side') {
                    // Show only entries with side images
                    return entry.sideImagePath != null;
                  } else if (_selectedImageType == 'back') {
                    // Show only entries with back images
                    return entry.backImagePath != null;
                  }
                  return false;
                }).toList();

                if (entriesWithImages.isEmpty) {
                  return const Center(child: Text('No images available'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: entriesWithImages.length,
                  itemBuilder: (context, index) {
                    return _buildImageCard(context, entriesWithImages[index]);
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

          // Clear filters button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the weight range filter
  Widget _buildWeightRangeFilter() {
    // Get min and max weights from entries - only once when initializing
    double minWeight = 40.0; // Default min
    double maxWeight = 120.0; // Default max
    bool initialized = false;

    // Only initialize the min/max weights once
    if (!initialized) {
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
        }
      });

      // Ensure min and max are different to avoid division by zero
      if (minWeight >= maxWeight) {
        maxWeight = minWeight + 1.0;
      }

      initialized = true;
    }

    // Initialize weight range if not set
    if (_weightRange == null) {
      _weightRange = RangeValues(minWeight, maxWeight);
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
                  // Apply filter immediately
                  _applyFilters();
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
      // Apply filter immediately
      _applyFilters();
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
                // Apply filter immediately
                _applyFilters();
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
        const Text('Image Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All images option
            FilterChip(
              label: const Text('All'),
              selected: _selectedImageType == null,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedImageType = null;
                  }
                });
                // Apply filter immediately
                _applyFilters();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
            // Front image option
            FilterChip(
              label: const Text('Front'),
              selected: _selectedImageType == 'front',
              onSelected: (selected) {
                setState(() {
                  _selectedImageType = selected ? 'front' : null;
                });
                // Apply filter immediately
                _applyFilters();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
            // Side image option
            FilterChip(
              label: const Text('Side'),
              selected: _selectedImageType == 'side',
              onSelected: (selected) {
                setState(() {
                  _selectedImageType = selected ? 'side' : null;
                });
                // Apply filter immediately
                _applyFilters();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ),
            // Back image option
            FilterChip(
              label: const Text('Back'),
              selected: _selectedImageType == 'back',
              onSelected: (selected) {
                setState(() {
                  _selectedImageType = selected ? 'back' : null;
                });
                // Apply filter immediately
                _applyFilters();
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

  /// Apply filters to the entries
  void _applyFilters() {
    ref
        .read(imageComparisonProvider.notifier)
        .applyFilters(
          weightRange: _weightRange,
          dateRange: _dateRange,
          tags: _selectedTags.isEmpty ? null : _selectedTags,
        );
  }

  /// Clear all filters
  void _clearFilters() {
    setState(() {
      _weightRange = null;
      _dateRange = null;
      _selectedTags = [];
      _selectedImageType = null;
    });
    ref.read(imageComparisonProvider.notifier).clearFilters();
  }

  /// Builds a card displaying an image with metadata
  Widget _buildImageCard(BuildContext context, BodyEntry entry) {
    // Determine which image to show based on selected image type
    String? imagePath;
    String viewType = '';

    if (_selectedImageType == 'front' && entry.frontImagePath != null) {
      imagePath = entry.frontImagePath;
      viewType = 'Front';
    } else if (_selectedImageType == 'side' && entry.sideImagePath != null) {
      imagePath = entry.sideImagePath;
      viewType = 'Side';
    } else if (_selectedImageType == 'back' && entry.backImagePath != null) {
      imagePath = entry.backImagePath;
      viewType = 'Back';
    } else {
      // Default prioritization if no specific type is selected
      if (entry.frontImagePath != null) {
        imagePath = entry.frontImagePath;
        viewType = 'Front';
      } else if (entry.sideImagePath != null) {
        imagePath = entry.sideImagePath;
        viewType = 'Side';
      } else if (entry.backImagePath != null) {
        imagePath = entry.backImagePath;
        viewType = 'Back';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: imagePath != null
                ? FutureBuilder<bool>(
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
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        );
                      }
                    },
                  )
                : const Center(child: Icon(Icons.no_photography, size: 48)),
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
