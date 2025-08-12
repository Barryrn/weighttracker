import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/tag_entry_view_model.dart';

/// A widget that allows users to enter and manage tags for body entries.
///
/// Tags are displayed as chips in a wrap layout and can be removed individually.
/// Users can add new tags by typing them in a text field and pressing enter or
/// the add button.
class TagEntry extends ConsumerWidget {
  /// Creates a TagEntry widget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const TagEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagEntryData = ref.watch(tagEntryProvider);
    final viewModel = ref.read(tagEntryProvider.notifier);
    final tags = tagEntryData.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppTypography.bodyLarge(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display existing tags
              if (tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map((tag) => _buildTagChip(tag, viewModel, context))
                      .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Input field for new tags
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: tagEntryData.tagController,
                      focusNode: tagEntryData.focusNode,
                      decoration: const InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: viewModel.handleSubmitted,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: viewModel.handleAddButtonPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds a chip widget for a tag with a delete button
  Widget _buildTagChip(
    String tag,
    TagEntryViewModel viewModel,
    BuildContext context,
  ) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => viewModel.removeTag(tag),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      labelStyle: AppTypography.subtitle2(
        context,
      ).copyWith(color: Theme.of(context).colorScheme.textPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
