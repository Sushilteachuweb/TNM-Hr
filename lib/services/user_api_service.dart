// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'cookie_manager.dart';

class UserApiService {
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Fetch All Users with optional filters
  /// Query params: skills, city, experience, keyword
  static Future<Map<String, dynamic>> getUsers({
    String? skills,
    String? city,
    String? experience,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (skills != null && skills.isNotEmpty) queryParams['skills'] = skills;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (experience != null && experience.isNotEmpty) {
        queryParams['experience'] = experience;
      }
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      final uri = Uri.parse(ApiConfig.getUsers).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print("👥 Calling Get Users API: $uri");

      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      print("👥 Raw Response: ${response.body}");
      print("👥 Status Code: ${response.statusCode}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Users fetched successfully");
        return {
          'success': true,
          'data': data,
        };
      } else {
        print("❌ Get Users failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Failed to fetch users',
        };
      }
    } on TimeoutException catch (e) {
      print("⏱️ Timeout Error: $e");
      return {
        'success': false,
        'message': 'Server is not responding. Try again later.',
      };
    } catch (e) {
      print("❌ Get Users error: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Try again later.',
      };
    }
  }
}
