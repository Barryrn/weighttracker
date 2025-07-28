import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'entry_form_provider.dart';

/// A data class that holds all the tag entry information.
///
/// This class follows the MVVM pattern by representing the ViewModel's state
/// that will be consumed by the View (TagEntryWidget).
class TagEntryData {
  final List<String> tags;
  final TextEditingController tagController;
  final FocusNode focusNode;

  TagEntryData({
    required this.tags,
    required this.tagController,
    required this.focusNode,
  });
}

/// A ViewModel that manages tag entry information.
///
/// This class follows the MVVM pattern by processing data from the bodyEntryProvider
/// and transforming it into a format that's ready for display in the View.
class TagEntryViewModel extends StateNotifier<TagEntryData> {
  TagEntryViewModel(this.ref) : super(
    TagEntryData(
      tags: [],
      tagController: TextEditingController(),
      focusNode: FocusNode(),
    )
  ) {
    _initializeData();
    
    // Listen for changes in the bodyEntryProvider that affect tags
    ref.listen(bodyEntryProvider, (_, __) => _updateData());
  }

  final Ref ref;

  @override
  void dispose() {
    state.tagController.dispose();
    state.focusNode.dispose();
    super.dispose();
  }

  /// Logs the current state of the tag entry
  void _logState() {
    developer.log('===== Tag Entry ViewModel State =====');
    developer.log('Tags: ${state.tags}');
    developer.log('===================================');
  }

  /// Initializes the data with current values from bodyEntryProvider
  void _initializeData() {
    final bodyEntry = ref.read(bodyEntryProvider);
    final currentTags = bodyEntry.tags ?? [];

    // Update state
    state = TagEntryData(
      tags: currentTags,
      tagController: state.tagController,
      focusNode: state.focusNode,
    );

    _logState();
  }

  /// Updates the data when the underlying bodyEntry changes
  void _updateData() {
    final bodyEntry = ref.read(bodyEntryProvider);
    final currentTags = bodyEntry.tags ?? [];

    // Update state
    state = TagEntryData(
      tags: currentTags,
      tagController: state.tagController,
      focusNode: state.focusNode,
    );

    _logState();
  }

  /// Adds a new tag to the list if it's not empty and not already in the list
  void addTag(String tag) {
    if (tag.isEmpty) return;

    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;

    // Don't add if the tag already exists
    if (state.tags.contains(trimmedTag)) return;

    final updatedTags = List<String>.from(state.tags)..add(trimmedTag);
    ref.read(bodyEntryProvider.notifier).updateTags(updatedTags);
    state.tagController.clear();
  }

  /// Removes a tag from the list
  void removeTag(String tag) {
    final updatedTags = List<String>.from(state.tags)..remove(tag);
    ref.read(bodyEntryProvider.notifier).updateTags(updatedTags);
  }

  /// Handles focus behavior when a tag is submitted
  void handleSubmitted(String value) {
    if (value.trim().isEmpty) {
      // If the controller is empty when finish is pressed, unfocus to dismiss keyboard
      state.focusNode.unfocus();
    } else {
      // Otherwise add the tag and keep focus
      addTag(value);
      state.focusNode.requestFocus();
    }
  }

  /// Handles the add button press
  void handleAddButtonPressed() {
    addTag(state.tagController.text);
    state.focusNode.requestFocus();
  }
}

/// A provider for accessing the TagEntryViewModel.
///
/// This provider makes the TagEntryViewModel available to widgets
/// that need to display and modify tag entry information.
final tagEntryProvider = StateNotifierProvider<TagEntryViewModel, TagEntryData>(
  (ref) => TagEntryViewModel(ref),
);