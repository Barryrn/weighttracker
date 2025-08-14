import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weigthtracker/l10n/app_localizations.dart';
import '../Widget/image_gallery_widget.dart';
import '../theme.dart';

/// A view that displays all images in a grid with filtering options
class ImageGalleryView extends ConsumerStatefulWidget {
  const ImageGalleryView({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageGalleryView> createState() => _ImageGalleryViewState();
}

class _ImageGalleryViewState extends ConsumerState<ImageGalleryView> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.imageGallery,
          style: AppTypography.headline3(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.textTertiary),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ImageGalleryWidget(showFilters: _showFilters),
      ),
    );
  }
}
