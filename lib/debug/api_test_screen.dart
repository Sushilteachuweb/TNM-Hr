import 'package:flutter/material.dart';
import '../utils/api_debug_helper.dart';
import '../services/plan_api_service.dart';
import '../services/job_api_service.dart';
import '../services/user_api_service.dart';
import '../services/cookie_manager.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _testResults = 'Tap buttons to test API endpoints';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'API Endpoint Testing',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testPlanEndpoints,
              child: const Text('Test Plan Endpoints'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testBaseApi,
              child: const Text('Test Base API'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testCurrentPlanService,
              child: const Text('Test Current Plan Service'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testJobService,
              child: const Text('Test Job Service'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testUserService,
              child: const Text('Test User Service'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuthentication,
              child: const Text('Test Authentication'),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _testResults,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testPlanEndpoints() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing plan endpoints...\n';
    });

    try {
      await ApiDebugHelper.testPlanEndpoints();
      // Capture print output would require more complex setup
      setState(() {
        _testResults += 'Plan endpoint testing completed. Check console for details.\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error testing plan endpoints: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testBaseApi() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing base API...\n';
    });

    try {
      await ApiDebugHelper.testBaseApi();
      setState(() {
        _testResults += 'Base API testing completed. Check console for details.\n';
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error testing base API: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testCurrentPlanService() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing current plan service...\n';
    });

    try {
      final result = await PlanApiService.fetchPlans();
      setState(() {
        _testResults += 'Plan Service Result:\n';
        _testResults += 'Success: ${result['success']}\n';
        _testResults += 'Message: ${result['message']}\n';
        _testResults += 'Data count: ${result['data']?.length ?? 0}\n';
        if (result['data'] != null && result['data'].isNotEmpty) {
          _testResults += 'First plan: ${result['data'][0]['planName']}\n';
        }
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error in plan service: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testJobService() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing job service...\n';
    });

    try {
      final result = await JobApiService.getHrJobs();
      setState(() {
        _testResults += 'Job Service Result:\n';
        _testResults += 'Success: ${result['success']}\n';
        _testResults += 'Message: ${result['message']}\n';
        if (result['data'] != null) {
          _testResults += 'Data type: ${result['data'].runtimeType}\n';
          if (result['data'] is List) {
            _testResults += 'Jobs count: ${result['data'].length}\n';
            // Check work location values in existing jobs
            if (result['data'].isNotEmpty) {
              for (int i = 0; i < result['data'].length && i < 3; i++) {
                final job = result['data'][i];
                _testResults += 'Job ${i + 1} workLocation: ${job['workLocation']}\n';
              }
            }
          } else if (result['data'] is Map) {
            _testResults += 'Data keys: ${result['data'].keys.toList()}\n';
          }
        }
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error in job service: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testUserService() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing user service...\n';
    });

    try {
      final result = await UserApiService.getUsers();
      setState(() {
        _testResults += 'User Service Result:\n';
        _testResults += 'Success: ${result['success']}\n';
        _testResults += 'Message: ${result['message']}\n';
        if (result['data'] != null) {
          _testResults += 'Data type: ${result['data'].runtimeType}\n';
          if (result['data'] is Map && result['data']['users'] != null) {
            _testResults += 'Users count: ${result['data']['users'].length}\n';
          }
        }
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error in user service: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing authentication...\n';
    });

    try {
      final cookie = await CookieManager.getCookie();
      setState(() {
        _testResults += 'Authentication Status:\n';
        _testResults += 'Cookie exists: ${cookie != null && cookie.isNotEmpty}\n';
        _testResults += 'Cookie value: ${cookie ?? "No cookie"}\n';
        if (cookie != null && cookie.isNotEmpty) {
          _testResults += 'Cookie length: ${cookie.length}\n';
          _testResults += 'Cookie starts with: ${cookie.substring(0, cookie.length > 20 ? 20 : cookie.length)}...\n';
        }
      });
    } catch (e) {
      setState(() {
        _testResults += 'Error checking authentication: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}