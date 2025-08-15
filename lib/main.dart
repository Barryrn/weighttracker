import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for SystemChrome
import '../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weigthtracker/View/onboarding_screen.dart';
import 'package:weigthtracker/ViewModel/health_provider.dart';
import 'package:weigthtracker/ViewModel/weight_progress_view_model.dart';
import 'package:weigthtracker/theme.dart';
import 'model/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'View/body_entry_sheet_view.dart';
import 'model/body_entry_model.dart';
import 'View/footer_pages/home_page.dart';
import 'model/mock_data_importer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'model/language_settings_storage_model.dart';
import 'Widget/restart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize the database
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  await dbHelper.printDatabasePath();

  // Run the app with ProviderScope and RestartWidget
  runApp(RestartWidget(child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool? _onboardingComplete;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    _loadSavedLanguage();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    });
  }

  Future<void> _loadSavedLanguage() async {
    final savedLocale = await LanguageSettingsStorageModel.getSavedLocale();
    setState(() {
      _currentLocale = savedLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for when the provider is initialized
    ref.listen<HealthState>(healthStateProvider, (previous, current) {
      // Only run once when the provider becomes available and authorized
      if (current.isAvailable &&
          current.isAuthorized &&
          (previous == null ||
              !previous.isAvailable ||
              !previous.isAuthorized)) {
        ref.read(healthStateProvider.notifier).performTwoWaySync();
        ref.watch(weightProgressProvider);
      }
    });
    ref.watch(weightProgressProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _currentLocale, // Use saved language preference

      title: 'BodyTrack',
      theme: appTheme, // Use the predefined light theme
      darkTheme: appDarkTheme, // Use the predefined dark theme
      // themeMode: ThemeMode.dark, // or ThemeMode.dark, ThemeMode.system
      home: _onboardingComplete == null
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : _onboardingComplete!
          ? const HomePage() // Onboarding completed
          : const OnboardingScreen(), // Show onboarding
    );
  }
}
