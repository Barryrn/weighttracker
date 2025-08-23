import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/viewmodel/unit_conversion_provider.dart';
import '../ViewModel/image_gallery_view_model.dart';
import '../theme.dart';

/// A widget that provides filtering options for the image gallery view
class ImageGalleryFilter extends ConsumerWidget {
  const ImageGalleryFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(imageGalleryFilterProvider);
    final filterNotifier = ref.read(imageGalleryFilterProvider.notifier);
    final unitPreferences = ref.watch(unitConversionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.card,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.border),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image type filter
          _buildImageTypeFilter(context, filterState, filterNotifier),
          const SizedBox(height: 16),

          // Weight range filter
          _buildWeightRangeFilter(
            context,
            filterState,
            filterNotifier,
            unitPreferences,
            ref,
          ),
          const SizedBox(height: 16),

          // Date range filter
          _buildDateRangeFilter(context, filterState, filterNotifier),
          const SizedBox(height: 16),

          // Tags filter
          if (filterState.allTags.isNotEmpty)
            _buildTagsFilter(context, filterState, filterNotifier),
          const SizedBox(height: 16),

          // Filter action buttons with sorting dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sort dropdown button - Make it flexible
              Flexible(
                flex: 2,
                child: Container(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _getSortDisplayValue(
                        filterState.sortBy,
                        filterState.sortOrder,
                      ),
                      hint: Text(
                        AppLocalizations.of(context)!.sortBy,
                        style: AppTypography.buttonText(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      style: AppTypography.buttonText(
                        context,
                      ).copyWith(color: Theme.of(context).colorScheme.primary),
                      isExpanded:
                          true, // Make dropdown take full width of its container
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _handleSortSelection(newValue, filterNotifier);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'date_ascending',
                          child: Text(
                            AppLocalizations.of(context)!.dateAscending,
                            style: AppTypography.buttonText(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'date_descending',
                          child: Text(
                            AppLocalizations.of(context)!.dateDescending,
                            style: AppTypography.buttonText(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'weight_ascending',
                          child: Text(
                            AppLocalizations.of(context)!.weightAscending,
                            style: AppTypography.buttonText(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'weight_descending',
                          child: Text(
                            AppLocalizations.of(context)!.weightDescending,
                            style: AppTypography.buttonText(context).copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Add some spacing
              // Clear filters button - Make it flexible
              Flexible(
                flex: 1,
                child: TextButton(
                  onPressed: () => filterNotifier.clearFilters(),
                  style: TextButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.clearFilters,
                    style: AppTypography.buttonText(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the image type filter
  Widget _buildImageTypeFilter(
    BuildContext context,
    ImageGalleryFilterState filterState,
    ImageGalleryFilterNotifier filterNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.imageTypes,
          style: AppTypography.subtitle1(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: Center(
                  child: Text(
                    AppLocalizations.of(context)!.frontCapital,
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                ),
                selected: filterState.showFrontImages,
                onSelected: (selected) =>
                    filterNotifier.setShowFrontImages(selected),
                backgroundColor: Theme.of(context).colorScheme.card,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: Center(
                  child: Text(
                    AppLocalizations.of(context)!.sideCapital,
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                ),
                selected: filterState.showSideImages,
                onSelected: (selected) =>
                    filterNotifier.setShowSideImages(selected),
                backgroundColor: Theme.of(context).colorScheme.card,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterChip(
                label: Center(
                  child: Text(
                    AppLocalizations.of(context)!.backCapital,
                    style: AppTypography.bodyLarge(context).copyWith(
                      color: Theme.of(context).colorScheme.textPrimary,
                    ),
                  ),
                ),
                selected: filterState.showBackImages,
                onSelected: (selected) =>
                    filterNotifier.setShowBackImages(selected),
                backgroundColor: Theme.of(context).colorScheme.card,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the weight range filter
  Widget _buildWeightRangeFilter(
    BuildContext context,
    ImageGalleryFilterState filterState,
    ImageGalleryFilterNotifier filterNotifier,
    UnitPreferences unitPreferences,
    WidgetRef ref,
  ) {
    // Get dynamic min and max weights from filter state
    double minWeight = filterState.minWeight;
    double maxWeight = filterState.maxWeight;

    // Ensure min and max are different to avoid division by zero
    if (minWeight >= maxWeight) {
      maxWeight = minWeight + 5.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)!.weightRange} (${unitPreferences.useMetricWeight ? 'kg' : 'lb'})',
          style: AppTypography.subtitle1(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              (unitPreferences.useMetricWeight
                      ? filterState.weightRange.start
                      : ref
                            .read(unitConversionProvider.notifier)
                            .kgToLb(filterState.weightRange.start))
                  .toStringAsFixed(1),
              style: AppTypography.bodyLarge(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  valueIndicatorTextStyle: AppTypography.bodyLarge(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: RangeSlider(
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Theme.of(context).colorScheme.primaryLight,
                  values: filterState.weightRange,
                  min: minWeight,
                  max: maxWeight,
                  divisions: ((maxWeight - minWeight) * 10).round(),
                  labels: RangeLabels(
                    filterState.weightRange.start.toStringAsFixed(1),
                    filterState.weightRange.end.toStringAsFixed(1),
                  ),
                  onChanged: (values) => filterNotifier.setWeightRange(values),
                ),
              ),
            ),
            Text(
              (unitPreferences.useMetricWeight
                      ? filterState.weightRange.end
                      : ref
                            .read(unitConversionProvider.notifier)
                            .kgToLb(filterState.weightRange.end))
                  .toStringAsFixed(1),
              style: AppTypography.bodyLarge(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the date range filter
  Widget _buildDateRangeFilter(
    BuildContext context,
    ImageGalleryFilterState filterState,
    ImageGalleryFilterNotifier filterNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.dateRange,
          style: AppTypography.subtitle1(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primaryLight,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () =>
                    _selectDateRange(context, filterState, filterNotifier),
                child: Text(
                  filterState.dateRange != null
                      ? '${DateFormat('MMM d, y').format(filterState.dateRange!.start)} - '
                            '${DateFormat('MMM d, y').format(filterState.dateRange!.end)}'
                      : AppLocalizations.of(context)!.selectDateRange,
                  style: AppTypography.bodyLarge(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Shows date range picker
  Future<void> _selectDateRange(
    BuildContext context,
    ImageGalleryFilterState filterState,
    ImageGalleryFilterNotifier filterNotifier,
  ) async {
    // Only provide initial range if dateRange is null - this is just for the picker UI
    final initialRange =
        filterState.dateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        );

    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 36500)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.textPrimary,
              background: Theme.of(context).colorScheme.background,
              surface: Theme.of(context).colorScheme.surface,
              onBackground: Theme.of(context).colorScheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      filterNotifier.setDateRange(newRange);
    }
  }

  /// Builds the tags filter
  Widget _buildTagsFilter(
    BuildContext context,
    ImageGalleryFilterState filterState,
    ImageGalleryFilterNotifier filterNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.tags,
          style: AppTypography.subtitle1(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filterState.allTags.map((tag) {
            final isSelected = filterState.selectedTags.contains(tag);
            return FilterChip(
              label: Text(
                tag,
                style: AppTypography.bodyLarge(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
              ),
              selected: isSelected,
              onSelected: (selected) => filterNotifier.toggleTag(tag),
              backgroundColor: Theme.of(context).colorScheme.card,
              selectedColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Get the current sort display value based on sort option and order
String _getSortDisplayValue(SortOption sortBy, SortOrder sortOrder) {
  switch (sortBy) {
    case SortOption.date:
      return sortOrder == SortOrder.ascending
          ? 'date_ascending'
          : 'date_descending';
    case SortOption.weight:
      return sortOrder == SortOrder.ascending
          ? 'weight_ascending'
          : 'weight_descending';
  }
}

/// Handle sort selection from dropdown
void _handleSortSelection(
  String value,
  ImageGalleryFilterNotifier filterNotifier,
) {
  switch (value) {
    case 'date_ascending':
      filterNotifier.setSortBy(SortOption.date);
      filterNotifier.setSortOrder(SortOrder.ascending);
      break;
    case 'date_descending':
      filterNotifier.setSortBy(SortOption.date);
      filterNotifier.setSortOrder(SortOrder.descending);
      break;
    case 'weight_ascending':
      filterNotifier.setSortBy(SortOption.weight);
      filterNotifier.setSortOrder(SortOrder.ascending);
      break;
    case 'weight_descending':
      filterNotifier.setSortBy(SortOption.weight);
      filterNotifier.setSortOrder(SortOrder.descending);
      break;
  }
}
