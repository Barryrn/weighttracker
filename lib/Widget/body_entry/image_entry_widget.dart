import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../../ViewModel/entry_form_provider.dart';
import '../../theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Enum representing the different view types for body images
enum ViewType { front, side, back }

/// A widget that allows users to upload or take photos for front, side, and back views.
class ImageEntry extends ConsumerStatefulWidget {
  const ImageEntry({Key? key}) : super(key: key);

  @override
  ConsumerState<ImageEntry> createState() => _ImageEntryState();
}

class _ImageEntryState extends ConsumerState<ImageEntry> {
  final ImagePicker _picker = ImagePicker();
  String? _frontImagePath;
  String? _sideImagePath;
  String? _backImagePath;

  @override
  void initState() {
    super.initState();
    _initializeImagePaths();

    // Add listener to bodyEntryProvider
    ref.listenManual(bodyEntryProvider, (previous, next) {
      if (next.frontImagePath != _frontImagePath ||
          next.sideImagePath != _sideImagePath ||
          next.backImagePath != _backImagePath) {
        setState(() {
          _frontImagePath = next.frontImagePath;
          _sideImagePath = next.sideImagePath;
          _backImagePath = next.backImagePath;
        });
      }
    });
  }

  /// Initializes image paths from the bodyEntryProvider
  void _initializeImagePaths() {
    final bodyEntry = ref.read(bodyEntryProvider);
    _frontImagePath = bodyEntry.frontImagePath;
    _sideImagePath = bodyEntry.sideImagePath;
    _backImagePath = bodyEntry.backImagePath;
  }

  Future<void> _showImageSourceDialog(ViewType viewType) async {
    final bodyEntry = ref.watch(bodyEntryProvider);
    String? currentImagePath;

    switch (viewType) {
      case ViewType.front:
        currentImagePath = bodyEntry.frontImagePath;
        break;
      case ViewType.side:
        currentImagePath = bodyEntry.sideImagePath;
        break;
      case ViewType.back:
        currentImagePath = bodyEntry.backImagePath;
        break;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${viewType.name.capitalize()} View Photo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.camera, viewType);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _getImage(ImageSource.gallery, viewType);
                  },
                ),
                if (currentImagePath != null)
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: const Text('Delete Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteImage(viewType);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source, ViewType viewType) async {
    try {
      // Request permissions before accessing camera or gallery
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
            ),
          );
          return;
        }
      } else {
        var status = await Permission.photos.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photos permission is required to select images'),
            ),
          );
          return;
        }
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            '${const Uuid().v4()}${path.extension(pickedFile.path)}';
        final newFilePath = '${appDir.path}/$fileName';
        final newImageFile = await File(pickedFile.path).copy(newFilePath);

        final bodyEntry = ref.read(bodyEntryProvider);
        final notifier = ref.read(bodyEntryProvider.notifier);

        String? currentImagePath;
        switch (viewType) {
          case ViewType.front:
            currentImagePath = bodyEntry.frontImagePath;
            break;
          case ViewType.side:
            currentImagePath = bodyEntry.sideImagePath;
            break;
          case ViewType.back:
            currentImagePath = bodyEntry.backImagePath;
            break;
        }

        // Vorheriges Bild löschen falls vorhanden
        if (currentImagePath != null) {
          final oldFile = File(currentImagePath);
          if (await oldFile.exists()) {
            await oldFile.delete();
            print('Deleted old image at $currentImagePath');
          }
        }

        // Neuen Pfad setzen
        switch (viewType) {
          case ViewType.front:
            notifier.updateFrontImagePath(newImageFile.path);
            break;
          case ViewType.side:
            notifier.updateSideImagePath(newImageFile.path);
            break;
          case ViewType.back:
            notifier.updateBackImagePath(newImageFile.path);
            break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Deletes the image for the specified view type
  /// @param viewType The type of view (front, side, or back)
  Future<void> _deleteImage(ViewType viewType) async {
    final bodyEntry = ref.watch(bodyEntryProvider);
    final notifier = ref.watch(bodyEntryProvider.notifier);
    String? imagePath;

    switch (viewType) {
      case ViewType.front:
        imagePath = bodyEntry.frontImagePath;
        break;
      case ViewType.side:
        imagePath = bodyEntry.sideImagePath;
        break;
      case ViewType.back:
        imagePath = bodyEntry.backImagePath;
        break;
    }

    if (imagePath != null) {
      try {
        print(imagePath);
        final file = File(imagePath);
        if (await file.exists()) {
          print('Deleting file at $imagePath');
          await file.delete();

          print('Image Path $imagePath');
          print('File deleted successfully');
        } else {
          print('File does not exist at $imagePath');
        }

        // Update state regardless of whether file existed or not
        switch (viewType) {
          case ViewType.front:
            notifier.updateFrontImagePath(null);

            break;
          case ViewType.side:
            notifier.updateSideImagePath(null);
            break;
          case ViewType.back:
            notifier.updateBackImagePath(null);
            break;
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
      }
    } else {
      // Even if there's no image path, we should still ensure the state is updated to null
      switch (viewType) {
        case ViewType.front:
          notifier.updateFrontImagePath(null);
          break;
        case ViewType.side:
          notifier.updateSideImagePath(null);
          break;
        case ViewType.back:
          notifier.updateBackImagePath(null);
          break;
      }
      print('No image path set for $viewType');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the cached image paths instead of reading from provider directly
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Progress Photos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildImageCard(
                title: 'Front',
                imagePath: _frontImagePath,
                onTap: () => _showImageSourceDialog(ViewType.front),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildImageCard(
                title: 'Side',
                imagePath: _sideImagePath,
                onTap: () => _showImageSourceDialog(ViewType.side),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildImageCard(
                title: 'Back',
                imagePath: _backImagePath,
                onTap: () => _showImageSourceDialog(ViewType.back),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard({
    required String title,
    String? imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: imagePath != null
              ? FutureBuilder<bool>(
                  future: File(imagePath).exists(),
                  builder: (context, snapshot) {
                    final exists = snapshot.data ?? false;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (exists) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            key: ValueKey(
                              imagePath,
                            ), // wichtig: erzwingt Rebuild wenn Pfad sich ändert
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return _buildPlaceholder(title);
                    }
                  },
                )
              : _buildPlaceholder(title),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.camera_alt,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
