import 'package:flutter/material.dart';
import '../models/active_plan_model.dart';
import '../services/plan_api_service.dart';

class ActivePlanProvider with ChangeNotifier {
  ActivePlan? _activePlan;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasLoadedOnce = false;

  // Getters
  ActivePlan? get activePlan => _activePlan;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;
  bool get hasActivePlan => _activePlan?.active == true;

  /// Fetch active plan from API - only loads if not already loaded, unless force refresh
  Future<void> fetchActivePlan({bool forceRefresh = false}) async {
    // Skip loading if already loaded and not forcing refresh
    if (_hasLoadedOnce && !forceRefresh) {
      print("📋 Active plan already loaded, skipping fetch");
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await PlanApiService.fetchActivePlan();
      
      if (response['success'] == true && response['data'] != null) {
        _activePlan = ActivePlan.fromJson(response['data']);
        _hasLoadedOnce = true;
        _errorMessage = '';
        print("✅ Active plan loaded: ${_activePlan?.planName}");
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch active plan';
        _activePlan = null;
        _hasLoadedOnce = true;
        print("❌ Failed to load active plan: $_errorMessage");
      }
    } catch (e) {
      print("❌ Active plan fetch error: $e");
      _errorMessage = 'Unable to load plan information. Please try again.';
      _activePlan = null;
      _hasLoadedOnce = true;
      print("💥 Error loading active plan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get remaining credits from active plan
  int get remainingCredits => _activePlan?.remainingCredits ?? 0;

  /// Get total credits from active plan
  int get totalCredits => _activePlan?.totalCredits ?? 0;

  /// Check if plan is about to expire (less than 7 days)
  bool get isExpiringSoon => _activePlan?.remainingDays != null && _activePlan!.remainingDays <= 7;

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear all data (e.g., on logout)
  void clear() {
    _activePlan = null;
    _errorMessage = '';
    _hasLoadedOnce = false;
    notifyListeners();
  }

  /// Refresh active plan data
  Future<void> refresh() async {
    await fetchActivePlan(forceRefresh: true);
  }
}