import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/hr_profile_api_service.dart';
import '../services/user_storage.dart';

class HrProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _profileData = {};

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get profileData => _profileData;

  // Getters for specific profile fields
  String get hrId => _profileData['_id'] ?? '';
  String get hrPhone => _profileData['hrPhone'] ?? '';
  String get fullName => _profileData['fullName'] ?? '';
  String get companyName => _profileData['companyName'] ?? '';
  String get email => _profileData['email'] ?? '';
  String get officeAddress => _profileData['officeAddress'] ?? '';
  String get floorDetails => _profileData['floorDetails'] ?? '';
  List<double> get coordinates {
    if (_profileData['coordinates'] != null && _profileData['coordinates'] is List) {
      return List<double>.from(_profileData['coordinates'].map((e) => e.toDouble()));
    }
    return [0.0, 0.0];
  }

  /// Load profile from SharedPreferences (both hr_profile and UserStorage)
  Future<void> loadProfileFromLocal() async {
    try {
      // First try to load from hr_profile key
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('hr_profile');
      
      if (profileJson != null) {
        _profileData = jsonDecode(profileJson);
        print('✅ HR Profile loaded from hr_profile key');
      } else {
        // Fallback to UserStorage keys
        final phone = prefs.getString('phone') ?? '';
        final company = prefs.getString('company') ?? '';
        final hrId = prefs.getString('hrId') ?? '';
        final userName = prefs.getString('userName') ?? '';
        final userEmail = prefs.getString('userEmail') ?? '';
        
        _profileData = {
          '_id': hrId,
          'hrPhone': phone,
          'fullName': userName,
          'companyName': company,
          'email': userEmail,
          'officeAddress': '', // Will be filled when user updates profile
          'floorDetails': '',
          'coordinates': [0.0, 0.0],
        };
        
        print('✅ HR Profile loaded from UserStorage keys');
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error loading profile from local: $e');
    }
  }

  /// Save profile to SharedPreferences
  Future<void> saveProfileToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('hr_profile', jsonEncode(_profileData));
      print('✅ HR Profile saved to local storage');
    } catch (e) {
      print('❌ Error saving profile to local: $e');
    }
  }

  /// Fetch HR profile from API
  Future<void> fetchProfile(String hrId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await HrProfileApiService.getHrProfile(hrId);

      if (result['success'] == true && result['data'] != null) {
        _profileData = result['data'];
        await saveProfileToLocal();
        
        // Handle skills array
        String? skillsStr;
        if (_profileData['skills'] != null) {
          if (_profileData['skills'] is List) {
            final skillsList = _profileData['skills'] as List;
            skillsStr = skillsList.isNotEmpty ? skillsList.join(', ') : null;
          } else {
            skillsStr = _profileData['skills'].toString();
          }
        }
        
        // Also update UserStorage with the fetched data
        await UserStorage.updateUserProfile(
          userName: _profileData['fullName']?.toString() ?? _profileData['name']?.toString() ?? _profileData['userName']?.toString(),
          userEmail: _profileData['email']?.toString() ?? _profileData['hrEmail']?.toString() ?? _profileData['userEmail']?.toString(),
          company: _profileData['companyName']?.toString() ?? _profileData['company']?.toString(),
          designation: _profileData['designation']?.toString(),
          experience: _profileData['experience']?.toString(),
          location: _profileData['location']?.toString() ?? _profileData['officeAddress']?.toString() ?? _profileData['city']?.toString() ?? _profileData['hrLocation']?.toString(),
          skills: skillsStr,
          bio: _profileData['bio']?.toString(),
          totalEmp: _profileData['totalEmp']?.toString(),
          profileImage: _profileData['profilePhoto']?.toString() ?? _profileData['profileImage']?.toString(),
        );
        
        print('✅ HR Profile and UserStorage updated from API');
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch profile';
      print('❌ Error fetching profile: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update HR profile
  Future<bool> updateProfile({
    String? fullName,
    String? companyName,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await HrProfileApiService.updateHrProfile(
        fullName: fullName,
        companyName: companyName,
        email: email,
      );

      if (result['success'] == true) {
        // Update local data
        if (fullName != null) _profileData['fullName'] = fullName;
        if (companyName != null) _profileData['companyName'] = companyName;
        if (email != null) _profileData['email'] = email;
        
        await saveProfileToLocal();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  /// Set profile data manually (e.g., after login/signup)
  void setProfileData(Map<String, dynamic> data) {
    _profileData = data;
    saveProfileToLocal();
    notifyListeners();
  }

  /// Clear profile data (e.g., on logout)
  Future<void> clearProfile() async {
    _profileData = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hr_profile');
    notifyListeners();
  }
}
