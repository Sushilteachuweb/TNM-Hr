import 'package:flutter/material.dart';
import '../services/job_api_service.dart';

class JobProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _jobs = [];
  Map<String, int> _jobCounts = {
    'active': 0,
    'pending': 0,
    'closed': 0,
  };
  bool _hasLoadedOnce = false; // Track if data has been loaded

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get jobs => _jobs;
  Map<String, int> get jobCounts => _jobCounts;
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Fetch all jobs - only loads if not already loaded, unless force refresh
  Future<void> fetchJobs({bool forceRefresh = false}) async {
    // Skip loading if already loaded and not forcing refresh
    if (_hasLoadedOnce && !forceRefresh) {
      print("📊 Jobs already loaded, skipping fetch");
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await JobApiService.getHrJobs();
      print("📊 Provider received result: ${result['success']}");

      if (result['success'] == true) {
        // Handle different response structures
        if (result['data'] is List) {
          _jobs = result['data'];
          print("📊 Jobs extracted from List: ${_jobs.length} jobs");
        } else if (result['data'] is Map && result['data']['jobs'] != null) {
          _jobs = result['data']['jobs'];
          print("📊 Jobs extracted from Map: ${_jobs.length} jobs");
        } else if (result['data'] is Map && result['data']['data'] != null && result['data']['data']['jobs'] != null) {
          _jobs = result['data']['data']['jobs'];
          print("📊 Jobs extracted from nested data: ${_jobs.length} jobs");
        } else {
          _jobs = [];
          print("📊 No jobs found in response structure");
          print("📊 Result data type: ${result['data'].runtimeType}");
          print("📊 Result data: ${result['data']}");
        }
        _updateJobCounts();
        _hasLoadedOnce = true; // Mark as loaded
        print("📊 Final jobs count: ${_jobs.length}");
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch jobs';
        _jobs = [];
        print("📊 API returned success=false");
        // Set hasLoadedOnce to true even when API returns success=false to prevent infinite skeleton
        _hasLoadedOnce = true;
      }
    } catch (e) {
      print("❌ Error in fetchJobs: $e");
      _errorMessage = 'Failed to fetch jobs';
      _jobs = [];
      // Set hasLoadedOnce to true even on error to prevent infinite skeleton loading
      _hasLoadedOnce = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create new job with full details
  Future<bool> createJob({
    required String hrPhone,
    required String title,
    required String companyName,
    required String jobCategory,
    required String jobType,
    required String planType,
    required String salaryType,
    required Map<String, int> salaryRange,
    required String workLocation,
    required String jobLocation,
    required String preferredLocation,
    required String officeAddress,
    required String floorDetails,
    required List<double> coordinates,
    required String minimumEducation,
    required String englishLevel,
    required String totalExperience,
    required String openingFor,
    required String jobDescription,
    required Map<String, int> ageRange,
    required String gender,
    required int openings,
    required bool isWalkInInterview,
    required List<String> additionalPerks,
    required List<String> documents,
    required String communicationPreference,
    required String workingDays,
    required String jobTiming,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await JobApiService.createJob(
      hrPhone: hrPhone,
      title: title,
      companyName: companyName,
      jobCategory: jobCategory,
      jobType: jobType,
      planType: planType,
      salaryType: salaryType,
      salaryRange: salaryRange,
      workLocation: workLocation,
      jobLocation: jobLocation,
      preferredLocation: preferredLocation,
      officeAddress: officeAddress,
      floorDetails: floorDetails,
      coordinates: coordinates,
      minimumEducation: minimumEducation,
      englishLevel: englishLevel,
      totalExperience: totalExperience,
      openingFor: openingFor,
      jobDescription: jobDescription,
      ageRange: ageRange,
      gender: gender,
      openings: openings,
      isWalkInInterview: isWalkInInterview,
      additionalPerks: additionalPerks,
      documents: documents,
      communicationPreference: communicationPreference,
      workingDays: workingDays,
      jobTiming: jobTiming,
    );

    _isLoading = false;

    print("💼 Create Job Result: $result");

    if (result['success'] == true) {
      // Check if payment is required
      if (result['data'] != null && result['data']['paymentRequired'] == true) {
        _errorMessage = 'Payment required for premium job posting';
        notifyListeners();
        return false;
      }
      
      await fetchJobs(); // Refresh list
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to create job';
      notifyListeners();
      return false;
    }
  }

  /// Update job
  Future<bool> updateJob({
    required String jobId,
    String? title,
    String? description,
    int? salary,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await JobApiService.updateJob(
      jobId: jobId,
      title: title,
      description: description,
      salary: salary,
      location: location,
    );

    _isLoading = false;

    if (result['success'] == true) {
      await fetchJobs(); // Refresh list
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to update job';
      notifyListeners();
      return false;
    }
  }

  /// Delete job
  Future<bool> deleteJob(String jobId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await JobApiService.deleteJob(jobId);

    _isLoading = false;

    if (result['success'] == true) {
      await fetchJobs(); // Refresh list
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to delete job';
      notifyListeners();
      return false;
    }
  }

  /// Update job counts based on fetched jobs
  void _updateJobCounts() {
    _jobCounts = {
      'active': _jobs.where((job) => job['status'] == 'active').length,
      'pending': _jobs.where((job) => job['status'] == 'pending').length,
      'closed': _jobs.where((job) => job['status'] == 'closed').length,
    };
  }

  /// Filter jobs by status
  List<dynamic> getJobsByStatus(String status) {
    // If no status filter is needed, return all jobs
    if (status.toLowerCase() == 'all') {
      return _jobs;
    }
    
    return _jobs.where((job) {
      final jobStatus = job['status']?.toString().toLowerCase() ?? 'active';
      return jobStatus == status.toLowerCase();
    }).toList();
  }

  /// Get total count of unique candidates who applied to HR's jobs
  Future<int> getAppliedCandidatesCount() async {
    Set<String> uniqueCandidates = {};
    
    try {
      print("📊 Getting applied candidates count for ${_jobs.length} jobs");
      
      // Iterate through all HR's jobs and collect unique applicants
      for (var job in _jobs) {
        String jobId = job['_id'] ?? job['id'] ?? '';
        if (jobId.isNotEmpty) {
          print("📊 Fetching applicants for job: $jobId");
          final result = await JobApiService.getAppliedUsers(jobId);
          if (result['success'] == true) {
            List<dynamic> applicants = result['data']['applicants'] ?? [];
            print("📊 Found ${applicants.length} applicants for job $jobId");
            for (var applicant in applicants) {
              String candidateId = applicant['id'] ?? applicant['_id'] ?? '';
              if (candidateId.isNotEmpty) {
                uniqueCandidates.add(candidateId);
              }
            }
          } else {
            print("📊 Failed to fetch applicants for job $jobId: ${result['message']}");
          }
        }
      }
      
      print("📊 Total unique candidates who applied: ${uniqueCandidates.length}");
    } catch (e) {
      print("❌ Error getting applied candidates count: $e");
    }
    
    return uniqueCandidates.length;
  }

  /// Clear all data (e.g., on logout)
  void clear() {
    _jobs = [];
    _jobCounts = {
      'active': 0,
      'pending': 0,
      'closed': 0,
    };
    _errorMessage = '';
    _hasLoadedOnce = false; // Reset the loaded flag
    notifyListeners();
  }
}
