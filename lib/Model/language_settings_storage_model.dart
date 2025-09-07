import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

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
  /// Returns system language if no language is saved previously, fallback to 'en'
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      return savedLanguage;
    }
    
    // If no language is saved, detect system language and save it
    final systemLanguage = _getSystemLanguage();
    await saveLanguage(systemLanguage);
    return systemLanguage;
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
  
  /// Detects the system language and returns a supported language code
  /// Falls back to 'en' if system language is not supported
  static String _getSystemLanguage() {
    final systemLocales = ui.PlatformDispatcher.instance.locales;
    
    // Check if any of the system locales are supported
    for (final locale in systemLocales) {
      final languageCode = locale.languageCode.toLowerCase();
      if (isLanguageSupported(languageCode)) {
        return languageCode;
      }
    }
    
    // Fallback to English if no supported language found
    return 'en';
  }
}