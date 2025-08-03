import 'package:shared_preferences/shared_preferences.dart';

/// A helper class for storing and retrieving health sync settings from SharedPreferences.
///
/// This class follows the MVVM pattern by providing data persistence services
/// for the health sync functionality.
class HealthSyncStorage {
  // Key for SharedPreferences
  static const String _lastSyncTimeKey = 'health_last_sync_time';

  /// Save last sync time to SharedPreferences
  /// @param lastSyncTime The DateTime to save
  static Future<void> saveLastSyncTime(DateTime? lastSyncTime) async {
    final prefs = await SharedPreferences.getInstance();

    // Save last sync time if not null
    if (lastSyncTime != null) {
      await prefs.setInt(
        _lastSyncTimeKey,
        lastSyncTime.millisecondsSinceEpoch,
      );
    } else {
      await prefs.remove(_lastSyncTimeKey);
    }
  }

  /// Load last sync time from SharedPreferences
  /// @return Future<DateTime?> The loaded last sync time
  static Future<DateTime?> loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();

    // Load last sync time
    final lastSyncTimeMillis = prefs.getInt(_lastSyncTimeKey);
    final DateTime? lastSyncTime = lastSyncTimeMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastSyncTimeMillis)
        : null;

    return lastSyncTime;
  }

  /// Clear last sync time from SharedPreferences
  static Future<void> clearLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncTimeKey);
  }
}