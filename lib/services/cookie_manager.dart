import 'package:shared_preferences/shared_preferences.dart';

/// Manages session cookies for API requests
class CookieManager {
  static const String _cookieKey = 'session_cookie';

  /// Save session cookie from response
  static Future<void> saveCookie(String? cookie) async {
    if (cookie != null && cookie.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cookieKey, cookie);
      print("🍪 Cookie saved: $cookie");
    }
  }

  /// Get saved session cookie
  static Future<String?> getCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final cookie = prefs.getString(_cookieKey);
    print("🍪 Cookie retrieved: $cookie");
    return cookie;
  }

  /// Clear session cookie
  static Future<void> clearCookie() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
    print("🍪 Cookie cleared");
  }

  /// Extract cookie from response headers
  static String? extractCookie(Map<String, String> headers) {
    final setCookie = headers['set-cookie'];
    if (setCookie != null) {
      // Extract just the session ID part
      final cookie = setCookie.split(';')[0];
      print("🍪 Cookie extracted from response: $cookie");
      return cookie;
    }
    return null;
  }

  /// Get headers with cookie
  static Future<Map<String, String>> getHeadersWithCookie() async {
    final cookie = await getCookie();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (cookie != null && cookie.isNotEmpty) {
      headers['Cookie'] = cookie;
    }
    
    return headers;
  }
}
