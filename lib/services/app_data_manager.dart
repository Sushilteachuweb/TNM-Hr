import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/job_provider.dart';
import '../Provider/user_provider.dart';
import '../Provider/credit_provider.dart';
import '../Provider/plan_provider.dart';

class AppDataManager {
  static bool _hasInitialized = false;
  static bool _isInitializing = false;

  /// Initialize all app data once when the app starts
  static Future<void> initializeAppData(BuildContext context) async {
    // Prevent multiple simultaneous initializations
    if (_hasInitialized || _isInitializing) {
      print("🚀 App data already initialized or initializing, skipping");
      return;
    }

    _isInitializing = true;
    print("🚀 Initializing app data...");

    try {
      // Load all essential data with individual error handling
      final results = await Future.wait([
        _safeInitialize(() => context.read<JobProvider>().fetchJobs(), "JobProvider"),
        _safeInitialize(() => context.read<UserProvider>().fetchUsers(), "UserProvider"),
        _safeInitialize(() => context.read<CreditProvider>().calculateAvailableCredits(), "CreditProvider"),
        _safeInitialize(() => context.read<PlanProvider>().fetchPlans(), "PlanProvider"),
      ]);

      // Check if any critical providers failed
      bool jobProviderSuccess = results[0];
      bool creditProviderSuccess = results[2];
      
      print("🚀 Initialization results - Jobs: $jobProviderSuccess, Credits: $creditProviderSuccess");

      _hasInitialized = true;
      print("✅ App data initialization completed");
    } catch (e) {
      print("❌ Error initializing app data: $e");
      // Still mark as initialized to prevent infinite retries
      _hasInitialized = true;
    } finally {
      _isInitializing = false;
    }
  }

  /// Safely initialize a provider with error handling
  static Future<bool> _safeInitialize(Future<void> Function() initFunction, String providerName) async {
    try {
      print("🚀 Initializing $providerName...");
      await initFunction();
      print("✅ $providerName initialized successfully");
      return true;
    } catch (e) {
      print("❌ Error initializing $providerName: $e");
      return false;
    }
  }

  /// Force refresh all app data
  static Future<void> refreshAllData(BuildContext context) async {
    print("🔄 Force refreshing all app data...");

    try {
      await Future.wait([
        context.read<JobProvider>().fetchJobs(forceRefresh: true),
        context.read<UserProvider>().fetchUsers(forceRefresh: true),
        context.read<CreditProvider>().calculateAvailableCredits(forceRefresh: true),
        context.read<PlanProvider>().fetchPlans(forceRefresh: true),
      ]);

      print("✅ App data refresh completed");
    } catch (e) {
      print("❌ Error refreshing app data: $e");
    }
  }

  /// Check if app data has been initialized
  static bool get hasInitialized => _hasInitialized;

  /// Check if app data is currently initializing
  static bool get isInitializing => _isInitializing;

  /// Reset initialization state (for testing or app restart)
  static void reset() {
    _hasInitialized = false;
    _isInitializing = false;
    print("🔄 App data manager reset");
  }
}