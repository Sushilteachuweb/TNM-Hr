import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cookie_manager.dart';

class ReferEarnApiService {
  static const String baseUrl = 'https://api.thenaukrimitra.com';
  
  /// Generate a new referral code for the current user
  static Future<String> generateReferralCode() async {
    try {
      final headers = await CookieManager.getHeadersWithCookie();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/hr/referral/generate'),
        headers: headers,
      );
      
      print('Generate referral code response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Handle different response structures
        if (data['referralCode'] != null) {
          return data['referralCode'];
        } else if (data['data'] != null && data['data']['referralCode'] != null) {
          return data['data']['referralCode'];
        } else if (data['code'] != null) {
          return data['code'];
        }
        
        throw Exception('Referral code not found in response');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to generate referral code');
      }
    } catch (e) {
      print('Error generating referral code: $e');
      rethrow;
    }
  }
  
  /// Redeem a referral code
  static Future<Map<String, dynamic>> redeemReferralCode(String referralCode) async {
    try {
      final headers = await CookieManager.getHeadersWithCookie();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/hr/referral/redeem'),
        headers: headers,
        body: jsonEncode({
          'referralCode': referralCode,
        }),
      );
      
      print('Redeem referral code response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Referral code redeemed successfully!',
          'credits': data['credits'] ?? data['data']?['credits'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to redeem referral code',
        };
      }
    } catch (e) {
      print('Error redeeming referral code: $e');
      return {
        'success': false,
        'message': 'Failed to redeem code. Please try again.',
      };
    }
  }
  
  /// Get user's referral statistics
  static Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final headers = await CookieManager.getHeadersWithCookie();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/hr/referral/stats'),
        headers: headers,
      );
      
      print('Get referral stats response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extract data from the response structure
        if (data['success'] == true && data['data'] != null) {
          final statsData = data['data'];
          
          // Get referral credits info
          final referralCredits = statsData['referralCredits'] as Map<String, dynamic>? ?? {};
          final creditsEarned = referralCredits['earned'] as int? ?? 0;
          final isRedeemed = referralCredits['isRedeemed'] as bool? ?? false;
          final usableForJobPosting = referralCredits['usableForJobPosting'] as bool? ?? false;
          
          // Get referral history
          final referralHistory = statsData['referralHistory'] as List<dynamic>? ?? [];
          
          return {
            'referralCode': statsData['referralCode'],
            'hasGeneratedCode': statsData['hasGeneratedCode'] ?? false,
            'totalReferrals': statsData['totalReferrals'] ?? 0,
            'successfulReferrals': statsData['successfulReferrals'] ?? 0,
            'availableCredits': creditsEarned,
            'totalCredits': creditsEarned,
            'isRedeemed': isRedeemed,
            'usableForJobPosting': usableForJobPosting,
            'subscriptionStatus': isRedeemed ? 'Active' : 'Inactive',
            'expiryDate': null,
            'referralHistory': referralHistory,
          };
        }
        
        // Fallback if structure is different
        return data['data'] ?? data;
      } else {
        throw Exception('Failed to fetch referral stats');
      }
    } catch (e) {
      print('Error fetching referral stats: $e');
      // Return default values on error
      return {
        'referralCode': null,
        'hasGeneratedCode': false,
        'totalReferrals': 0,
        'successfulReferrals': 0,
        'availableCredits': 0,
        'totalCredits': 0,
        'isRedeemed': false,
        'usableForJobPosting': false,
        'subscriptionStatus': 'Inactive',
        'expiryDate': null,
        'referralHistory': [],
      };
    }
  }
}