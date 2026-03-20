import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cookie_manager.dart';

/// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background FCM message: ${message.notification?.title}');
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications like job applications',
    importance: Importance.high,
  );

  /// Call once after Firebase.initializeApp()
  static Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup local notifications
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
    );

    // Request notification permission via permission_handler (Android 13+)
    final status = await Permission.notification.request();
    print('🔔 Notification permission: $status');

    if (status.isGranted) {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('🔔 FCM auth status: ${settings.authorizationStatus}');
    } else if (status.isPermanentlyDenied) {
      print('⚠️ Notification permission permanently denied — open app settings');
      await openAppSettings();
    } else {
      print('⚠️ Notification permission denied');
    }

    // Show local notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground FCM: ${message.notification?.title}');
      print('📩 Foreground FCM body: ${message.notification?.body}');
      _showLocalNotification(message);
    });

    // Notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification tapped: ${message.notification?.title}');
    });
  }

  /// Display a local notification banner (foreground only)
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Get and cache the FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        print('✅ FCM Token: $token');
      }
      return token;
    } catch (e) {
      print('❌ FCM token error: $e');
      return null;
    }
  }

  /// Retrieve cached token
  static Future<String?> getCachedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Listen for token refresh and update cache + backend
  static void listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', newToken);
      print('🔄 FCM Token refreshed: $newToken');
      await updateToken();
    });
  }

  /// Save FCM token to backend (called after login)
  static Future<void> updateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token') ?? '';

      if (token.isEmpty) {
        print('⚠️ FCM token not available, skipping update-token');
        return;
      }

      final headers = await CookieManager.getHeadersWithCookie();

      // Log whether cookie is present
      final hasCookie = headers.containsKey('Cookie') && headers['Cookie']!.isNotEmpty;
      print('📡 Calling update-token | cookie present: $hasCookie | token: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('https://api.thenaukrimitra.com/api/notifications/update-token'),
        headers: headers,
        body: jsonEncode({'token': token}),
      );

      print('📡 Update token response [${response.statusCode}]: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('⚠️ update-token did not return success — backend may not have saved the token');
      }
    } catch (e) {
      print('❌ Update token error: $e');
    }
  }

  /// Send test push notification via backend API
  static Future<void> sendTestNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token') ?? '';

      if (token.isEmpty) {
        print('⚠️ FCM token not available, skipping test notification');
        return;
      }

      final response = await http.post(
        Uri.parse('https://api.thenaukrimitra.com/api/notifications/test-push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      print('🔔 Notification API response [${response.statusCode}]: ${response.body}');
    } catch (e) {
      print('❌ Notification API error: $e');
    }
  }
}
