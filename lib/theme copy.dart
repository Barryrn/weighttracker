// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class Theme.of(context).colorScheme {
//   // Primary (Blue Shades)
//   static const Color primary = Color(0xFF1E90FF); // hsl(210, 100%, 50%)
//   static const Color primaryLight = Color(0xFF66B2FF); // hsl(210, 100%, 70%)
//   static const Color primaryExtraLight = Color(
//     0xFFE6F2FF,
//   ); // hsl(210, 100%, 90%)
//   static const Color primaryDark = Color(0xFF0066CC); // hsl(210, 100%, 40%)

//   // Backgrounds (Light Mode)
//   static const Color background1 = Color(0xFFF2F6F9); // hsl(210, 20%, 95%)
//   static const Color background2 = Color(0xFFE0E8EF); // hsl(210, 20%, 90%)
//   static const Color background3 = Color(0xFFCEDAE5); // hsl(210, 20%, 85%)

//   // Card
//   static const Color card = Color(0xFFFFFFFF); // hsl(0, 0%, 100%) — clean white

//   // Backgrounds (Dark Mode)
//   static const Color background1Dark = Color(0xFF0F1115); // hsl(210, 15%, 10%)
//   static const Color background2Dark = Color(0xFF171A1F); // hsl(210, 15%, 13%)
//   static const Color background3Dark = Color(0xFF21262C); // hsl(210, 15%, 18%)
//   static const Color cardDark = Color(0xFF2B2F35); // hsl(210, 10%, 20%)

//   // Text Colors
//   static const Color textPrimary = Color(0xFF1F2937); // hsl(210, 15%, 20%)
//   static const Color textSecondary = Color(0xFF6B7280); // hsl(210, 10%, 40%)
//   static const Color textTertiary = Color(0xFFFFFFFF); // white
//   static const Color textDisabled = Color(0xFFA0AAB4); // hsl(210, 10%, 65%)
//   static const Color textPrimaryDark = Color(0xFFFFFFFF); // white
//   static const Color textSecondaryDark = Color(
//     0xFFB0B8C1,
//   ); // hsl(210, 10%, 70%)
//   static const Color textDisabledDark = Color(0xFF7A8693); // hsl(210, 10%, 50%)

//   // Border
//   static const Color border = Color(0xFFCBD5E1); // hsl(210, 10%, 80%)
//   static const Color borderDark = Color(0xFF3A3F45); // hsl(210, 10%, 30%)

//   // Status Colors
//   static const Color success = Color(0xFF2E8B57); // hsl(140, 60%, 45%)
//   static const Color error = Color(0xFFDC3545); // hsl(0, 80%, 55%)
//   static const Color warning = Color(0xFFFFAA33); // hsl(35, 90%, 55%)
//   static const Color info = Color(0xFF33B5E5); // hsl(200, 90%, 55%)
// }

// final ThemeData appTheme = ThemeData(
//   useMaterial3: true,
//   colorScheme: const ColorScheme.light(
//     primary: Theme.of(context).colorScheme.primary,
//     secondary: Theme.of(context).colorScheme.primaryLight,
//     background: Theme.of(context).colorScheme.background1,
//     surface: Theme.of(context).colorScheme.card,
//     onPrimary: Colors.white,
//     onSecondary: Colors.white,
//     onBackground: Theme.of(context).colorScheme.textPrimary,
//     onSurface: Theme.of(context).colorScheme.textPrimary,
//     error: Theme.of(context).colorScheme.error,
//     onError: Colors.white,
//   ),
//   scaffoldBackgroundColor: Theme.of(context).colorScheme.background1,
//   appBarTheme: AppBarTheme(
//     backgroundColor: Theme.of(context).colorScheme.card,
//     elevation: 1,
//     iconTheme: const IconThemeData(color: Theme.of(context).colorScheme.textPrimary),
//     titleTextStyle: GoogleFonts.poppins(
//       color: Theme.of(context).colorScheme.textPrimary,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   textTheme: GoogleFonts.poppinsTextTheme().copyWith(
//     displayLarge: const TextStyle(color: Theme.of(context).colorScheme.textPrimary),
//     displayMedium: const TextStyle(color: Theme.of(context).colorScheme.textPrimary),
//     titleLarge: const TextStyle(
//       color: Theme.of(context).colorScheme.textPrimary,
//       fontWeight: FontWeight.bold,
//     ),
//     bodyLarge: const TextStyle(color: Theme.of(context).colorScheme.textPrimary),
//     bodyMedium: const TextStyle(color: Theme.of(context).colorScheme.textSecondary),
//     labelLarge: const TextStyle(color: Theme.of(context).colorScheme.primary),
//   ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       foregroundColor: Colors.white,
//       textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//   ),
//   bottomNavigationBarTheme: BottomNavigationBarThemeData(
//     backgroundColor: Theme.of(context).colorScheme.card,
//     selectedItemColor: Theme.of(context).colorScheme.primary,
//     unselectedItemColor: Theme.of(context).colorScheme.textDisabled,
//     selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//     unselectedLabelStyle: GoogleFonts.poppins(),
//   ),
// );

// final ThemeData appDarkTheme = ThemeData(
//   useMaterial3: true,
//   colorScheme: const ColorScheme.dark(
//     primary: Theme.of(context).colorScheme.primaryLight,
//     secondary: Theme.of(context).colorScheme.primary,
//     background: Theme.of(context).colorScheme.background1Dark,
//     surface: Theme.of(context).colorScheme.cardDark,
//     onPrimary: Colors.white,
//     onSecondary: Colors.white,
//     onBackground: Theme.of(context).colorScheme.textPrimaryDark,
//     onSurface: Theme.of(context).colorScheme.textPrimaryDark,
//     error: Theme.of(context).colorScheme.error,
//     onError: Colors.white,
//   ),
//   scaffoldBackgroundColor: Theme.of(context).colorScheme.background1Dark,
//   appBarTheme: AppBarTheme(
//     backgroundColor: Theme.of(context).colorScheme.cardDark,
//     elevation: 1,
//     iconTheme: const IconThemeData(color: Theme.of(context).colorScheme.textPrimaryDark),
//     titleTextStyle: GoogleFonts.poppins(
//       color: Theme.of(context).colorScheme.textPrimaryDark,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//   ),
//   textTheme: GoogleFonts.poppinsTextTheme().copyWith(
//     displayLarge: const TextStyle(color: Theme.of(context).colorScheme.textPrimaryDark),
//     displayMedium: const TextStyle(color: Theme.of(context).colorScheme.textPrimaryDark),
//     titleLarge: const TextStyle(
//       color: Theme.of(context).colorScheme.textPrimaryDark,
//       fontWeight: FontWeight.bold,
//     ),
//     bodyLarge: const TextStyle(color: Theme.of(context).colorScheme.textPrimaryDark),
//     bodyMedium: const TextStyle(color: Theme.of(context).colorScheme.textSecondaryDark),
//     labelLarge: const TextStyle(color: Theme.of(context).colorScheme.primaryLight),
//   ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(
//       backgroundColor: Theme.of(context).colorScheme.primaryLight,
//       foregroundColor: Colors.white,
//       textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ),
//   ),
//   bottomNavigationBarTheme: BottomNavigationBarThemeData(
//     backgroundColor: Theme.of(context).colorScheme.cardDark,
//     selectedItemColor: Theme.of(context).colorScheme.primaryLight,
//     unselectedItemColor: Theme.of(context).colorScheme.textDisabledDark,
//     selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//     unselectedLabelStyle: GoogleFonts.poppins(),
//   ),
// );
