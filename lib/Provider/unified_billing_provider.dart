import 'package:flutter/material.dart';
import '../models/active_plan_model.dart';
import '../models/payment_history_model.dart';
import '../services/plan_api_service.dart';
import '../services/payment_history_api_service.dart';
import '../services/user_storage.dart';

class UnifiedBillingProvider with ChangeNotifier {
  // Active Plan Data
  ActivePlan? _activePlan;
  bool _activePlanLoading = false;
  String _activePlanError = '';

  // Payment History Data
  List<PaymentHistory> _paymentHistory = [];
  bool _paymentHistoryLoading = false;
  String _paymentHistoryError = '';
  int _totalPayments = 0;

  // Filter state
  String _selectedFilter = 'all';

  // Loading state
  bool _hasLoadedOnce = false;

  // Getters for Active Plan
  ActivePlan? get activePlan => _activePlan;
  bool get activePlanLoading => _activePlanLoading;
  String get activePlanError => _activePlanError;
  bool get hasActivePlan => _activePlan?.active == true;
  int get remainingCredits => _activePlan?.remainingCredits ?? 0;
  int get totalCredits => _activePlan?.totalCredits ?? 0;
  bool get isExpiringSoon => _activePlan?.remainingDays != null && _activePlan!.remainingDays <= 7;

  // Getters for Payment History
  List<PaymentHistory> get paymentHistory => _paymentHistory;
  bool get paymentHistoryLoading => _paymentHistoryLoading;
  String get paymentHistoryError => _paymentHistoryError;
  int get totalPayments => _totalPayments;
  String get selectedFilter => _selectedFilter;
  bool get hasLoadedOnce => _hasLoadedOnce;

  // Combined loading state
  bool get isLoading => _activePlanLoading || _paymentHistoryLoading;
  String get errorMessage => _activePlanError.isNotEmpty ? _activePlanError : _paymentHistoryError;

  // Get filtered payment history
  List<PaymentHistory> get filteredPaymentHistory {
    if (_selectedFilter == 'all') {
      return _paymentHistory;
    }
    return _paymentHistory.where((history) => 
      history.status.toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  /// Set filter for payment history
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Fetch both active plan and payment history
  Future<void> fetchAllData({bool forceRefresh = false}) async {
    // Skip loading if already loaded and not forcing refresh
    if (_hasLoadedOnce && !forceRefresh) {
      print("📋 Billing data already loaded, skipping fetch");
      return;
    }

    // Fetch both active plan and payment history in parallel
    await Future.wait([
      _fetchActivePlan(),
      _fetchPaymentHistory(),
    ]);

    _hasLoadedOnce = true;
  }

  /// Fetch active plan data
  Future<void> _fetchActivePlan() async {
    _activePlanLoading = true;
    _activePlanError = '';
    notifyListeners();

    try {
      final response = await PlanApiService.fetchActivePlan();
      
      if (response['success'] == true && response['data'] != null) {
        _activePlan = ActivePlan.fromJson(response['data']);
        _activePlanError = '';
        print("✅ Active plan loaded: ${_activePlan?.planName}");
      } else {
        _activePlanError = response['message'] ?? 'Failed to fetch active plan';
        _activePlan = null;
        print("❌ Failed to load active plan: $_activePlanError");
      }
    } catch (e) {
      _activePlanError = 'Network error: $e';
      _activePlan = null;
      print("💥 Error loading active plan: $e");
    } finally {
      _activePlanLoading = false;
      notifyListeners();
    }
  }

  /// Fetch payment history data
  Future<void> _fetchPaymentHistory() async {
    _paymentHistoryLoading = true;
    _paymentHistoryError = '';
    notifyListeners();

    try {
      // Get mobile number from user storage
      final mobileNumber = await UserStorage.getPhone();
      if (mobileNumber.isEmpty) {
        _paymentHistoryError = 'Mobile number not found';
        _paymentHistory = [];
        _totalPayments = 0;
        return;
      }

      final response = await PaymentHistoryApiService.fetchPaymentHistory(mobileNumber);
      
      if (response['success'] == true && response['payments'] != null) {
        _paymentHistory = (response['payments'] as List)
            .map((paymentJson) => PaymentHistory.fromJson(paymentJson))
            .toList();
        
        // Sort by creation date (newest first)
        _paymentHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        _totalPayments = response['total'] ?? _paymentHistory.length;
        _paymentHistoryError = '';
        print("✅ Payment history loaded: ${_paymentHistory.length} payments");
      } else {
        _paymentHistoryError = response['message'] ?? 'Failed to fetch payment history';
        _paymentHistory = [];
        _totalPayments = 0;
        print("❌ Failed to load payment history: $_paymentHistoryError");
      }
    } catch (e) {
      _paymentHistoryError = 'Network error: $e';
      _paymentHistory = [];
      _totalPayments = 0;
      print("💥 Error loading payment history: $e");
    } finally {
      _paymentHistoryLoading = false;
      notifyListeners();
    }
  }

  /// Refresh active plan data only
  Future<void> refreshActivePlan() async {
    await _fetchActivePlan();
  }

  /// Refresh payment history data only
  Future<void> refreshPaymentHistory() async {
    await _fetchPaymentHistory();
  }

  /// Refresh all data
  Future<void> refresh() async {
    await fetchAllData(forceRefresh: true);
  }

  /// Get payment history by status
  List<PaymentHistory> getPaymentHistoryByStatus(String status) {
    return _paymentHistory.where((history) => 
      history.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }

  /// Get total count by status
  int getCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _paymentHistory.length;
    }
    return getPaymentHistoryByStatus(status).length;
  }

  /// Clear error messages
  void clearErrors() {
    _activePlanError = '';
    _paymentHistoryError = '';
    notifyListeners();
  }

  /// Clear all data (e.g., on logout)
  void clear() {
    _activePlan = null;
    _paymentHistory = [];
    _activePlanError = '';
    _paymentHistoryError = '';
    _selectedFilter = 'all';
    _totalPayments = 0;
    _hasLoadedOnce = false;
    notifyListeners();
  }
}