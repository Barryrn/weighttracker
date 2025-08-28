import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service for handling image file operations with fallback support
/// Provides methods to resolve image paths across different storage directories
class ImageFileService {
  /// Gets an image file with fallback support for directory migration
  /// 
  /// This method handles the transition from Documents directory to ApplicationSupport directory
  /// by checking both locations when an image file is not found at the specified path.
  /// 
  /// @param imagePath The original image path from the database
  /// @return Future<File?> The image file if found, null if not found in either location
  static Future<File?> getImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }
    
    try {
      // First, try the original path
      final originalFile = File(imagePath);
      if (await originalFile.exists()) {
        return originalFile;
      }
      
      // If original file doesn't exist, try fallback locations
      final documentsDir = await getApplicationDocumentsDirectory();
      final supportDir = await getApplicationSupportDirectory();
      
      String? fallbackPath;
      
      // Determine fallback path based on current path
      if (imagePath.contains(documentsDir.path)) {
        // Original path is in Documents, try ApplicationSupport
        fallbackPath = imagePath.replaceFirst(
          documentsDir.path, 
          supportDir.path
        );
      } else if (imagePath.contains(supportDir.path)) {
        // Original path is in ApplicationSupport, try Documents
        fallbackPath = imagePath.replaceFirst(
          supportDir.path, 
          documentsDir.path
        );
      } else {
        // Path doesn't contain either directory, try both with /images/ subdirectory
        final fileName = imagePath.split('/').last;
        
        // Try ApplicationSupport first (current standard)
        final supportImagePath = '${supportDir.path}/images/$fileName';
        final supportFile = File(supportImagePath);
        if (await supportFile.exists()) {
          return supportFile;
        }
        
        // Try Documents as fallback
        final documentsImagePath = '${documentsDir.path}/images/$fileName';
        fallbackPath = documentsImagePath;
      }
      
      if (fallbackPath != null) {
        final fallbackFile = File(fallbackPath);
        if (await fallbackFile.exists()) {
          print('Found image at fallback location: $fallbackPath');
          return fallbackFile;
        }
      }
      
      print('Image not found at original path or fallback locations: $imagePath');
      return null;
      
    } catch (e) {
      print('Error resolving image file: $e');
      return null;
    }
  }
  
  /// Checks if an image file exists with fallback support
  /// 
  /// @param imagePath The image path to check
  /// @return Future<bool> True if the image exists in any supported location
  static Future<bool> imageExists(String? imagePath) async {
    final file = await getImageFile(imagePath);
    return file != null;
  }
  
  /// Gets the actual path of an image file with fallback support
  /// 
  /// @param imagePath The original image path
  /// @return Future<String?> The actual path where the image was found, null if not found
  static Future<String?> getActualImagePath(String? imagePath) async {
    final file = await getImageFile(imagePath);
    return file?.path;
  }
}