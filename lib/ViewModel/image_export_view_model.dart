import 'dart:io';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weigthtracker/service/permission_service.dart';

/// State class for the image export functionality
class ImageExportState {
  final bool isExporting;
  final String? errorMessage;
  final bool isSuccess;

  ImageExportState({
    this.isExporting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  ImageExportState copyWith({
    bool? isExporting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ImageExportState(
      isExporting: isExporting ?? this.isExporting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// ViewModel for handling image exports to the phone gallery
class ImageExportViewModel extends StateNotifier<ImageExportState> {
  ImageExportViewModel() : super(ImageExportState());

  /// Exports an image to the phone gallery
  /// Returns true if successful, false otherwise
  Future<bool> exportImageToGallery(String imagePath) async {
    try {
      // Set state to exporting
      state = state.copyWith(
        isExporting: true,
        errorMessage: null,
        isSuccess: false,
      );

      // Check if we have permission
      final status = await Permission.photos.request();
      if (status.isGranted) {
        // Read the file
        final file = File(imagePath);
        final bytes = await file.readAsBytes();

        // Save to gallery
        final result = await ImageGallerySaver.saveImage(bytes);

        // Update state based on result
        if (result['isSuccess']) {
          state = state.copyWith(isExporting: false, isSuccess: true);
          return true;
        } else {
          state = state.copyWith(
            isExporting: false,
            errorMessage: 'Failed to save image',
            isSuccess: false,
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isExporting: false,
          errorMessage: 'Permission denied to save images',
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: 'Error saving image: $e',
        isSuccess: false,
      );
      return false;
    }
  }

  /// Shows a modal bottom sheet with export options
  Future<void> showExportOptions(BuildContext context, String imagePath) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Export to Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final success = await exportImageToGallery(imagePath);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Image saved to gallery'
                              : state.errorMessage ?? 'Failed to save image',
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Provider for accessing the ImageExportViewModel
final imageExportProvider =
    StateNotifierProvider<ImageExportViewModel, ImageExportState>(
      (ref) => ImageExportViewModel(),
    );
