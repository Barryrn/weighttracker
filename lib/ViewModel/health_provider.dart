import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/health_service.dart';
import '../model/body_entry_model.dart';
import '../repository/weight_repository.dart';
import '../model/health_sync_storage_model.dart'; // Add this import
import 'package:permission_handler/permission_handler.dart';

/// State class for health integration
class HealthState {
  final bool isAvailable;
  final bool isAuthorized;
  final bool isSyncing;
  final String? errorMessage;
  final DateTime? lastSyncTime;

  const HealthState({
    this.isAvailable = false,
    this.isAuthorized = false,
    this.isSyncing = false,
    this.errorMessage,
    this.lastSyncTime,
  });

  HealthState copyWith({
    bool? isAvailable,
    bool? isAuthorized,
    bool? isSyncing,
    String? errorMessage,
    DateTime? lastSyncTime,
    bool clearError = false,
  }) {
    return HealthState(
      isAvailable: isAvailable ?? this.isAvailable,
      isAuthorized: isAuthorized ?? this.isAuthorized,
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Notifier class for managing health state
class HealthStateNotifier extends StateNotifier<HealthState> {
  final HealthService _healthService;

  HealthStateNotifier(this._healthService) : super(const HealthState()) {
    // Initialize health service and check availability when initialized
    _initializeHealthService();
  }

  /// Initialize the health service
  Future<void> _initializeHealthService() async {
    try {
      await _healthService.initialize();
      // Load last sync time from SharedPreferences
      final lastSyncTime = await HealthSyncStorage.loadLastSyncTime();
      state = state.copyWith(lastSyncTime: lastSyncTime);
      checkAvailability();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error initializing health service: $e',
      );
      debugPrint('Error initializing health service: $e');
    }
  }

  /// Check if health services are available on the device
  Future<void> checkAvailability() async {
    try {
      final isAvailable = await _healthService.isHealthDataAvailable();
      state = state.copyWith(isAvailable: isAvailable, clearError: true);

      if (isAvailable) {
        // If available, check authorization
        await checkAuthorization();
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error checking health availability: $e',
      );
      debugPrint('Error checking health availability: $e');
    }
  }

  /// Check if the app is authorized to access health data
  Future<void> checkAuthorization() async {
    if (!state.isAvailable) return;

    try {
      final isAuthorized = await _healthService.requestAuthorization();
      state = state.copyWith(isAuthorized: isAuthorized, clearError: true);

      // Automatically sync if authorized
      if (isAuthorized) {
        performTwoWaySync();
      }
    } catch (e) {
      // Error handling...
    }
  }

  /// Request authorization to access health data
  Future<bool> requestAuthorization() async {
    if (!state.isAvailable) return false;

    try {
      state = state.copyWith(clearError: true);
      final isAuthorized = await _healthService.requestAuthorization();
      state = state.copyWith(isAuthorized: isAuthorized);
      return isAuthorized;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error requesting health authorization: $e',
      );
      debugPrint('Error requesting health authorization: $e');
      return false;
    }
  }

  /// Sync weight data to health services
  Future<bool> syncToHealth(List<BodyEntry> entries) async {
    if (!state.isAvailable || !state.isAuthorized) return false;

    try {
      state = state.copyWith(isSyncing: true, clearError: true);
      final success = await _healthService.syncDataToHealth(entries);

      if (success) {
        final now = DateTime.now();
        state = state.copyWith(isSyncing: false, lastSyncTime: now);
        // Save last sync time to SharedPreferences
        await HealthSyncStorage.saveLastSyncTime(now);
      } else {
        state = state.copyWith(
          isSyncing: false,
          errorMessage: 'Failed to sync data to health services',
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Error syncing to health: $e',
      );
      debugPrint('Error syncing to health: $e');
      return false;
    }
  }

  /// Fetch weight data from health services
  Future<List<BodyEntry>> fetchFromHealth(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (!state.isAvailable || !state.isAuthorized) return [];

    try {
      state = state.copyWith(isSyncing: true, clearError: true);
      final entries = await _healthService.fetchtDataFromHealth(
        startDate,
        endDate,
      );

      if (entries.isNotEmpty) {
        final now = DateTime.now();
        state = state.copyWith(isSyncing: false, lastSyncTime: now);
        // Save last sync time to SharedPreferences
        await HealthSyncStorage.saveLastSyncTime(now);
      } else {
        state = state.copyWith(isSyncing: false);
      }

      return entries;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Error fetching from health: $e',
      );
      debugPrint('Error fetching from health: $e');
      return [];
    }
  }

  /// Perform a two-way sync between the app and health services
  Future<bool> performTwoWaySync() async {
    if (!state.isAvailable || !state.isAuthorized) return false;

    try {
      state = state.copyWith(isSyncing: true, clearError: true);
      final success = await _healthService.performTwoWaySync();

      if (success) {
        final now = DateTime.now();
        state = state.copyWith(isSyncing: false, lastSyncTime: now);
        // Save last sync time to SharedPreferences
        await HealthSyncStorage.saveLastSyncTime(now);
      } else {
        state = state.copyWith(
          isSyncing: false,
          errorMessage:
              'Two-way sync failed. Please check your health data permissions and try again.',
        );
        debugPrint('Two-way sync failed - health service returned false');
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Error performing two-way sync: ${e.toString()}',
      );
      debugPrint('Error performing two-way sync: $e');
      return false;
    }
  }
}

/// Provider for the HealthService
final healthServiceProvider = Provider<HealthService>((ref) {
  final weightRepository = WeightRepository();
  return HealthService(weightRepository: weightRepository);
});

/// Provider for health integration state
final healthStateProvider =
    StateNotifierProvider<HealthStateNotifier, HealthState>((ref) {
      final healthService = ref.watch(healthServiceProvider);
      return HealthStateNotifier(healthService);
    });
