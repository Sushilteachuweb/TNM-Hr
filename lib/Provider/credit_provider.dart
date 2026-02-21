import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/billing_history_model.dart';
import '../models/job_plan_model.dart';
import '../services/plan_api_service.dart';

class CreditProvider with ChangeNotifier {
  int _availableCredits = 0;
  bool _isLoading = false;
  String _errorMessage = '';
  List<JobPlan> _plans = [];
  bool _hasLoadedOnce = false; // Track if data has been loaded

  // Getters
  int get availableCredits => _availableCredits;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Calculate available credits based on billing history and job postings - only loads if not already loaded, unless force refresh
  Future<void> calculateAvailableCredits({bool forceRefresh = false}) async {
    // Skip loading if already loaded and not forcing refresh
    if (_hasLoadedOnce && !forceRefresh) {
      print("💳 Credits already calculated, skipping calculation");
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // First, fetch plans to get credit information
      await _fetchPlans();
      
      // Get billing history from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final billingHistoryJson = prefs.getString('billing_history');
      
      int totalPurchasedCredits = 0;
      
      if (billingHistoryJson != null) {
        final List<dynamic> historyList = json.decode(billingHistoryJson);
        final billingHistory = historyList
            .map((historyJson) => BillingHistory.fromJson(historyJson))
            .toList();
        
        // Calculate total credits from successful purchases
        for (var billing in billingHistory) {
          if (billing.status.toLowerCase() == 'success') {
            // Find the plan to get credit amount
            final plan = _plans.firstWhere(
              (p) => p.id == billing.planId || p.planName == billing.planName,
              orElse: () => JobPlan(
                id: '',
                planName: '',
                description: '',
                pricePerMonth: 0,
                originalPrice: 0,
                discountPercent: 0,
                credits: 0, // Default to 0 if plan not found
                validityDays: 0,
                jobActiveDays: 0,
                aiMatching: false,
                advancedFilters: 0,
                whatsappLead: false,
                isRecommended: false,
                isCustom: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            
            totalPurchasedCredits += plan.credits;
            print("📊 Added ${plan.credits} credits from plan: ${billing.planName}");
          }
        }
      }
      
      // Get used credits from job postings
      int usedCredits = await _getUsedCredits();
      
      // Calculate available credits
      _availableCredits = totalPurchasedCredits - usedCredits;
      
      // Ensure credits don't go negative
      if (_availableCredits < 0) {
        _availableCredits = 0;
      }
      
      print("📊 Total purchased credits: $totalPurchasedCredits");
      print("📊 Used credits: $usedCredits");
      print("📊 Available credits: $_availableCredits");
      
      _hasLoadedOnce = true; // Mark as loaded
      _errorMessage = '';
    } catch (e) {
      print("❌ Error calculating credits: $e");
      _errorMessage = 'Unable to load credit information. Please try again.';
      print("❌ Error calculating credits: $e");
      // Set hasLoadedOnce to true even on error to prevent infinite skeleton loading
      _hasLoadedOnce = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch plans to get credit information
  Future<void> _fetchPlans() async {
    try {
      final response = await PlanApiService.fetchPlans();
      
      if (response['success'] == true && response['data'] != null) {
        _plans = (response['data'] as List)
            .map((planJson) => JobPlan.fromJson(planJson))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching plans for credit calculation: $e");
    }
  }

  /// Get used credits from job postings
  /// This is a simplified calculation - in a real app, you'd track this via API
  Future<int> _getUsedCredits() async {
    try {
      // Get jobs from SharedPreferences or calculate based on job count
      // For now, we'll assume each job costs 1 credit
      // In a real implementation, you'd track this via API or local storage
      
      final prefs = await SharedPreferences.getInstance();
      final usedCredits = prefs.getInt('used_credits') ?? 0;
      
      return usedCredits;
    } catch (e) {
      print("❌ Error getting used credits: $e");
      return 0;
    }
  }

  /// Deduct credits when a job is posted
  Future<void> deductCredits(int creditsToDeduct) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUsedCredits = prefs.getInt('used_credits') ?? 0;
      await prefs.setInt('used_credits', currentUsedCredits + creditsToDeduct);
      
      // Recalculate available credits
      await calculateAvailableCredits();
      
      print("📊 Deducted $creditsToDeduct credits. New used credits: ${currentUsedCredits + creditsToDeduct}");
    } catch (e) {
      print("❌ Error deducting credits: $e");
    }
  }

  /// Add credits when a plan is purchased (called after successful payment)
  Future<void> addCreditsFromPlan(String planId, String planName) async {
    try {
      // Find the plan to get credit amount
      final plan = _plans.firstWhere(
        (p) => p.id == planId || p.planName == planName,
        orElse: () => JobPlan(
          id: '',
          planName: '',
          description: '',
          pricePerMonth: 0,
          originalPrice: 0,
          discountPercent: 0,
          credits: 0,
          validityDays: 0,
          jobActiveDays: 0,
          aiMatching: false,
          advancedFilters: 0,
          whatsappLead: false,
          isRecommended: false,
          isCustom: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (plan.credits > 0) {
        // Recalculate available credits to include the new purchase
        await calculateAvailableCredits();
        print("📊 Added ${plan.credits} credits from plan purchase: $planName");
      }
    } catch (e) {
      print("❌ Error adding credits from plan: $e");
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Reset credits (for testing or admin purposes)
  Future<void> resetCredits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('used_credits');
      await calculateAvailableCredits();
      print("📊 Credits reset successfully");
    } catch (e) {
      print("❌ Error resetting credits: $e");
    }
  }

  /// Clear all data (e.g., on logout)
  void clear() {
    _availableCredits = 0;
    _plans = [];
    _errorMessage = '';
    _hasLoadedOnce = false; // Reset the loaded flag
    notifyListeners();
  }
}