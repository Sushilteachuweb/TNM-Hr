import 'package:flutter/material.dart';
import '../models/job_plan_model.dart';
import '../services/plan_api_service.dart';

class PlanProvider with ChangeNotifier {
  List<JobPlan> _plans = [];
  bool _isLoading = false;
  String _errorMessage = '';
  JobPlan? _selectedPlan;
  bool _hasLoadedOnce = false; // Track if data has been loaded

  // Getters
  List<JobPlan> get plans => _plans;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  JobPlan? get selectedPlan => _selectedPlan;
  bool get hasLoadedOnce => _hasLoadedOnce;

  // Select a plan
  void selectPlan(JobPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  // Clear selected plan
  void clearSelectedPlan() {
    _selectedPlan = null;
    notifyListeners();
  }

  // Fetch plans from API - only loads if not already loaded, unless force refresh
  Future<void> fetchPlans({bool forceRefresh = false}) async {
    // Skip loading if already loaded and not forcing refresh
    if (_hasLoadedOnce && !forceRefresh) {
      print("📋 Plans already loaded, skipping fetch");
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await PlanApiService.fetchPlans();
      
      if (response['success'] == true && response['data'] != null) {
        _plans = (response['data'] as List)
            .map((planJson) => JobPlan.fromJson(planJson))
            .toList();
        
        // Sort plans by price (ascending)
        _plans.sort((a, b) => a.pricePerMonth.compareTo(b.pricePerMonth));
        
        _hasLoadedOnce = true; // Mark as loaded
        _errorMessage = '';
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch plans';
        _plans = [];
        // Set hasLoadedOnce to true even when API returns success=false to prevent infinite skeleton
        _hasLoadedOnce = true;
      }
    } catch (e) {
      print("❌ Plans fetch error: $e");
      _errorMessage = 'Unable to load plans. Please check your connection and try again.';
      _plans = [];
      // Set hasLoadedOnce to true even on error to prevent infinite skeleton loading
      _hasLoadedOnce = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get plan by ID
  JobPlan? getPlanById(String id) {
    try {
      return _plans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get recommended plan
  JobPlan? get recommendedPlan {
    try {
      return _plans.firstWhere((plan) => plan.isRecommended);
    } catch (e) {
      return null;
    }
  }

  // Clear all data (e.g., on logout)
  void clear() {
    _plans = [];
    _selectedPlan = null;
    _errorMessage = '';
    _hasLoadedOnce = false; // Reset the loaded flag
    notifyListeners();
  }

  // Buy a plan using the new API
  Future<Map<String, dynamic>> buyPlan({
    required String planId,
    required String userId,
    required int amount,
  }) async {
    try {
      final response = await PlanApiService.buyPlan(
        planId: planId,
        userId: userId,
        amount: amount,
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to process plan purchase. Please try again.',
        'order': null
      };
    }
  }
}