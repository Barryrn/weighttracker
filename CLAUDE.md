# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter weight tracking application called "BodyTrack" that helps users monitor weight, body composition, and visual progress over time. The app includes photo tracking, BMI calculations, body fat percentage tracking, calorie calculations, and TDEE calculations based on weight changes.

## Common Development Commands

### Build and Run
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS
- `flutter clean` - Clean build files
- `flutter pub get` - Install dependencies

### Code Quality
- `flutter analyze` - Run static analysis (uses `analysis_options.yaml`)
- `flutter test` - Run tests
- `flutter pub outdated` - Check for dependency updates

### Internationalization
- `flutter gen-l10n` - Generate localization files from ARB files
- Localization files are in `lib/l10n/` with support for EN, DE, ES, FR, IT, PL, PT, TR

## Architecture and Code Structure

### State Management
- **Riverpod**: Primary state management solution (flutter_riverpod)
- **Providers**: Located in `lib/ViewModel/` directory
- **Key Providers**:
  - `healthStateProvider` - HealthKit/Health Connect integration
  - `weightProgressProvider` - Weight data management
  - `latestWeightProvider` - Current weight tracking
  - Various view models for different features

### Directory Structure
```
lib/
├── main.dart                 # App entry point with Riverpod setup
├── theme.dart               # App theming (light/dark themes)
├── View/                    # UI screens and pages
│   ├── footer_pages/        # Bottom navigation pages
│   └── *.dart              # Individual screen components
├── ViewModel/              # Riverpod providers and business logic
├── model/                  # Data models and database helper
│   └── database_helper.dart # SQLite database management
├── Widget/                 # Reusable UI components
├── service/                # Services (image migration, etc.)
├── l10n/                   # Internationalization files
└── repository/             # Data access layer
```

### Database
- **SQLite** with sqflite package
- Database managed by `DatabaseHelper` singleton class
- Main table: `body_entries` storing weight, body measurements, images, notes
- Database version: 7 (increment when schema changes)
- Automatic migration handled in `ImageMigrationService`

### Key Features and Components
1. **Weight Tracking**: Core weight entry and progress tracking
2. **Image Timeline**: Photo progress tracking with front/side/back views
3. **Body Composition**: BMI, body fat percentage, circumference measurements
4. **Health Integration**: HealthKit (iOS) and Health Connect (Android) sync
5. **Calorie Tracking**: Daily calorie entries and TDEE calculations
6. **Data Visualization**: Charts using fl_chart package
7. **Internationalization**: 8 language support

### Theme System
- Custom themes in `theme.dart` (light and dark modes)
- Uses Google Fonts for typography
- Card-based UI design following material design principles
- App follows portrait-only orientation

### Image Handling
- Image picker for progress photos
- Image compression and cropping capabilities
- Images stored in Application Support directory
- Migration service handles moving images to correct directories

### Data Persistence
- SQLite for local data storage
- SharedPreferences for app settings and onboarding state
- Profile settings stored separately from body entries

### Important Dependencies
- **sqflite**: Local database
- **riverpod/flutter_riverpod**: State management
- **health**: HealthKit/Health Connect integration
- **image_picker/image_cropper**: Photo handling
- **fl_chart**: Data visualization
- **path_provider**: File system access
- **shared_preferences**: Simple key-value storage

## Development Notes

### Onboarding Flow
- First-time users go through `OnboardingScreen`
- Completion status stored in SharedPreferences
- Main app shows `HomePage` after onboarding

### Health Integration
- Automatic two-way sync with HealthKit/Health Connect
- Permission handling for health data access
- Manual entry flag distinguishes user vs. health app entries

### Localization
- ARB files in `lib/l10n/` for translations
- Generated localizations support 8 languages
- Language preference persisted using `LanguageSettingsStorageModel`

### Image Migration
- App includes service to migrate images to proper directories
- Runs automatically on app startup in main.dart

### Testing
- Test files located in `test/` directory
- Use `flutter test` to run test suite