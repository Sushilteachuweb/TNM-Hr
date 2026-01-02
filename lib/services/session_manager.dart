import 'package:flutter/material.dart';
import 'user_storage.dart';
import 'cookie_manager.dart';

/// Handles session management and expiry across the app
class SessionManager {
  /// Check if API response indicates session expiry
  static bool isSessionExpired(Map<String, dynamic> apiResponse) {
    if (apiResponse['success'] == false) {
      final message = apiResponse['message']?.toString().toLowerCase() ?? '';
      return message.contains('session') || 
             message.contains('login') || 
             message.contains('unauthorized') ||
             message.contains('expired');
    }
    return false;
  }

  /// Handle session expiry - clear data and navigate to login
  static Future<void> handleSessionExpiry(BuildContext context) async {
    // Clear all stored data
    await UserStorage.clearUser();
    await CookieManager.clearCookie();

    if (context.mounted) {
      // Show session expired message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your session has expired. Please login again."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false,
      );
    }
  }

  /// Validate session before making API calls
  static Future<bool> isSessionValid() async {
    final cookie = await CookieManager.getCookie();
    final isLoggedIn = await UserStorage.isLoggedIn();
    
    return cookie != null && cookie.isNotEmpty && isLoggedIn;
  }

  /// Check API response and handle session expiry automatically
  static Future<bool> checkAndHandleResponse(
    BuildContext context, 
    Map<String, dynamic> apiResponse,
  ) async {
    if (isSessionExpired(apiResponse)) {
      await handleSessionExpiry(context);
      return false; // Session expired
    }
    return true; // Session valid
  }
}