import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/auth_api_service.dart';
import '../services/user_storage.dart';
import '../services/hr_profile_api_service.dart';
import '../services/fcm_service.dart';

class OtpProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool? _isExistingUser;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool? get isExistingUser => _isExistingUser;

  Future<void> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _errorMessage = '';
    _isExistingUser = null;
    notifyListeners();

    // Validate OTP format
    if (otp.length != 4 || !RegExp(r'^\d+$').hasMatch(otp)) {
      _isLoading = false;
      _errorMessage = 'Please enter a valid 4-digit OTP';
      notifyListeners();
      return;
    }

    // Internet check
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isLoading = false;
      _errorMessage = 'Please connect your Internet';
      notifyListeners();
      return;
    }

    // Call API service
    final result = await AuthApiService.verifyOtp(phone, otp);
    
    print('🔐 Verify OTP Result: $result');
    print('🔐 Result Keys: ${result.keys}');
    print('🔐 isExistingUser: ${result['isExistingUser']}');
    print('🔐 hrId: ${result['hrId']}');

    if (result['success'] == true) {
      _errorMessage = '';
      _isExistingUser = result['isExistingUser'];

      // Save login data to storage
      await UserStorage.saveLoginData(
        phone: phone,
        isExistingUser: result['isExistingUser'],
        hrId: result['hrId'],
        userId: result['userId'],
        userName: result['userName'],
        userEmail: result['userEmail'],
        company: result['company'],
      );
      
      print('💾 Login data saved to storage');

      // Fetch FCM token after successful login and send to backend
      final fcmToken = await FcmService.getToken();
      if (fcmToken != null) {
        print('📲 FCM Token ready, sending to backend...');
        await FcmService.updateToken();
        await FcmService.sendTestNotification();
      }

      // Fetch complete HR profile for existing users
      if (result['isExistingUser'] == true) {
        final hrId = result['hrId']?.toString();
        print('🔍 isExistingUser: ${result['isExistingUser']}');
        print('🔍 hrId from verify OTP: $hrId');
        
        if (hrId != null && hrId.isNotEmpty && hrId != 'null') {
          print('🔄 Fetching HR profile for existing user with hrId: $hrId');
          
          try {
            final profileResult = await HrProfileApiService.getHrProfile(hrId);
            
            print('📦 Profile API Result: $profileResult');
            print('📦 Profile API Success: ${profileResult['success']}');
            print('📦 Profile API Data: ${profileResult['data']}');
            
            if (profileResult['success'] == true && profileResult['data'] != null) {
              print('✅ HR profile fetched successfully');
              final profileData = profileResult['data'];
              
              print('📋 Profile Data Keys: ${profileData.keys}');
              print('📋 Full Profile Data: $profileData');
              
              // Extract profile fields with multiple possible field names
              final userName = profileData['fullName']?.toString() ?? 
                              profileData['name']?.toString() ?? 
                              profileData['userName']?.toString() ?? 
                              result['userName']?.toString();
              final userEmail = profileData['email']?.toString() ?? 
                               profileData['hrEmail']?.toString() ?? 
                               profileData['userEmail']?.toString() ?? 
                               result['userEmail']?.toString();
              final company = profileData['companyName']?.toString() ?? 
                             profileData['company']?.toString() ?? 
                             result['company']?.toString();
              final location = profileData['location']?.toString() ?? 
                              profileData['officeAddress']?.toString() ?? 
                              profileData['city']?.toString() ??
                              profileData['hrLocation']?.toString();
              
              // Handle skills array
              String? skillsStr;
              if (profileData['skills'] != null) {
                if (profileData['skills'] is List) {
                  final skillsList = profileData['skills'] as List;
                  skillsStr = skillsList.isNotEmpty ? skillsList.join(', ') : null;
                } else {
                  skillsStr = profileData['skills'].toString();
                }
              }
              
              print('📝 Extracted fields:');
              print('   userName: $userName');
              print('   userEmail: $userEmail');
              print('   company: $company');
              print('   location: $location');
              print('   phone: $phone');
              print('   designation: ${profileData['designation']}');
              print('   experience: ${profileData['experience']}');
              print('   skills: $skillsStr');
              print('   bio: ${profileData['bio']}');
              
              // Update user storage with complete profile data
              await UserStorage.updateUserProfile(
                userName: userName,
                userEmail: userEmail,
                company: company,
                designation: profileData['designation']?.toString(),
                experience: profileData['experience']?.toString(),
                location: location,
                skills: skillsStr,
                bio: profileData['bio']?.toString(),
                totalEmp: profileData['totalEmp']?.toString(),
                profileImage: profileData['profilePhoto']?.toString() ?? profileData['profileImage']?.toString(),
              );
              
              // Existing user has a complete profile
              await UserStorage.setProfileComplete(true);
              
              print('✅ User storage updated with profile data');
              
              // Verify data was saved
              final savedData = await UserStorage.getLoginData();
              print('🔍 Verification - Saved data: $savedData');
            } else {
              print('⚠️ Failed to fetch HR profile: ${profileResult['message']}');
              print('⚠️ Profile result success: ${profileResult['success']}');
              print('⚠️ Profile result data: ${profileResult['data']}');
            }
          } catch (e) {
            print('❌ Error fetching HR profile: $e');
            print('❌ Stack trace: ${StackTrace.current}');
          }
        } else {
          print('⚠️ hrId is null or empty, cannot fetch profile');
        }
      } else {
        print('🔍 Not an existing user or isExistingUser is false');
      }
    } else {
      _errorMessage = result['message'] ?? 'Verification failed';
      _isExistingUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
