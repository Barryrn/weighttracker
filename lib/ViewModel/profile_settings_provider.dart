import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/profile_settings_model.dart';
import '../Model/profile_settings_storage_model.dart'; // Import the new storage class
import 'dart:developer' as developer;

/// A StateNotifier that manages the state of the user's profile settings.
///
/// This class follows the MVVM pattern by acting as the ViewModel that connects
/// the Model (ProfileSettings) with the View (ProfileSettingsPage).
class ProfileSettingsNotifier extends StateNotifier<ProfileSettings> {
  /// Creates a ProfileSettingsNotifier with default empty settings.
  /// Loads saved settings from storage when initialized.
  ProfileSettingsNotifier() : super(const ProfileSettings()) {
    _loadSettings();
  }

  /// Loads settings from persistent storage
  Future<void> _loadSettings() async {
    try {
      final settings = await ProfileSettingsStorage.loadProfileSettings();
      state = settings;
      _logState();
    } catch (e) {
      developer.log('Error loading profile settings: $e');
    }
  }

  /// Saves the current settings to persistent storage
  Future<void> _saveSettings() async {
    try {
      await ProfileSettingsStorage.saveProfileSettings(state);
    } catch (e) {
      developer.log('Error saving profile settings: $e');
    }
  }

  /// Logs the current state of the ProfileSettings
  /// This is called after each state update to help with debugging
  void _logState() {
    developer.log('===== ProfileSettings Provider State =====');
    developer.log('Birthday: ${state.birthday}');
    developer.log('Gender: ${state.gender}');
    developer.log('Height: ${state.height}');
  }

  /// Updates the birthday in the profile settings.
  ///
  /// [birthday] is the new birthday to set.
  void updateBirthday(DateTime birthday) {
    state = state.copyWith(birthday: birthday);
    _saveSettings(); // Save after update
    _logState();
  }

  /// Updates the gender in the profile settings.
  ///
  /// [gender] is the new gender to set.
  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
    _saveSettings(); // Save after update
    _logState();
  }

  /// Updates the height in the profile settings.
  ///
  /// [height] is the new height to set in centimeters.
  void updateHeight(double height) {
    state = state.copyWith(height: height);
    _saveSettings(); // Save after update
    _logState();
  }
}

/// A provider for accessing and modifying profile settings.
///
/// This provider makes the ProfileSettingsNotifier available to widgets
/// that need to read or update profile settings.
final profileSettingsProvider =
    StateNotifierProvider<ProfileSettingsNotifier, ProfileSettings>(
      (ref) => ProfileSettingsNotifier(),
    );
