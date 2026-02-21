// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_routes.dart';
import 'cookie_manager.dart';

class AuthApiService {
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Send OTP to phone number
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      print("📞 Calling Send OTP API: ${ApiConfig.sendOtp}");
      print("📞 Request Body: {phone: $phoneNumber}");

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.sendOtp),
            headers: headers,
            body: jsonEncode({'phone': phoneNumber}),
          )
          .timeout(const Duration(seconds: 15));

      print("📞 Raw Response: ${response.body}");
      print("📞 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("📞 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        print("✅ OTP sent successfully");
        return {
          'success': true,
          'otp': data['otp'],
          'message': data['message'] ?? 'OTP sent successfully',
        };
      } else {
        print("❌ Send OTP failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] is List
              ? data['message'].join(', ')
              : data['message']?.toString() ?? 'Failed to send OTP',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } on FormatException catch (e) {
      print("🔧 JSON Parse Error: $e");
      return {
        'success': false,
        'message': 'Invalid response from server.',
      };
    } catch (e) {
      print("❌ Send OTP error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    try {
      print("🔐 Calling Verify OTP API: ${ApiConfig.verifyOtp}");
      print("🔐 Request Body: {phone: $phone, otp: $otp}");

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.verifyOtp),
            headers: headers,
            body: jsonEncode({'phone': phone, 'otp': int.parse(otp)}),
          )
          .timeout(const Duration(seconds: 30));

      print("🔐 Raw Response: ${response.body}");
      print("🔐 Status Code: ${response.statusCode}");

      // Save session cookie
      final cookie = CookieManager.extractCookie(response.headers);
      if (cookie != null) {
        await CookieManager.saveCookie(cookie);
      }

      if (response.body.isEmpty) {
        print("❌ Empty response from server");
        return {
          'success': false,
          'message': 'Empty response from server. Please try again.',
        };
      }

      final data = jsonDecode(response.body);
      print("🔐 Decoded JSON: $data");

      if (response.statusCode == 200) {
        bool? isExistingUser = data['isExistingUser'];
        print("✅ OTP verified - isExistingUser: $isExistingUser");

        if (isExistingUser != null) {
          // Extract user data from nested 'data' object if present
          final userData = data['data'] ?? {};
          
          return {
            'success': true,
            'isExistingUser': isExistingUser,
            'hrId': userData['hrId']?.toString() ?? data['hrId']?.toString(),
            'userId': userData['id']?.toString() ?? userData['userId']?.toString() ?? data['userId']?.toString(),
            'userName': userData['fullName']?.toString() ?? userData['userName']?.toString() ?? data['userName']?.toString(),
            'userEmail': userData['email']?.toString() ?? userData['userEmail']?.toString() ?? data['userEmail']?.toString(),
            'company': userData['companyName']?.toString() ?? userData['company']?.toString() ?? data['company']?.toString(),
            'phone': userData['phone']?.toString() ?? data['phone']?.toString(),
            'message': data['message'] ?? 'OTP verified successfully',
          };
        } else {
          print("❌ isExistingUser is null in API response");
          return {
            'success': false,
            'message': data['message'] is List
                ? data['message'].join(', ')
                : data['message']?.toString() ?? 'Invalid response from server.',
          };
        }
      } else {
        print("❌ Verify OTP failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] is List
              ? data['message'].join(', ')
              : data['message']?.toString() ??
                  data['error']?.toString() ??
                  'Server error. Please try again later.',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } on FormatException catch (e) {
      print("🔧 JSON Parse Error: $e");
      return {
        'success': false,
        'message': 'Invalid response from server.',
      };
    } on http.ClientException catch (e) {
      print("🌐 Network Error: $e");
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    } catch (e) {
      print("❌ Verify OTP error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Resend OTP
  static Future<Map<String, dynamic>> resendOtp(String phoneNumber) async {
    try {
      print("🔄 Calling Resend OTP API: ${ApiConfig.resendOtp}");
      print("🔄 Request Body: {phone: $phoneNumber}");

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.resendOtp),
            headers: headers,
            body: jsonEncode({'phone': phoneNumber}),
          )
          .timeout(const Duration(seconds: 15));

      print("🔄 Raw Response: ${response.body}");
      print("🔄 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);
      print("🔄 Decoded JSON: $data");

      if (response.statusCode == 200 && data['success'] == true) {
        print("✅ OTP resent successfully");
        return {
          'success': true,
          'message': data['message'] ?? 'OTP resent successfully',
        };
      } else {
        print("❌ Resend OTP failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] is List
              ? data['message'].join(', ')
              : data['message']?.toString() ?? 'Failed to resend OTP',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Resend OTP error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Signup (New HR only)
  /// Creates session after signup
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String phone,
    required String companyName,
    required String email,
    required int totalEmp,
  }) async {
    try {
      print("📝 Calling Signup API: ${ApiConfig.signup}");

      final body = {
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'companyName': companyName,
        'totalEmp': totalEmp,
      };

      print("📝 Request Body: $body");

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.signup),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print("📝 Raw Response: ${response.body}");
      print("📝 Status Code: ${response.statusCode}");

      // Save session cookie
      final cookie = CookieManager.extractCookie(response.headers);
      if (cookie != null) {
        await CookieManager.saveCookie(cookie);
      }

      final data = jsonDecode(response.body);
      print("📝 Decoded JSON: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Signup successful");
        return {
          'success': true,
          'message': data['message'] ?? 'Signup successful',
          'hrId': data['data']?['hrId']?.toString(),
          'userId': data['data']?['id']?.toString(),
          'data': data,
        };
      } else {
        print("❌ Signup failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] is List
              ? data['message'].join(', ')
              : data['message']?.toString() ?? 'Signup failed',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Signup error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Signup with Document (New HR with verification document)
  /// Creates session after signup
  static Future<Map<String, dynamic>> signupWithDocument({
    required String fullName,
    required String phone,
    required String companyName,
    required String email,
    required int totalEmp,
    required File verificationDocument,
    File? profilePhoto,
  }) async {
    try {
      print("📝 Calling Signup API with Document: ${ApiConfig.signup}");

      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Let http package set multipart content type

      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.signup));
      
      // Add headers
      request.headers.addAll(headers);

      // Add form fields
      request.fields['fullName'] = fullName;
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['companyName'] = companyName;
      request.fields['totalEmp'] = totalEmp.toString();

      // Add verification document with explicit content type
      String fileName = verificationDocument.path.split('/').last;
      String? mimeType;
      
      // Determine MIME type based on file extension
      if (fileName.toLowerCase().endsWith('.pdf')) {
        mimeType = 'application/pdf';
      } else if (fileName.toLowerCase().endsWith('.jpg') || fileName.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'verificationDocument',
          verificationDocument.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        ),
      );

      // Add profile photo if provided
      if (profilePhoto != null) {
        String photoFileName = profilePhoto.path.split('/').last;
        String? photoMimeType;
        
        if (photoFileName.toLowerCase().endsWith('.jpg') || photoFileName.toLowerCase().endsWith('.jpeg')) {
          photoMimeType = 'image/jpeg';
        } else if (photoFileName.toLowerCase().endsWith('.png')) {
          photoMimeType = 'image/png';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePhoto',
            profilePhoto.path,
            contentType: photoMimeType != null ? MediaType.parse(photoMimeType) : null,
          ),
        );
        print("📸 Added profile photo: ${profilePhoto.path}");
      }

      print("📝 Request Fields: ${request.fields}");
      print("📝 Request File: ${verificationDocument.path}");
      print("📝 File Name: $fileName");
      print("📝 MIME Type: $mimeType");

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print("📝 Raw Response: ${response.body}");
      print("📝 Status Code: ${response.statusCode}");

      // Save session cookie
      final cookie = CookieManager.extractCookie(response.headers);
      if (cookie != null) {
        await CookieManager.saveCookie(cookie);
      }

      final data = jsonDecode(response.body);
      print("📝 Decoded JSON: $data");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Signup with document successful");
        return {
          'success': true,
          'message': data['message'] ?? 'Signup successful',
          'hrId': data['data']?['hrId']?.toString(),
          'userId': data['data']?['id']?.toString(),
          'data': data,
        };
      } else {
        print("❌ Signup with document failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] is List
              ? data['message'].join(', ')
              : data['message']?.toString() ?? 'Signup failed',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Signup with document error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }

  /// Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      print("🚪 Calling Logout API: ${ApiConfig.logout}");

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(ApiConfig.logout),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print("🚪 Raw Response: ${response.body}");
      print("🚪 Status Code: ${response.statusCode}");

      // Clear session cookie
      await CookieManager.clearCookie();

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Logout successful");
        return {
          'success': true,
          'message': data['message'] ?? 'Logout successful',
        };
      } else {
        print("❌ Logout failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Logout failed',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Logout error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }
}
