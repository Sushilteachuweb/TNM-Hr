// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'cookie_manager.dart';

class PaymentHistoryApiService {
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Fetch payment history for a user by mobile number
  static Future<Map<String, dynamic>> fetchPaymentHistory(String mobileNumber) async {
    try {
      print("═══════════════════════════════════════");
      print("📋 FETCH PAYMENT HISTORY API CALL STARTED");
      print("═══════════════════════════════════════");
      print("🔗 API Endpoint: ${ApiConfig.paymentHistory(mobileNumber)}");
      print("📱 Mobile Number: $mobileNumber");
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse(ApiConfig.paymentHistory(mobileNumber)),
        headers: headers,
      );

      print("📊 Response Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print("✅ Payment history fetched successfully");
          print("📦 Total payments: ${responseData['total'] ?? 0}");
          return responseData;
        } else {
          print("❌ API returned success: false");
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch payment history',
            'payments': [],
            'total': 0
          };
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
          'payments': [],
          'total': 0
        };
      }
    } catch (e) {
      print("💥 Exception in fetchPaymentHistory: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
        'payments': [],
        'total': 0
      };
    }
  }

  /// Fetch payment details by order ID
  static Future<Map<String, dynamic>> fetchPaymentDetails(String orderId) async {
    try {
      print("═══════════════════════════════════════");
      print("📋 FETCH PAYMENT DETAILS API CALL STARTED");
      print("═══════════════════════════════════════");
      print("🔗 API Endpoint: ${ApiConfig.paymentDetails(orderId)}");
      print("🆔 Order ID: $orderId");
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse(ApiConfig.paymentDetails(orderId)),
        headers: headers,
      );

      print("📊 Response Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print("✅ Payment details fetched successfully");
          return responseData;
        } else {
          print("❌ API returned success: false");
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to fetch payment details',
            'payment': null
          };
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
          'payment': null
        };
      }
    } catch (e) {
      print("💥 Exception in fetchPaymentDetails: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
        'payment': null
      };
    }
  }
}