import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weigthtracker/Widget/image_timeline_filter.dart';
import 'package:weigthtracker/Widget/image_timeline_view_widget.dart';
import '../ViewModel/image_timeline_view_model.dart';
import '../theme.dart';

/// A view that displays a timeline of progress images
class ImageTimelineView extends ConsumerStatefulWidget {
  const ImageTimelineView({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageTimelineView> createState() => _ImageTimelineViewState();
}

class _ImageTimelineViewState extends ConsumerState<ImageTimelineView> {
  // State variable to control filter visibility
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Timeline',
          style: AppTypography.headline3(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textTertiary),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.textTertiary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Add filter icon to the app bar
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background2,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Wrap with SingleChildScrollView to make it scrollable
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Show filter widget if _showFilters is true
                if (_showFilters)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ImageTimelineFilter(),
                  ),
                // Use SizedBox with a fixed height for the image timeline widget
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      150, // Adjust height as needed
                  child: ImageTimelineViewWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
