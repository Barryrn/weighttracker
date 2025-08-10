import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionsService {
  /// Request camera and photos permissions together
  Future<bool> requestCameraAndPhotos() async {
    final cameraGranted = await Permission.camera.isGranted;
    final photosGranted = await Permission.photos.isGranted;

    if (cameraGranted && photosGranted) return true;

    final statuses = await [Permission.camera, Permission.photos].request();

    final allGranted = statuses.values.every((status) => status.isGranted);
    final anyPermanentlyDenied = statuses.values.any(
      (status) => status.isPermanentlyDenied,
    );

    if (anyPermanentlyDenied) await openAppSettings();

    return allGranted;
  }
}

final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService();
});
