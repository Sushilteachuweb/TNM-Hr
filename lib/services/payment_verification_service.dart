// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'api_routes.dart';
import 'cookie_manager.dart';

class PaymentVerificationService {
  static const String _logTag = 'PaymentVerification';
  
  static Future<Map<String, String>> _getHeaders() async {
    return await CookieManager.getHeadersWithCookie();
  }

  /// Log detailed information for backend developer debugging
  static void _logForBackend(String message, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = {
      'timestamp': timestamp,
      'tag': _logTag,
      'message': message,
      'data': data,
    };
    
    // Use developer.log for production logging (won't show in release builds by default)
    developer.log(
      json.encode(logData),
      name: _logTag,
      time: DateTime.now(),
    );
    
    // Also print for debug builds
    print("[$_logTag] $timestamp: $message");
    if (data != null) {
      print("[$_logTag] Data: ${json.encode(data)}");
    }
  }

  /// Verify payment with backend after successful Razorpay payment
  static Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String planId,
    required String userId,
    required int amount,
  }) async {
    final startTime = DateTime.now();
    
    try {
      _logForBackend("Payment verification started", data: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signatureLength': signature.length,
        'signaturePrefix': signature.length > 10 ? signature.substring(0, 10) : signature,
        'planId': planId,
        'userId': userId,
        'amount': amount,
        'endpoint': ApiConfig.verifyPayment,
      });

      final headers = await _getHeaders();
      
      _logForBackend("Request headers prepared", data: {
        'headers': headers.keys.toList(),
        'hasCookie': headers.containsKey('Cookie'),
      });
      
      final body = {
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
        'planId': planId,
        'userId': userId,
        'amount': amount,
      };

      _logForBackend("Sending verification request", data: {
        'requestBody': {
          'orderId': orderId,
          'paymentId': paymentId,
          'signatureProvided': signature.isNotEmpty,
          'planId': planId,
          'userId': userId,
          'amount': amount,
        },
        'fullEndpoint': ApiConfig.verifyPayment,
        'method': 'POST',
      });

      final response = await http.post(
        Uri.parse(ApiConfig.verifyPayment),
        headers: headers,
        body: json.encode(body),
      );

      final duration = DateTime.now().difference(startTime).inMilliseconds;

      _logForBackend("Verification response received", data: {
        'statusCode': response.statusCode,
        'responseTime': '${duration}ms',
        'responseHeaders': response.headers,
        'responseBodyLength': response.body.length,
        'responseBody': response.body,
        'requestUrl': ApiConfig.verifyPayment,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          _logForBackend("Payment verification successful", data: {
            'verificationResult': responseData,
            'totalProcessingTime': '${duration}ms',
          });
          
          return {
            'success': true,
            'message': responseData['message'] ?? 'Payment verified successfully',
            'data': responseData['data'],
          };
        } else {
          _logForBackend("Payment verification failed - API returned success: false", data: {
            'apiResponse': responseData,
            'failureReason': responseData['message'] ?? 'Unknown failure reason',
          });
          
          return {
            'success': false,
            'message': 'Payment verification failed',
            'data': null,
          };
        }
      } else {
        _logForBackend("HTTP Error during verification", data: {
          'statusCode': response.statusCode,
          'responseBody': response.body,
          'responseHeaders': response.headers,
          'requestUrl': ApiConfig.verifyPayment,
          'possibleIssue': response.statusCode == 404 ? 'Endpoint not found - check backend routing' : 'Server error',
        });
        
        return {
          'success': false,
          'message': 'Verification service unavailable',
          'data': null,
        };
      }
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      
      _logForBackend("Exception during payment verification", data: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'processingTime': '${duration}ms',
        'requestData': {
          'orderId': orderId,
          'paymentId': paymentId,
          'planId': planId,
          'userId': userId,
          'amount': amount,
        },
        'endpoint': ApiConfig.verifyPayment,
      });
      
      return {
        'success': false,
        'message': 'Payment verification temporarily unavailable',
        'data': null,
      };
    }
  }

  /// Validate Razorpay signature locally (optional client-side validation)
  static bool validateSignature({
    required String orderId,
    required String paymentId,
    required String signature,
    required String razorpaySecret,
  }) {
    try {
      _logForBackend("Client-side signature validation", data: {
        'orderId': orderId,
        'paymentId': paymentId,
        'signatureProvided': signature.isNotEmpty,
        'secretProvided': razorpaySecret.isNotEmpty,
      });
      
      // This is optional client-side validation
      // The real validation should always happen on the backend
      // You can implement HMAC-SHA256 validation here if needed
      
      final isValid = orderId.isNotEmpty && 
                     paymentId.isNotEmpty && 
                     signature.isNotEmpty;
      
      _logForBackend("Client-side validation result", data: {
        'isValid': isValid,
        'orderIdValid': orderId.isNotEmpty,
        'paymentIdValid': paymentId.isNotEmpty,
        'signatureValid': signature.isNotEmpty,
      });
      
      return isValid;
    } catch (e, stackTrace) {
      _logForBackend("Error in client-side signature validation", data: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      return false;
    }
  }
}