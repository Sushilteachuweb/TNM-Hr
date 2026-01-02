import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user data in local storage
class UserStorage {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _phoneKey = 'phone';
  static const String _isExistingUserKey = 'isExistingUser';
  static const String _hrIdKey = 'hrId';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _companyKey = 'company';
  static const String _designationKey = 'designation';
  static const String _experienceKey = 'experience';
  static const String _locationKey = 'location';
  static const String _skillsKey = 'skills';
  static const String _bioKey = 'bio';
  static const String _profileImageKey = 'profileImage';
  static const String _profileCompletionSnackbarShownKey = 'profileCompletionSnackbarShown';

  /// Save login data after successful authentication
  static Future<void> saveLoginData({
    required String phone,
    required bool isExistingUser,
    String? hrId,
    String? userId,
    String? userName,
    String? userEmail,
    String? company,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_phoneKey, phone);
    await prefs.setBool(_isExistingUserKey, isExistingUser);

    if (hrId != null) await prefs.setString(_hrIdKey, hrId);
    if (userId != null) await prefs.setString(_userIdKey, userId);
    if (userName != null) await prefs.setString(_userNameKey, userName);
    if (userEmail != null) await prefs.setString(_userEmailKey, userEmail);
    if (company != null) await prefs.setString(_companyKey, company);
  }

  /// Get all stored login data
  static Future<Map<String, dynamic>> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'isLoggedIn': prefs.getBool(_isLoggedInKey) ?? false,
      'phone': prefs.getString(_phoneKey) ?? '',
      'isExistingUser': prefs.getBool(_isExistingUserKey) ?? false,
      'hrId': prefs.getString(_hrIdKey),
      'userId': prefs.getString(_userIdKey),
      'userName': prefs.getString(_userNameKey),
      'userEmail': prefs.getString(_userEmailKey),
      'company': prefs.getString(_companyKey),
      'designation': prefs.getString(_designationKey),
      'experience': prefs.getString(_experienceKey),
      'location': prefs.getString(_locationKey),
      'skills': prefs.getString(_skillsKey),
      'bio': prefs.getString(_bioKey),
      'profileImage': prefs.getString(_profileImageKey),
    };
  }

  /// Get stored HR ID
  static Future<String?> getHrId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_hrIdKey);
  }

  /// Get stored User ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get stored phone number
  static Future<String> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey) ?? '';
  }

  /// Check if user is existing user
  static Future<bool> isExistingUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isExistingUserKey) ?? false;
  }

  /// Clear all user data (logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Update user profile information
  static Future<void> updateUserProfile({
    String? userName,
    String? userEmail,
    String? company,
    String? designation,
    String? experience,
    String? location,
    String? skills,
    String? bio,
    String? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (userName != null) await prefs.setString(_userNameKey, userName);
    if (userEmail != null) await prefs.setString(_userEmailKey, userEmail);
    if (company != null) await prefs.setString(_companyKey, company);
    if (designation != null) {
      await prefs.setString(_designationKey, designation);
    }
    if (experience != null) await prefs.setString(_experienceKey, experience);
    if (location != null) await prefs.setString(_locationKey, location);
    if (skills != null) await prefs.setString(_skillsKey, skills);
    if (bio != null) await prefs.setString(_bioKey, bio);
    if (profileImage != null) {
      await prefs.setString(_profileImageKey, profileImage);
    }
  }

  /// Check if profile completion snackbar has been shown
  static Future<bool> hasProfileCompletionSnackbarBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileCompletionSnackbarShownKey) ?? false;
  }

  /// Mark profile completion snackbar as shown
  static Future<void> markProfileCompletionSnackbarAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompletionSnackbarShownKey, true);
  }
}
