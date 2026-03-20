// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'cookie_manager.dart';
import 'payment_verification_service.dart';
import 'user_storage.dart';

class PlanApiService {
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Fetch all available job plans
  static Future<Map<String, dynamic>> fetchPlans() async {
    try {
      print("═══════════════════════════════════════");
      print("📋 FETCH PLANS API CALL STARTED");
      print("═══════════════════════════════════════");
      print("🔗 API Endpoint: ${ApiConfig.fetchPlans}");
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse(ApiConfig.fetchPlans),
        headers: headers,
      );

      print("📊 Response Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print("✅ Plans fetched successfully");
          print("📦 Total plans: ${responseData['data']?.length ?? 0}");
          return responseData;
        } else {
          print("❌ API returned success: false");
          return {
            'success': false,
            'message': 'Unable to load plans. Please try again.',
            'data': []
          };
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        return {
          'success': false,
          'message': 'Unable to load plans. Please try again.',
          'data': []
        };
      }
    } catch (e) {
      print("💥 Exception in fetchPlans: $e");
      return {
        'success': false,
        'message': 'Unable to load plans. Please check your connection and try again.',
        'data': []
      };
    }
  }

  /// Buy a plan using the new payment API
  static Future<Map<String, dynamic>> buyPlan({
    required String planId,
    required String userId,
    required int amount,
  }) async {
    try {
      print("═══════════════════════════════════════");
      print("💳 BUY PLAN API CALL STARTED");
      print("═══════════════════════════════════════");
      print("🔗 API Endpoint: ${ApiConfig.buyPlan}");
      print("📋 Plan ID: $planId");
      print("👤 User ID: $userId");
      print("💰 Amount: $amount");
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      print("📋 REQUEST HEADERS: $headers");
      
      final body = {
        'planId': planId,
        'userId': userId,
        'amount': amount,
      };

      print("📦 Request Body: ${json.encode(body)}");
      print("📦 Request Body Type: ${body.runtimeType}");

      final response = await http.post(
        Uri.parse(ApiConfig.buyPlan),
        headers: headers,
        body: json.encode(body),
      );

      print("📊 Response Status Code: ${response.statusCode}");
      print("📋 Response Headers: ${response.headers}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print("✅ Plan purchase order created successfully");
          print("🆔 Order ID: ${responseData['order']?['id']}");
          return responseData;
        } else {
          print("❌ API returned success: false");
          return {
            'success': false,
            'message': responseData['message'] ?? 'Unable to process your order. Please try again.',
            'order': null
          };
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        print("❌ Response Body: ${response.body}");
        return {
          'success': false,
          'message': 'Unable to process your order. Please try again.',
          'order': null
        };
      }
    } catch (e) {
      print("💥 Exception in buyPlan: $e");
      return {
        'success': false,
        'message': 'Unable to process your order. Please check your connection and try again.',
        'order': null
      };
    }
  }

  /// Verify payment after successful Razorpay payment
  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String planId,
    required String userId,
    required int amount,
  }) async {
    return await PaymentVerificationService.verifyPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      planId: planId,
      userId: userId,
      amount: amount,
    );
  }

  /// Fetch active plan details
  static Future<Map<String, dynamic>> fetchActivePlan() async {
    try {
      print("═══════════════════════════════════════");
      print("📋 FETCH ACTIVE PLAN API CALL STARTED");
      print("═══════════════════════════════════════");

      // Get HR ID from storage
      final hrId = await UserStorage.getHrId();
      if (hrId == null || hrId.isEmpty || hrId == 'null') {
        print("❌ No valid HR ID found in storage");
        return {
          'success': false,
          'message': 'No HR ID found. Please login again.',
          'data': null
        };
      }

      final endpoint = ApiConfig.activePlan(hrId);
      print("🔗 API Endpoint: $endpoint");
      print("👤 HR ID: $hrId");
      print("═══════════════════════════════════════");

      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      print("📊 Response Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print("✅ Active plan fetched successfully");
          return responseData;
        } else {
          print("❌ API returned success: false");
          return {
            'success': false,
            'message': 'Unable to load your plan. Please try again.',
            'data': null
          };
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        return {
          'success': false,
          'message': 'Unable to load your plan. Please try again.',
          'data': null
        };
      }
    } catch (e) {
      print("💥 Exception in fetchActivePlan: $e");
      return {
        'success': false,
        'message': 'Unable to load your plan. Please check your connection and try again.',
        'data': null
      };
    }
  }
}