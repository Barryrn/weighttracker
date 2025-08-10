# Permission Usage Summary

## Android Permissions

### Declared in AndroidManifest.xml

**Main Manifest** (`android/app/src/main/AndroidManifest.xml`):
- `android.permission.CAMERA` - For taking progress photos
- `android.permission.READ_MEDIA_IMAGES` - For accessing media images on Android 13+
- `android.permission.READ_EXTERNAL_STORAGE` (maxSdkVersion="32") - For accessing stored images on older Android versions
- `android.permission.WRITE_EXTERNAL_STORAGE` (maxSdkVersion="29") - For saving images on older Android versions
- `android.permission.health.READ_WEIGHT` - For reading weight data from Health Connect
- `android.permission.health.WRITE_WEIGHT` - For writing weight data to Health Connect
- `android.permission.health.READ_BODY_FAT` - For reading body fat data from Health Connect
- `android.permission.health.WRITE_BODY_FAT` - For writing body fat data to Health Connect

**Debug Manifest** (`android/app/src/debug/AndroidManifest.xml`):
- `android.permission.INTERNET` - Required for development (hot reload, debugging)

**Profile Manifest** (`android/app/src/profile/AndroidManifest.xml`):
- `android.permission.INTERNET` - For Flutter debugging
- `android.permission.CAMERA` - For taking progress photos
- `android.permission.RECORD_AUDIO` - For recording videos
- `android.permission.READ_MEDIA_IMAGES` - For accessing media images on Android 13+
- `android.permission.READ_EXTERNAL_STORAGE` - For accessing stored images on older Android versions
- `android.permission.WRITE_EXTERNAL_STORAGE` (maxSdkVersion="28") - For saving images on older Android versions

## iOS Permissions

### Info.plist Usage Descriptions

**Camera** (`NSCameraUsageDescription`):