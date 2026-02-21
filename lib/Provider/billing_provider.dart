import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/billing_history_model.dart';

class BillingProvider with ChangeNotifier {
  List<BillingHistory> _billingHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedFilter = 'all';

  // Getters
  List<BillingHistory> get billingHistory => _billingHistory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  // Get filtered billing history
  List<BillingHistory> get filteredBillingHistory {
    if (_selectedFilter == 'all') {
      return _billingHistory;
    }
    return _billingHistory.where((history) => 
      history.status.toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  // Set filter
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Load billing history from local storage
  Future<void> loadBillingHistory() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final billingHistoryJson = prefs.getString('billing_history');
      
      if (billingHistoryJson != null) {
        final List<dynamic> historyList = json.decode(billingHistoryJson);
        _billingHistory = historyList
            .map((historyJson) => BillingHistory.fromJson(historyJson))
            .toList();
        
        // Sort by date (newest first)
        _billingHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _billingHistory = [];
      }
      
      _errorMessage = '';
    } catch (e) {
      print("❌ Billing history error: $e");
      _errorMessage = 'Unable to load billing history. Please check your connection and try again.';
      _billingHistory = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save billing history to local storage
  Future<void> _saveBillingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final billingHistoryJson = json.encode(
        _billingHistory.map((history) => history.toJson()).toList()
      );
      await prefs.setString('billing_history', billingHistoryJson);
    } catch (e) {
      print('Failed to save billing history: $e');
    }
  }

  // Add a new billing record (called after successful payment)
  Future<void> addBillingRecord({
    required String planName,
    required String planId,
    required int amount,
    required String status,
    required String paymentId,
    required String orderId,
    String? expiresOn,
  }) async {
    final newRecord = BillingHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: BillingHistory.formatDate(DateTime.now()),
      time: BillingHistory.formatTime(DateTime.now()),
      planName: planName,
      planId: planId,
      expiresOn: expiresOn ?? 'N/A',
      amount: amount,
      status: status,
      paymentId: paymentId,
      orderId: orderId,
      createdAt: DateTime.now(),
    );

    _billingHistory.insert(0, newRecord); // Add to beginning (newest first)
    await _saveBillingHistory();
    notifyListeners();
  }

  // Update billing record status (e.g., from pending to success)
  Future<void> updateBillingRecordStatus({
    required String orderId,
    required String status,
    String? paymentId,
  }) async {
    final index = _billingHistory.indexWhere((record) => record.orderId == orderId);
    if (index != -1) {
      final updatedRecord = BillingHistory(
        id: _billingHistory[index].id,
        date: _billingHistory[index].date,
        time: _billingHistory[index].time,
        planName: _billingHistory[index].planName,
        planId: _billingHistory[index].planId,
        expiresOn: _billingHistory[index].expiresOn,
        amount: _billingHistory[index].amount,
        status: status,
        paymentId: paymentId ?? _billingHistory[index].paymentId,
        orderId: _billingHistory[index].orderId,
        createdAt: _billingHistory[index].createdAt,
      );

      _billingHistory[index] = updatedRecord;
      await _saveBillingHistory();
      notifyListeners();
    }
  }

  // Get billing history by status
  List<BillingHistory> getBillingHistoryByStatus(String status) {
    return _billingHistory.where((history) => 
      history.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }

  // Get total count by status
  int getCountByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return _billingHistory.length;
    }
    return getBillingHistoryByStatus(status).length;
  }

  // Clear billing history
  Future<void> clearBillingHistory() async {
    _billingHistory = [];
    _errorMessage = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('billing_history');
    notifyListeners();
  }

  // Clear all data (e.g., on logout)
  void clear() {
    _billingHistory = [];
    _errorMessage = '';
    _selectedFilter = 'all';
    notifyListeners();
  }

  // Initialize - load existing billing history
  Future<void> initialize() async {
    await loadBillingHistory();
  }
}