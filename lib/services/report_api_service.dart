import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cookie_manager.dart';

class ReportApiService {
  static const String baseUrl = 'https://api.thenaukrimitra.com';
  
  /// Submit a user report/issue
  static Future<Map<String, dynamic>> submitReport({
    required String message,
  }) async {
    try {
      // Get cookie for authentication
      final cookie = await CookieManager.getCookie();
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/reports/submit'),
        headers: headers,
        body: jsonEncode({
          'message': message,
        }),
      );
      
      print('📤 Report API Response Status: ${response.statusCode}');
      print('📤 Report API Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Report submitted successfully',
            'data': data['data'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to submit report',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to submit report. Please try again.',
        };
      }
    } catch (e) {
      print('❌ Report submission error: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }
  
  /// Get user's previous reports (for future implementation)
  static Future<List<Map<String, dynamic>>> getUserReports() async {
    try {
      // Get cookie for authentication
      final cookie = await CookieManager.getCookie();
      
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/reports/user'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('❌ Error fetching user reports: $e');
      return [];
    }
  }
}