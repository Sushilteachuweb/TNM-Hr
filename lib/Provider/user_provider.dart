import 'package:flutter/material.dart';
import '../services/user_api_service.dart';

class UserProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<dynamic> _users = [];
  bool _hasLoadedOnce = false; // Track if data has been loaded

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<dynamic> get users => _users;
  int get usersCount => _users.length;
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Fetch all users with optional filters - only loads if not already loaded, unless force refresh
  Future<void> fetchUsers({
    String? skills,
    String? city,
    String? experience,
    String? keyword,
    bool forceRefresh = false,
  }) async {
    // Skip loading if already loaded and not forcing refresh (and no filters applied)
    if (_hasLoadedOnce && !forceRefresh && 
        skills == null && city == null && experience == null && keyword == null) {
      print("👥 Users already loaded, skipping fetch");
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final result = await UserApiService.getUsers(
      skills: skills,
      city: city,
      experience: experience,
      keyword: keyword,
    );

    try {
      if (result['success'] == true) {
        _users = result['data']['users'] ?? result['data'] ?? [];
        if (skills == null && city == null && experience == null && keyword == null) {
          _hasLoadedOnce = true; // Mark as loaded only for initial load without filters
        }
      } else {
        _errorMessage = result['message'] ?? 'Failed to fetch users';
        if (skills == null && city == null && experience == null && keyword == null) {
          _hasLoadedOnce = true; // Mark as loaded even on error to prevent infinite skeleton
        }
      }
    } catch (e) {
      print("❌ User data processing error: $e");
      _errorMessage = 'Unable to load users. Please try again.';
      if (skills == null && city == null && experience == null && keyword == null) {
        _hasLoadedOnce = true; // Mark as loaded even on error to prevent infinite skeleton
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear filters and fetch all users
  Future<void> clearFilters() async {
    await fetchUsers();
  }

  /// Clear all data
  void clear() {
    _users = [];
    _errorMessage = '';
    notifyListeners();
  }
}
