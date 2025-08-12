import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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

    return GestureDetector(
      // Add GestureDetector to dismiss keyboard when tapping anywhere on the screen
      onTap: () {
        // Hide the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.tagSettings,
            style: AppTypography.headline3(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.textTertiary),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.textPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.background2,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(context, tagSettingsData, viewModel),
        ),
      ),
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
              AppLocalizations.of(context)!.error + ' ' + data.error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadAllTags(),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (data.allTags.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(
            context,
          )!.noTagsFoundAddTagsWhenEnteringWeightData,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: data.allTags.length,
      itemBuilder: (context, index) {
        final tag = data.allTags[index];
        return Card(
          color: Theme.of(context).colorScheme.card,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(tag),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
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
        title: Text(AppLocalizations.of(context)!.deleteTag),
        content: Text(
          AppLocalizations.of(context)!.areYouSureYouWantToDeleteTheTag +
              ' "$tag"? ' +
              AppLocalizations.of(
                context,
              )!.thisWillRemoveItFromAllEntriesInTheDatabase,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.deleteTag(tag);
              // viewModel.cleanupEmptyTags();
            },
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
