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
      // Fetch both regular jobs and draft jobs
      final results = await Future.wait([
        JobApiService.getHrJobs(),
        JobApiService.getDraftJobs(),
      ]);
      
      final regularJobsResult = results[0];
      final draftJobsResult = results[1];
      
      print("📊 Provider received regular jobs result: ${regularJobsResult['success']}");
      print("📊 Provider received draft jobs result: ${draftJobsResult['success']}");

      List<dynamic> regularJobs = [];
      List<dynamic> draftJobs = [];

      // Extract regular jobs
      if (regularJobsResult['success'] == true) {
        if (regularJobsResult['data'] is List) {
          regularJobs = regularJobsResult['data'];
          print("📊 Regular jobs extracted from List: ${regularJobs.length} jobs");
        } else if (regularJobsResult['data'] is Map && regularJobsResult['data']['jobs'] != null) {
          regularJobs = regularJobsResult['data']['jobs'];
          print("📊 Regular jobs extracted from Map: ${regularJobs.length} jobs");
        } else if (regularJobsResult['data'] is Map && regularJobsResult['data']['data'] != null && regularJobsResult['data']['data']['jobs'] != null) {
          regularJobs = regularJobsResult['data']['data']['jobs'];
          print("📊 Regular jobs extracted from nested data: ${regularJobs.length} jobs");
        } else {
          print("📊 No regular jobs found in response structure");
          print("📊 Result data type: ${regularJobsResult['data'].runtimeType}");
          print("📊 Result data: ${regularJobsResult['data']}");
        }
      }

      // Extract draft jobs
      if (draftJobsResult['success'] == true) {
        if (draftJobsResult['data'] is List) {
          draftJobs = draftJobsResult['data'];
          print("📊 Draft jobs extracted from List: ${draftJobs.length} jobs");
        } else if (draftJobsResult['data'] is Map && draftJobsResult['data']['jobs'] != null) {
          draftJobs = draftJobsResult['data']['jobs'];
          print("📊 Draft jobs extracted from Map: ${draftJobs.length} jobs");
        } else if (draftJobsResult['data'] is Map && draftJobsResult['data']['data'] != null && draftJobsResult['data']['data']['jobs'] != null) {
          draftJobs = draftJobsResult['data']['data']['jobs'];
          print("📊 Draft jobs extracted from nested data: ${draftJobs.length} jobs");
        } else {
          print("📊 No draft jobs found in response structure");
          print("📊 Result data type: ${draftJobsResult['data'].runtimeType}");
          print("📊 Result data: ${draftJobsResult['data']}");
        }
      }

      // Merge regular jobs and draft jobs
      _jobs = [...draftJobs, ...regularJobs];
      print("📊 Total jobs (draft + regular): ${_jobs.length}");
      
      // Update applicant counts for each job
      await _updateApplicantCounts();
      
      _updateJobCounts();
      _hasLoadedOnce = true; // Mark as loaded
      print("📊 Final jobs count: ${_jobs.length}");
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

  /// Create new job with full details (saves as draft)
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
      await fetchJobs(forceRefresh: true); // Force refresh to get updated list
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] ?? 'Failed to create job';
      notifyListeners();
      return false;
    }
  }

  /// Publish a draft job - checks credits and publishes
  Future<Map<String, dynamic>> publishJob(String jobId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await JobApiService.publishJob(jobId);

    _isLoading = false;

    if (result['success'] == true) {
      await fetchJobs(forceRefresh: true); // Refresh list to show updated status
      notifyListeners();
      return {
        'success': true,
        'message': result['message'] ?? 'Job published successfully',
      };
    } else {
      _errorMessage = result['message'] ?? 'Failed to publish job';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
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
      await fetchJobs(forceRefresh: true); // Force refresh to get updated list
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

  /// Update applicant counts for all jobs by fetching actual applicant data
  Future<void> _updateApplicantCounts() async {
    print("📊 Updating applicant counts for ${_jobs.length} jobs");
    
    for (int i = 0; i < _jobs.length; i++) {
      final job = _jobs[i];
      final jobId = job['_id']?.toString() ?? job['id']?.toString();
      
      if (jobId != null && jobId.isNotEmpty) {
        try {
          print("📊 Fetching applicants for job: $jobId");
          final result = await JobApiService.getAppliedUsers(jobId);
          
          if (result['success'] == true) {
            List<dynamic> applicants = result['data']['applicants'] ?? [];
            int actualCount = applicants.length;
            
            // Update the job's applicant count
            _jobs[i]['applicantsCount'] = actualCount;
            print("📊 Updated job $jobId applicant count: $actualCount");
          } else {
            print("📊 Failed to fetch applicants for job $jobId: ${result['message']}");
            // Keep existing count or set to 0 if not present
            _jobs[i]['applicantsCount'] = _jobs[i]['applicantsCount'] ?? 0;
          }
        } catch (e) {
          print("❌ Error fetching applicants for job $jobId: $e");
          // Keep existing count or set to 0 if not present
          _jobs[i]['applicantsCount'] = _jobs[i]['applicantsCount'] ?? 0;
        }
      } else {
        print("📊 Job missing ID, skipping applicant count update");
        _jobs[i]['applicantsCount'] = 0;
      }
    }
    
    print("📊 Finished updating applicant counts");
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

  /// Get draft jobs
  List<dynamic> getDraftJobs() {
    return _jobs.where((job) {
      final status = job['status']?.toString().toLowerCase() ?? '';
      return status == 'draft';
    }).toList();
  }

  /// Get published jobs (active, pending, closed)
  List<dynamic> getPublishedJobs() {
    return _jobs.where((job) {
      final status = job['status']?.toString().toLowerCase() ?? '';
      return status != 'draft';
    }).toList();
  }

  /// Update applicant count for a specific job
  Future<void> updateJobApplicantCount(String jobId) async {
    try {
      print("📊 Updating applicant count for job: $jobId");
      final result = await JobApiService.getAppliedUsers(jobId);
      
      if (result['success'] == true) {
        List<dynamic> applicants = result['data']['applicants'] ?? [];
        int actualCount = applicants.length;
        
        // Find and update the specific job
        for (int i = 0; i < _jobs.length; i++) {
          final job = _jobs[i];
          final currentJobId = job['_id']?.toString() ?? job['id']?.toString();
          
          if (currentJobId == jobId) {
            _jobs[i]['applicantsCount'] = actualCount;
            print("📊 Updated job $jobId applicant count: $actualCount");
            notifyListeners();
            break;
          }
        }
      } else {
        print("📊 Failed to fetch applicants for job $jobId: ${result['message']}");
      }
    } catch (e) {
      print("❌ Error updating applicant count for job $jobId: $e");
    }
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

  /// Refresh applicant counts for all jobs
  Future<void> refreshApplicantCounts() async {
    print("📊 Manually refreshing applicant counts");
    await _updateApplicantCounts();
    notifyListeners();
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
