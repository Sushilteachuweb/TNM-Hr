// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_routes.dart';
import 'cookie_manager.dart';

class HrProfileApiService {
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Update HR Profile
  /// Requires active HR session
  static Future<Map<String, dynamic>> updateHrProfile({
    String? fullName,
    String? companyName,
    String? email,
    String? designation,
    String? experience,
    String? hrLocation,
    String? bio,
    String? skills,
    File? profilePhoto,
  }) async {
    try {
      print("👤 Calling Update HR Profile API: ${ApiConfig.updateHrProfile}");

      final headers = await _getHeaders();
      
      // Create multipart request for file upload
      var request = http.MultipartRequest('PUT', Uri.parse(ApiConfig.updateHrProfile));
      
      // Add headers
      request.headers.addAll(headers);
      
      // Add text fields
      if (fullName != null) request.fields['fullName'] = fullName;
      if (companyName != null) request.fields['companyName'] = companyName;
      if (email != null) request.fields['email'] = email;
      if (designation != null) request.fields['designation'] = designation;
      if (experience != null) {
        // Ensure experience is a valid number
        final expNum = int.tryParse(experience);
        if (expNum != null) {
          request.fields['experience'] = expNum.toString();
        }
      }
      if (hrLocation != null) request.fields['hrLocation'] = hrLocation;
      if (bio != null) request.fields['bio'] = bio;
      if (skills != null && skills.isNotEmpty) {
        request.fields['skills[0]'] = skills; // Based on Postman format
      }
      
      // Add profile photo if provided
      if (profilePhoto != null) {
        // Validate file extension
        final fileName = profilePhoto.path.toLowerCase();
        final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
        final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));
        
        if (!hasValidExtension) {
          print("❌ Invalid file type. Only jpg, jpeg, png, gif, webp are allowed");
          return {
            'success': false,
            'message': 'Only image files are allowed (jpg, jpeg, png, gif, webp)',
          };
        }
        
        // Determine MIME type based on extension
        String mimeType = 'image/jpeg'; // default
        if (fileName.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (fileName.endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (fileName.endsWith('.webp')) {
          mimeType = 'image/webp';
        }
        
        request.files.add(await http.MultipartFile.fromPath(
          'profilePhoto',
          profilePhoto.path,
          contentType: MediaType.parse(mimeType),
        ));
        print("📸 Added profile photo: ${profilePhoto.path} (${mimeType})");
      }

      print("👤 Request Fields: ${request.fields}");
      print("👤 Request Files: ${request.files.map((f) => f.field).toList()}");

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print("👤 Raw Response: ${response.body}");
      print("👤 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ HR Profile updated successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
          'data': data,
        };
      } else {
        print("❌ Update HR Profile failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to update profile',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Update HR Profile error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Fetch HR Profile
  static Future<Map<String, dynamic>> getHrProfile(String hrId) async {
    try {
      print("👤 Calling Get HR Profile API: ${ApiConfig.getHrProfile(hrId)}");

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.getHrProfile(hrId)),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print("👤 Raw Response: ${response.body}");
      print("👤 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("👤 Decoded Data: $data");
      print("👤 Data Type: ${data.runtimeType}");

      if (response.statusCode == 200) {
        print("✅ HR Profile fetched successfully");
        
        // Check if data is wrapped in a 'data' or 'user' key, or if it's an array
        Map<String, dynamic> profileData;
        
        if (data is List && data.isNotEmpty) {
          // If response is an array, take the first item
          print("👤 Response is a List, taking first item");
          profileData = data[0];
        } else if (data is Map<String, dynamic>) {
          // Handle nested structure: {success: true, user: {success: true, user: {...}}}
          if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
            var userData = data['user'];
            // Check if user is nested again
            if (userData.containsKey('user') && userData['user'] is Map<String, dynamic>) {
              print("👤 Found nested user -> user structure");
              profileData = userData['user'];
            } else {
              print("👤 Found user structure");
              profileData = userData;
            }
          } else if (data.containsKey('data')) {
            var innerData = data['data'];
            if (innerData is List && innerData.isNotEmpty) {
              profileData = innerData[0];
            } else if (innerData is Map<String, dynamic>) {
              profileData = innerData;
            } else {
              profileData = data;
            }
          } else if (data.containsKey('hr')) {
            profileData = data['hr'];
          } else if (data.containsKey('users') && data['users'] is List && (data['users'] as List).isNotEmpty) {
            profileData = (data['users'] as List)[0];
          } else {
            profileData = data;
          }
        } else {
          print("⚠️ Unexpected data type: ${data.runtimeType}");
          profileData = {};
        }
        
        print("👤 Final Profile Data: $profileData");
        print("👤 Profile Data Keys: ${profileData.keys}");
        
        return {
          'success': true,
          'data': profileData,
        };
      } else {
        print("❌ Get HR Profile failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to fetch profile',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Get HR Profile error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }
}
