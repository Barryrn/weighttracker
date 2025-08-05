import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ViewModel/tag_settings_view_model.dart';
import '../theme.dart';

/// A view that displays and manages all tags in the application.
///
/// This view follows the MVVM pattern by using the tagSettingsProvider
/// to access the ViewModel that manages all business logic and state.
class TagSettingsView extends ConsumerWidget {
  /// Creates a TagSettingsView.
  ///
  /// The [key] parameter is optional and is passed to the parent class.
  const TagSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagSettingsData = ref.watch(tagSettingsProvider);
    final viewModel = ref.read(tagSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tags'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: _buildBody(context, tagSettingsData, viewModel),
    );
  }

  /// Builds the body of the view based on the current state
  Widget _buildBody(
    BuildContext context,
    TagSettingsData data,
    TagSettingsViewModel viewModel,
  ) {
    if (data.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${data.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadAllTags(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (data.allTags.isEmpty) {
      return const Center(
        child: Text(
          'No tags found. Add tags when entering weight data.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: data.allTags.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final tag = data.allTags[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(tag),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, tag, viewModel),
            ),
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog before deleting a tag
  void _showDeleteConfirmation(
    BuildContext context,
    String tag,
    TagSettingsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Are you sure you want to delete the tag "$tag"? '
          'This will remove it from all entries in the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deleteTag(tag);
              // viewModel.cleanupEmptyTags();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
