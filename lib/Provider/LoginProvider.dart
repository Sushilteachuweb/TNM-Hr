import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/auth_api_service.dart';

class LoginProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  int? _otp;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int? get otp => _otp;

  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = '';
    _otp = null;
    notifyListeners();

    // Validate phone number
    if (phoneNumber.length != 10 || !RegExp(r'^\d+$').hasMatch(phoneNumber)) {
      _isLoading = false;
      _errorMessage = 'Please enter a valid 10-digit phone number';
      notifyListeners();
      return;
    }

    // Check Internet
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isLoading = false;
      _errorMessage = 'Please connect your Internet';
      notifyListeners();
      return;
    }

    // Call API service
    final result = await AuthApiService.sendOtp(phoneNumber);

    if (result['success'] == true) {
      _otp = result['otp'];
    } else {
      _errorMessage = result['message'] ?? 'Failed to send OTP';
    }

    _isLoading = false;
    notifyListeners();
  }
}
