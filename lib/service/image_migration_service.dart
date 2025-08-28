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

      final dbHelper = DatabaseHelper();
      final entries = await dbHelper.queryAllBodyEntries();

      for (final entry in entries) {
        bool needsUpdate = false;
        String? newFrontPath = entry.frontImagePath;
        String? newSidePath = entry.sideImagePath;
        String? newBackPath = entry.backImagePath;

        // Migrate front image
        if (entry.frontImagePath != null && 
            entry.frontImagePath!.contains(documentsDir.path)) {
          final oldFile = File(entry.frontImagePath!);
          if (await oldFile.exists()) {
            final fileName = entry.frontImagePath!.split('/').last;
            final newPath = '${imagesDir.path}/$fileName';
            await oldFile.copy(newPath);
            await oldFile.delete();
            newFrontPath = newPath;
            needsUpdate = true;
          }
        }

        // Similar logic for side and back images...

        // FIXED: Use direct database update with exact entry data
        if (needsUpdate) {
          final db = await dbHelper.database;
          await db.update(
            'body_entries',
            {
              'front_image_path': newFrontPath,
              'side_image_path': newSidePath,
              'back_image_path': newBackPath,
            },
            where: 'date = ?',
            whereArgs: [entry.date.millisecondsSinceEpoch],
          );
          print('Updated paths for entry at ${entry.date}');
        }
      }
    } catch (e) {
      print('Error during image migration: $e');
    }
  }
}
