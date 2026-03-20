// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'cookie_manager.dart';
import 'user_storage.dart';
import '../models/job_category_model.dart';

class JobApiService {
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Create Job with full details
  static Future<Map<String, dynamic>> createJob({
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
    try {
      print("═══════════════════════════════════════");
      print("🚀 CREATE JOB API CALL STARTED");
      print("═══════════════════════════════════════");
      print("💼 API Endpoint: ${ApiConfig.createJob}");
      print("📱 HR Phone: $hrPhone");
      print("📝 Job Title: $title");
      print("🏢 Company: $companyName");
      print("💰 Plan Type: $planType");
      print("🌍 LOCATION DETAILS:");
      print("  📍 Work Location: $workLocation");
      print("  🏙️ Job Location: $jobLocation");
      print("  ⭐ Preferred Location: $preferredLocation");
      print("  🏠 Office Address: $officeAddress");
      print("═══════════════════════════════════════");

      final body = {
        'hrPhone': hrPhone,
        'title': title,
        'companyName': companyName,
        'jobCategory': jobCategory,
        'jobType': jobType,
        'planType': planType,
        'salaryType': salaryType,
        'salaryRange': salaryRange,
        'workLocation': workLocation,
        'jobLocation': jobLocation,
        'preferredLocation': preferredLocation,
        'officeAddress': officeAddress,
        'floorDetails': floorDetails,
        'coordinates': coordinates,
        'minimumEducation': minimumEducation,
        'englishLevel': englishLevel,
        'totalExperience': totalExperience,
        'openingFor': openingFor,
        'jobDescription': jobDescription,
        'ageRange': ageRange,
        'gender': gender,
        'openings': openings,
        'isWalkInInterview': isWalkInInterview,
        'additionalPerks': additionalPerks, // Keep as array - API expects array
        'documents': documents.join(', '), // create API expects comma-separated string
        'communicationPreference': communicationPreference,
        'workingDays': workingDays,
        'jobTiming': jobTiming,
      };

      print("📦 Request Body:");
      print(jsonEncode(body));
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      print("🔑 Request Headers: $headers");
      print("═══════════════════════════════════════");
      
      print("⏳ Sending request...");
      final response = await http
          .post(
            Uri.parse(ApiConfig.createJob),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print("═══════════════════════════════════════");
      print("📥 RESPONSE RECEIVED");
      print("═══════════════════════════════════════");
      print("📊 Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");
      print("═══════════════════════════════════════");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ SUCCESS: Job created as draft successfully!");
        print("📋 Response Data: $data");
        print("═══════════════════════════════════════");
        return {
          'success': true,
          'message': data['message'] ?? 'Job created as draft successfully',
          'data': data,
          'jobId': data['data']?['_id'] ?? data['data']?['id'],
        };
      } else {
        print("❌ FAILED: Job creation failed");
        print("⚠️ Error Message: ${data['message']}");
        print("═══════════════════════════════════════");
        return {
          'success': false,
          'message': data['message'], // preserve raw (String or List) for friendly parsing
        };
      }
    } on TimeoutException catch (e) {
      print("═══════════════════════════════════════");
      print("⏱️ TIMEOUT ERROR");
      print("═══════════════════════════════════════");
      print("Error: $e");
      print("═══════════════════════════════════════");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("═══════════════════════════════════════");
      print("❌ EXCEPTION OCCURRED");
      print("═══════════════════════════════════════");
      print("Error: $e");
      print("Stack trace: ${StackTrace.current}");
      print("═══════════════════════════════════════");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Get HR Jobs
  static Future<Map<String, dynamic>> getHrJobs() async {
    try {
      // Use phone number as HR ID for fetching jobs
      final phone = await UserStorage.getPhone();
      if (phone.isEmpty) {
        print("❌ No phone number found in storage");
        return {
          'success': false,
          'message': 'Phone number not found. Please log in again.',
        };
      }

      print("💼 Using phone number as HR ID: $phone");
      final endpoint = ApiConfig.getHrJobs(phone);
      print("💼 Calling Get HR Jobs API: $endpoint");

      final headers = await _getHeaders();
      print("💼 Request Headers: $headers");
      
      // Check if we have a valid cookie
      final cookie = await CookieManager.getCookie();
      if (cookie == null || cookie.isEmpty) {
        print("❌ No authentication cookie found - user may not be logged in");
        return {
          'success': false,
          'message': 'Authentication required. Please log in again.',
        };
      }
      
      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print("💼 Raw Response: ${response.body}");
      print("💼 Status Code: ${response.statusCode}");
      print("💼 Response Headers: ${response.headers}");

      // Handle different status codes
      if (response.statusCode == 401) {
        print("❌ Unauthorized - authentication failed");
        return {
          'success': false,
          'message': 'Authentication failed. Please log in again.',
        };
      }

      if (response.statusCode == 404) {
        print("❌ Endpoint not found - API may not exist");
        return {
          'success': false,
          'message': 'Jobs endpoint not found. This may be a new account with no jobs.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Jobs fetched successfully");
        print("💼 Jobs data: $data");
        return {
          'success': true,
          'data': data,
        };
      } else {
        print("❌ Get Jobs failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to fetch jobs',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Get Jobs error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Get Draft Jobs
  static Future<Map<String, dynamic>> getDraftJobs() async {
    try {
      // Use phone number as HR ID for fetching draft jobs
      final phone = await UserStorage.getPhone();
      if (phone.isEmpty) {
        print("❌ No phone number found in storage");
        return {
          'success': false,
          'message': 'Phone number not found. Please log in again.',
        };
      }

      print("💼 Using phone number as HR ID: $phone");
      final endpoint = ApiConfig.getDraftJobs(phone);
      print("💼 Calling Get Draft Jobs API: $endpoint");

      final headers = await _getHeaders();
      print("💼 Request Headers: $headers");
      
      // Check if we have a valid cookie
      final cookie = await CookieManager.getCookie();
      if (cookie == null || cookie.isEmpty) {
        print("❌ No authentication cookie found - user may not be logged in");
        return {
          'success': false,
          'message': 'Authentication required. Please log in again.',
        };
      }
      
      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print("💼 Raw Response: ${response.body}");
      print("💼 Status Code: ${response.statusCode}");
      print("💼 Response Headers: ${response.headers}");

      // Handle different status codes
      if (response.statusCode == 401) {
        print("❌ Unauthorized - authentication failed");
        return {
          'success': false,
          'message': 'Authentication failed. Please log in again.',
        };
      }

      if (response.statusCode == 404) {
        print("❌ Endpoint not found - API may not exist");
        return {
          'success': false,
          'message': 'Draft jobs endpoint not found.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Draft jobs fetched successfully");
        print("💼 Draft jobs data: $data");
        return {
          'success': true,
          'data': data,
        };
      } else {
        print("❌ Get Draft Jobs failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to fetch draft jobs',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Get Draft Jobs error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Update Job
  static Future<Map<String, dynamic>> updateJob({
    required String jobId,
    String? title,
    String? companyName,
    String? jobType,
    String? salaryType,
    Map<String, int>? salaryRange,
    String? workLocation,
    String? jobLocation,
    String? preferredLocation,
    String? officeAddress,
    String? floorDetails,
    List<double>? coordinates,
    String? minimumEducation,
    String? englishLevel,
    String? totalExperience,
    String? jobDescription,
    Map<String, int>? ageRange,
    String? gender,
    int? openings,
    bool? isWalkInInterview,
    List<String>? additionalPerks,
    List<String>? documents,
    String? communicationPreference,
    String? workingDays,
    String? jobTiming,
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.updateJob(jobId));
      print("💼 Calling Update Job API: $uri");

      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (companyName != null) body['companyName'] = companyName;
      if (jobType != null) body['jobType'] = jobType;
      if (salaryType != null) body['salaryType'] = salaryType;
      if (salaryRange != null) body['salaryRange'] = salaryRange;
      if (workLocation != null) body['workLocation'] = workLocation;
      if (jobLocation != null) body['jobLocation'] = jobLocation;
      if (preferredLocation != null) body['preferredLocation'] = preferredLocation;
      if (officeAddress != null) body['officeAddress'] = officeAddress;
      if (floorDetails != null) body['floorDetails'] = floorDetails;
      if (coordinates != null) body['coordinates'] = coordinates;
      if (minimumEducation != null) body['minimumEducation'] = minimumEducation;
      if (englishLevel != null) body['englishLevel'] = englishLevel;
      if (totalExperience != null) body['totalExperience'] = totalExperience;
      if (jobDescription != null) body['jobDescription'] = jobDescription;
      if (ageRange != null) body['ageRange'] = ageRange;
      if (gender != null) body['gender'] = gender;
      if (openings != null) body['openings'] = openings;
      if (isWalkInInterview != null) body['isWalkInInterview'] = isWalkInInterview;
      if (additionalPerks != null) body['additionalPerks'] = additionalPerks;
      if (documents != null) body['documents'] = documents; // Send as array - API expects array
      if (communicationPreference != null) body['communicationPreference'] = communicationPreference;
      if (workingDays != null) body['workingDays'] = workingDays;
      if (jobTiming != null) body['jobTiming'] = jobTiming;

      print("💼 Request Body: $body");

      final headers = await _getHeaders();
      final response = await http
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print("💼 Raw Response: ${response.body}");
      print("💼 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Job updated successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'Job updated successfully',
          'data': data,
        };
      } else {
        print("❌ Update Job failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'], // preserve raw (String or List) for friendly parsing
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Update Job error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Delete Job
  static Future<Map<String, dynamic>> deleteJob(String jobId) async {
    try {
      final uri = Uri.parse(ApiConfig.deleteJob(jobId));

      print("💼 Calling Delete Job API: $uri");

      final headers = await _getHeaders();
      final response = await http
          .delete(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print("💼 Raw Response: ${response.body}");
      print("💼 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Job deleted successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'Job deleted successfully',
        };
      } else {
        print("❌ Delete Job failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to delete job',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Delete Job error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Get Applied Users for Job
  static Future<Map<String, dynamic>> getAppliedUsers(String jobId) async {
    try {
      print(
        "💼 Calling Get Applied Users API: ${ApiConfig.getAppliedUsers(jobId)}",
      );

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.getAppliedUsers(jobId)),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print("💼 Raw Response: ${response.body}");
      print("💼 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Applied users fetched successfully");
        print("💼 Response data structure: ${data.keys}");
        
        // Handle different response structures
        List<dynamic> applicants = [];
        
        if (data['applicants'] != null) {
          applicants = data['applicants'];
        } else if (data['data'] != null && data['data']['applicants'] != null) {
          applicants = data['data']['applicants'];
        } else if (data['data'] != null && data['data'] is List) {
          applicants = data['data'];
        } else if (data is List) {
          applicants = data;
        }
        
        print("💼 Found ${applicants.length} applicants");
        
        return {
          'success': true,
          'data': {
            'applicants': applicants,
          },
        };
      } else {
        final data = jsonDecode(response.body);
        print("❌ Get Applied Users failed: ${data['message']}");
        
        // Handle specific error cases
        String errorMessage = data['message']?.toString() ?? 'Failed to fetch applied users';
        
        // Check for server configuration issues
        if (response.statusCode == 500 && errorMessage.contains('Schema hasn\'t been registered')) {
          errorMessage = 'Server configuration issue. The backend needs to register the Application model schema.';
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Get Applied Users error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Get All Job Categories
  static Future<JobCategoryResponse?> getAllJobCategories() async {
    try {
      print("📂 Calling Get Job Categories API: ${ApiConfig.getAllJobCategories}");

      final response = await http
          .get(
            Uri.parse(ApiConfig.getAllJobCategories),
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      print("📂 Raw Response: ${response.body}");
      print("📂 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Job categories fetched successfully");
        return JobCategoryResponse.fromJson(data);
      } else {
        print("❌ Get Job Categories failed: ${response.statusCode}");
        return null;
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return null;
    } catch (e) {
      print("❌ Get Job Categories error: $e");
      return null;
    }
  }

  /// Publish Job - checks credits and publishes draft job
  static Future<Map<String, dynamic>> publishJob(String jobId) async {
    try {
      print("═══════════════════════════════════════");
      print("🚀 PUBLISH JOB API CALL STARTED");
      print("═══════════════════════════════════════");
      print("💼 API Endpoint: ${ApiConfig.publishJob(jobId)}");
      print("📝 Job ID: $jobId");
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      print("🔑 Request Headers: $headers");
      print("═══════════════════════════════════════");
      
      print("⏳ Sending request...");
      final response = await http
          .post(
            Uri.parse(ApiConfig.publishJob(jobId)),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print("═══════════════════════════════════════");
      print("📥 RESPONSE RECEIVED");
      print("═══════════════════════════════════════");
      print("📊 Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");
      print("═══════════════════════════════════════");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ SUCCESS: Job published successfully!");
        print("📋 Response Data: $data");
        print("═══════════════════════════════════════");
        return {
          'success': true,
          'message': data['message'] ?? 'Job published successfully',
          'data': data,
        };
      } else {
        print("❌ FAILED: Job publish failed");
        print("⚠️ Error Message: ${data['message']}");
        print("═══════════════════════════════════════");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to publish job',
        };
      }
    } on TimeoutException catch (e) {
      print("═══════════════════════════════════════");
      print("⏱️ TIMEOUT ERROR");
      print("═══════════════════════════════════════");
      print("Error: $e");
      print("═══════════════════════════════════════");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("═══════════════════════════════════════");
      print("❌ EXCEPTION OCCURRED");
      print("═══════════════════════════════════════");
      print("Error: $e");
      print("Stack trace: ${StackTrace.current}");
      print("═══════════════════════════════════════");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }
}
