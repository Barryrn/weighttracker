import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary – Orange
  static const Color secondary = Color(0xFFFB8500);
  static const Color secondaryLight = Color(0xFFFFB347);
  static const Color secondaryVeryLight = Color(0xFFFFD699);

  // Secondary – Blue
  static const Color primary = Color(0xFF246EE9);
  static const Color primaryLight = Color(0xFF669DFF);
  static const Color primaryVeryLight = Color(0xFFB8D0FF);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFFAFAFA); // Light gray
  static const Color backgroundLight = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFFFFFFF); // Card/container
  static const Color surfaceLight = Color(0xFFF5F5F5); // Subtle surface

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
  static const Color textInactive = Color(0xFFD1D5DB); // Light Gray
  static const Color textHint = Color(
    0xFFE5E7EB,
  ); // Very light (e.g. placeholders)

  // Status Colors (optional)
  static const Color success = Color(0xFF10B981); // Green
  static const Color error = Color(0xFFEF4444); // Red
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.surface,
    onPrimary: Colors.white, // e.g. white text on orange button
    onSecondary: Colors.white,
    onBackground: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: Colors.white,
  ),

  scaffoldBackgroundColor: AppColors.background,

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 1,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: GoogleFonts.poppins(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  textTheme: GoogleFonts.poppinsTextTheme().copyWith(
    displayLarge: TextStyle(color: AppColors.textPrimary),
    displayMedium: TextStyle(color: AppColors.textPrimary),
    titleLarge: TextStyle(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textSecondary),
    labelLarge: TextStyle(color: AppColors.primary),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textInactive,
    selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
    unselectedLabelStyle: GoogleFonts.poppins(),
  ),
);
