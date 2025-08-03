# Apple Health Synchronization in WeightTracker

## Overview

The WeightTracker app implements a two-way synchronization with Apple Health (on iOS) and Google Health Connect (on Android). This document explains how the synchronization works, what data is exchanged, and the technical implementation details.

## Data Types Synchronized

The app currently synchronizes the following data types with health platforms:

1. **Weight measurements** - Both read and write access
2. **Body fat percentage** - Both read and write access

## Synchronization Direction

The synchronization is bidirectional (two-way):

- **App to Health Platform**: Data entered in the WeightTracker app is uploaded to Apple Health/Google Health Connect
- **Health Platform to App**: Data entered in Apple Health/Google Health Connect is imported into the WeightTracker app

## How Two-Way Sync Works

### 1. Authorization

Before any synchronization can occur, the app requests authorization from the health platform:

- The app requests READ_WRITE permissions for weight and body fat percentage
- The user must explicitly grant these permissions in the Apple Health/Google Health Connect interface
- Without these permissions, synchronization will not occur

### 2. App to Health Platform (Upload)

When data is entered in the WeightTracker app:

1. The data is first saved to the app's local SQLite database
2. The app then calls `syncWeightDataToHealth()` which:
   - Iterates through each entry in the app's database
   - For each entry, writes the weight data to the health platform using `writeHealthData()`
   - If fat percentage data is available, it also writes that data

### 3. Health Platform to App (Download)

When syncing from the health platform to the app:

1. The app calls `fetchWeightDataFromHealth()` which:
   - Retrieves weight data from the health platform for a specified date range
   - Retrieves body fat percentage data for the same date range
   - Combines this data into BodyEntry objects

### 4. Two-Way Sync Process

The complete two-way sync process is implemented in the `performTwoWaySync()` method and follows these steps:

1. Request authorization from the health platform
2. Determine the date range for syncing (from earliest entry to current date)
3. Fetch all entries from the app's database
4. Upload app data to the health platform using `syncWeightDataToHealth()`
5. Download data from the health platform using `fetchWeightDataFromHealth()`
6. For each entry downloaded from the health platform:
   - Check if an entry with the same date already exists in the app's database
   - If no matching entry exists, add the new entry to the database
   - If a matching entry exists, update the existing entry with the health platform data

## Conflict Resolution

When the same date has entries in both the app and the health platform, the app uses a simple "last write wins" approach:

- During two-way sync, health platform data will overwrite app data for the same date
- This ensures that the most recent data entry (whether from the app or health platform) is preserved

## Technical Implementation

The synchronization is implemented using the `health` Flutter package, which provides a cross-platform API for interacting with Apple Health and Google Health Connect.

Key classes involved:

1. **HealthService**: Manages all health platform interactions
2. **WeightRepository**: Manages the app's local database operations
3. **DatabaseHelper**: Provides low-level database access
4. **BodyEntry**: Data model representing weight and body measurements

## Platform Differences

- **iOS**: Uses HealthKit, which is available on all iOS devices running iOS 8 or later
- **Android**: Uses Health Connect, which requires checking for availability before use

## Privacy Considerations

Health data is sensitive personal information. The app:

- Only requests the minimum permissions needed
- Syncs data only when explicitly triggered
- Does not send health data to any external servers
- Respects the user's decision if they deny health platform access