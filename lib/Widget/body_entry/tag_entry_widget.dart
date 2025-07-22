import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/theme.dart';
import '../../ViewModel/entry_form_provider.dart';

/// A widget that allows users to enter and manage tags for body entries.
///
/// Tags are displayed as chips in a wrap layout and can be removed individually.
/// Users can add new tags by typing them in a text field and pressing enter or
/// the add button.
class TagEntry extends ConsumerStatefulWidget {
  /// Creates a TagEntry widget.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const TagEntry({Key? key}) : super(key: key);

  @override
  ConsumerState<TagEntry> createState() => _TagEntryState();
}

class _TagEntryState extends ConsumerState<TagEntry> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Adds a new tag to the list if it's not empty and not already in the list
  void _addTag(String tag) {
    if (tag.isEmpty) return;

    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;

    final currentTags = ref.read(bodyEntryProvider).tags ?? [];

    // Don't add if the tag already exists
    if (currentTags.contains(trimmedTag)) return;

    final updatedTags = List<String>.from(currentTags)..add(trimmedTag);
    ref.read(bodyEntryProvider.notifier).updateTags(updatedTags);
    _controller.clear();
  }

  /// Removes a tag from the list
  void _removeTag(String tag) {
    final currentTags = ref.read(bodyEntryProvider).tags ?? [];
    final updatedTags = List<String>.from(currentTags)..remove(tag);
    ref.read(bodyEntryProvider.notifier).updateTags(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(bodyEntryProvider).tags ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display existing tags
              if (tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) => _buildTagChip(tag)).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Input field for new tags
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Add a tag...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) {
                          // If the controller is empty when finish is pressed, unfocus to dismiss keyboard
                          _focusNode.unfocus();
                        } else {
                          // Otherwise add the tag and keep focus
                          _addTag(value);
                          _focusNode.requestFocus();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    onPressed: () {
                      _addTag(_controller.text);
                      _focusNode.requestFocus();
                    },
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
  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _removeTag(tag),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      labelStyle: const TextStyle(fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}
