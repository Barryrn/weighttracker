import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/database_helper.dart';

class ImageMigrationService {
  static Future<void> migrateImagesToSupportDirectory() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final supportDir = await getApplicationSupportDirectory();
      final imagesDir = Directory('${supportDir.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Get all body entries from database
      final dbHelper = DatabaseHelper();
      final entries = await dbHelper.queryAllBodyEntries();

      for (final entry in entries) {
        bool needsUpdate = false;
        String? newFrontPath;
        String? newSidePath;
        String? newBackPath;

        // Migrate front image
        if (entry.frontImagePath != null) {
          final oldFile = File(entry.frontImagePath!);
          if (await oldFile.exists() &&
              entry.frontImagePath!.contains(documentsDir.path)) {
            final fileName = entry.frontImagePath!.split('/').last;
            final newPath = '${imagesDir.path}/$fileName';
            await oldFile.copy(newPath);
            await oldFile.delete();
            newFrontPath = newPath;
            needsUpdate = true;
          }
        }

        // Migrate side image
        if (entry.sideImagePath != null) {
          final oldFile = File(entry.sideImagePath!);
          if (await oldFile.exists() &&
              entry.sideImagePath!.contains(documentsDir.path)) {
            final fileName = entry.sideImagePath!.split('/').last;
            final newPath = '${imagesDir.path}/$fileName';
            await oldFile.copy(newPath);
            await oldFile.delete();
            newSidePath = newPath;
            needsUpdate = true;
          }
        }

        // Migrate back image
        if (entry.backImagePath != null) {
          final oldFile = File(entry.backImagePath!);
          if (await oldFile.exists() &&
              entry.backImagePath!.contains(documentsDir.path)) {
            final fileName = entry.backImagePath!.split('/').last;
            final newPath = '${imagesDir.path}/$fileName';
            await oldFile.copy(newPath);
            await oldFile.delete();
            newBackPath = newPath;
            needsUpdate = true;
          }
        }

        // Update database with new paths
        if (needsUpdate) {
          final updatedEntry = entry.copyWith(
            frontImagePath: newFrontPath ?? entry.frontImagePath,
            sideImagePath: newSidePath ?? entry.sideImagePath,
            backImagePath: newBackPath ?? entry.backImagePath,
          );
          // You'll need to add a method to get entry ID and update
          // This is a simplified example
        }
      }

      print('Image migration completed successfully');
    } catch (e) {
      print('Error during image migration: $e');
    }
  }
}
