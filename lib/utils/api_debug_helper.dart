import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiDebugHelper {
  /// Test different API endpoints to find the correct one
  static Future<void> testPlanEndpoints() async {
    final List<String> endpointsToTest = [
      'https://api.thenaukrimitra.com/api/job-plan/fetchplans',
      'https://api.thenaukrimitra.com/api/job-plans/fetchplans',
      'https://api.thenaukrimitra.com/api/plans/fetch',
      'https://api.thenaukrimitra.com/api/job-plan/fetch-plans',
      'https://api.thenaukrimitra.com/api/job-plan/list',
      'https://api.thenaukrimitra.com/api/job-plan/all',
      'https://api.thenaukrimitra.com/api/job-plan',
      'https://api.thenaukrimitra.com/api/plans',
    ];

    print('🔍 Testing API endpoints for job plans...\n');

    for (int i = 0; i < endpointsToTest.length; i++) {
      final endpoint = endpointsToTest[i];
      
      try {
        print('${i + 1}. Testing: $endpoint');
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        print('   Status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          try {
            final data = json.decode(response.body);
            print('   ✅ SUCCESS! Response: ${data.toString().substring(0, 100)}...');
            print('   📋 This endpoint works!\n');
          } catch (e) {
            print('   ⚠️ Response not JSON: ${response.body.substring(0, 50)}...\n');
          }
        } else if (response.statusCode == 404) {
          print('   ❌ Not Found (404)\n');
        } else {
          print('   ⚠️ Error ${response.statusCode}: ${response.body.substring(0, 50)}...\n');
        }
      } catch (e) {
        print('   💥 Exception: $e\n');
      }
    }
  }

  /// Test base API connectivity
  static Future<void> testBaseApi() async {
    final baseUrls = [
      'https://api.thenaukrimitra.com',
      'https://api.thenaukrimitra.com/api',
      'https://api.thenaukrimitra.com/health',
      'https://api.thenaukrimitra.com/status',
    ];

    print('🌐 Testing base API connectivity...\n');

    for (final url in baseUrls) {
      try {
        print('Testing: $url');
        final response = await http.get(Uri.parse(url));
        print('Status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('✅ Base API is reachable\n');
        } else {
          print('Response: ${response.body.substring(0, 100)}...\n');
        }
      } catch (e) {
        print('❌ Error: $e\n');
      }
    }
  }
}