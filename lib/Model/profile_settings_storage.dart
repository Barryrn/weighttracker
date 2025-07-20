import 'package:shared_preferences/shared_preferences.dart';
import 'profile_settings.dart';

/// A helper class for storing and retrieving profile settings from SharedPreferences.
///
/// This class follows the MVVM pattern by providing data persistence services
/// for the ProfileSettings model.
class ProfileSettingsStorage {
  // Keys for SharedPreferences
  static const String _birthdayKey = 'profile_birthday';
  static const String _genderKey = 'profile_gender';
  static const String _heightKey = 'profile_height';
  
  /// Save profile settings to SharedPreferences
  /// @param settings The ProfileSettings to save
  static Future<void> saveProfileSettings(ProfileSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save birthday if not null
    if (settings.birthday != null) {
      await prefs.setInt(_birthdayKey, settings.birthday!.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_birthdayKey);
    }
    
    // Save gender if not null
    if (settings.gender != null) {
      await prefs.setString(_genderKey, settings.gender!);
    } else {
      await prefs.remove(_genderKey);
    }
    
    // Save height if not null
    if (settings.height != null) {
      await prefs.setDouble(_heightKey, settings.height!);
    } else {
      await prefs.remove(_heightKey);
    }
  }
  
  /// Load profile settings from SharedPreferences
  /// @return Future<ProfileSettings> The loaded profile settings
  static Future<ProfileSettings> loadProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load birthday
    final birthdayMillis = prefs.getInt(_birthdayKey);
    final DateTime? birthday = birthdayMillis != null 
        ? DateTime.fromMillisecondsSinceEpoch(birthdayMillis)
        : null;
    
    // Load gender
    final String? gender = prefs.getString(_genderKey);
    
    // Load height
    final double? height = prefs.getDouble(_heightKey);
    
    return ProfileSettings(
      birthday: birthday,
      gender: gender,
      height: height,
    );
  }
  
  /// Clear all profile settings from SharedPreferences
  static Future<void> clearProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_birthdayKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_heightKey);
  }
}