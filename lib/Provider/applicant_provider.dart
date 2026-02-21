import 'package:flutter/material.dart';
import '../services/job_api_service.dart';

class ApplicantProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _applicants = [];
  Set<String> _contactedApplicants = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get applicants => _applicants;
  int get applicantsCount => _applicants.length;
  int get contactedCount => _contactedApplicants.length;

  /// Fetch applied users for a specific job
  Future<void> fetchApplicants(String jobId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await JobApiService.getAppliedUsers(jobId);

    if (result['success'] == true) {
      _applicants = result['data']['applicants'] ?? [];
    } else {
      // Handle specific server errors more gracefully
      String errorMessage = result['message'] ?? 'Failed to fetch applicants';
      
      // Check for specific backend schema error
      if (errorMessage.contains('Schema hasn\'t been registered for model "Application"')) {
        _errorMessage = 'Server configuration issue. Please contact support or try again later.';
      } else if (errorMessage.contains('Server is not responding')) {
        _errorMessage = 'Unable to connect to server. Please check your internet connection.';
      } else {
        _errorMessage = errorMessage;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mark applicant as contacted
  void markAsContacted(String applicantId) {
    _contactedApplicants.add(applicantId);
    notifyListeners();
  }

  /// Check if applicant is contacted
  bool isContacted(String applicantId) {
    return _contactedApplicants.contains(applicantId);
  }

  /// Get contacted applicants
  List<dynamic> getContactedApplicants() {
    return _applicants
        .where((applicant) {
          final id = applicant['_id'] ?? applicant['id'] ?? '';
          return _contactedApplicants.contains(id);
        })
        .toList();
  }

  /// Get non-contacted applicants
  List<dynamic> getNonContactedApplicants() {
    return _applicants
        .where((applicant) {
          final id = applicant['_id'] ?? applicant['id'] ?? '';
          return !_contactedApplicants.contains(id);
        })
        .toList();
  }

  /// Remove applicant from list (local only)
  void removeApplicant(String applicantId) {
    _applicants.removeWhere((applicant) {
      final id = applicant['_id'] ?? applicant['id'] ?? '';
      return id == applicantId;
    });
    _contactedApplicants.remove(applicantId);
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _applicants = [];
    _contactedApplicants.clear();
    _errorMessage = '';
    notifyListeners();
  }
}
