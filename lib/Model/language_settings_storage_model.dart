import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsStorageModel {
  static const String _languageKey = 'selected_language';
  
  // Supported languages with their locale codes and display names
  static const Map<String, Map<String, String>> supportedLanguages = {
    'de': {'name': 'Deutsch', 'flag': '🇩🇪'},
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'es': {'name': 'Español', 'flag': '🇪🇸'},
    'fr': {'name': 'Français', 'flag': '🇫🇷'},
    'pt': {'name': 'Português', 'flag': '🇵🇹'},
    'it': {'name': 'Italiano', 'flag': '🇮🇹'},
    'tr': {'name': 'Türkçe', 'flag': '🇹🇷'},
    'pl': {'name': 'Polski', 'flag': '🇵🇱'},
  };
  
  /// Save the selected language to SharedPreferences
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
  
  /// Get the saved language from SharedPreferences
  /// Returns 'en' as default if no language is saved
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
  
  /// Get the Locale object for the saved language
  static Future<Locale> getSavedLocale() async {
    final languageCode = await getSavedLanguage();
    return Locale(languageCode);
  }
  
  /// Check if a language code is supported
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }
  
  /// Get display name for a language code
  static String getLanguageDisplayName(String languageCode) {
    return supportedLanguages[languageCode]?['name'] ?? 'Unknown';
  }
  
  /// Get flag emoji for a language code
  static String getLanguageFlag(String languageCode) {
    return supportedLanguages[languageCode]?['flag'] ?? '🏳️';
  }
}