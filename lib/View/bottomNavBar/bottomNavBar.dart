import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naukri_hr_app/View/Home/HomeScreen.dart';
import 'package:naukri_hr_app/View/Jobs/job_Screen.dart';
import 'package:naukri_hr_app/View/Plans/plans_screen.dart';
import 'package:naukri_hr_app/View/Helps/help_screen.dart';
import 'package:naukri_hr_app/View/Profiles/profile_screen.dart';
import 'package:naukri_hr_app/View/Profiles/EditProfileScreen.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/user_storage.dart';
import '../../Widgets/back_button_handler.dart';
import '../../Provider/hr_profile_provider.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  final bool showProfileCompletionSnackbar;
  
  const BottomNavBar({
    super.key, 
    this.initialIndex = 0,
    this.showProfileCompletionSnackbar = false,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;
  DateTime? _lastBackPressed;
  
  // Create screens once and preserve their state
  late List<Widget> _screens;
  
  // Key to force ProfileScreen rebuild when needed
  Key _profileScreenKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Initialize screens once to preserve state
    _screens = [
      const HomeScreen(),
      const JobScreen(),
      const PlansScreen(),
      const HelpScreen(),
      ProfileScreen(key: _profileScreenKey),
    ];

    // Show profile completion snackbar for new users
    if (widget.showProfileCompletionSnackbar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileCompletionSnackbar();
      });
    } else {
      // Check if we should show the snackbar for new users
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowProfileCompletionSnackbar();
      });
    }
  }

  Future<void> _checkAndShowProfileCompletionSnackbar() async {
    try {
      final isExistingUser = await UserStorage.isExistingUser();
      final hasSnackbarBeenShown = await UserStorage.hasProfileCompletionSnackbarBeenShown();
      
      // Show snackbar only for new users who haven't seen it yet
      if (!isExistingUser && !hasSnackbarBeenShown) {
        _showProfileCompletionSnackbar();
      }
    } catch (e) {
      print('Error checking profile completion snackbar status: $e');
    }
  }

  void _showProfileCompletionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add more details to your Profile.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Complete',
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          onPressed: () async {
            // Mark snackbar as shown
            await UserStorage.markProfileCompletionSnackbarAsShown();
            
            // Navigate to edit profile screen
            _navigateToEditProfile();
          },
        ),
      ),
    );

    // Mark snackbar as shown after a delay (in case user doesn't click the action)
    Future.delayed(const Duration(seconds: 6), () async {
      await UserStorage.markProfileCompletionSnackbarAsShown();
    });
  }

  void _navigateToEditProfile() async {
    try {
      // Get current user data for the edit profile screen
      final userData = await UserStorage.getLoginData();
      
      // Navigate to edit profile screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(initialData: userData),
        ),
      );

      // If profile was updated, you might want to refresh data or show a success message
      if (result == true) {
        print("✅ Profile completed from popup, refreshing app data...");
        
        // Refresh HR profile provider to get latest data
        try {
          final hrProfileProvider = Provider.of<HrProfileProvider>(context, listen: false);
          final hrId = await UserStorage.getHrId();
          if (hrId != null && hrId.isNotEmpty) {
            await hrProfileProvider.fetchProfile(hrId);
            print("✅ HR profile refreshed after completion");
          }
        } catch (e) {
          print("⚠️ Error refreshing profile: $e");
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Force ProfileScreen to rebuild by changing its key
        setState(() {
          _profileScreenKey = UniqueKey();
          _screens[4] = ProfileScreen(key: _profileScreenKey);
        });
      }
    } catch (e) {
      print('Error navigating to edit profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open profile editor. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    // If not on home screen, navigate to home screen
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false; // Don't exit the app
    }
    
    // If on home screen, check for double tap to exit
    final now = DateTime.now();
    if (_lastBackPressed == null || 
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      
      // Show toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Press back again to exit'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return false; // Don't exit the app
    }
    
    // Double tap detected, exit the app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      canPop: false,
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_outlined,
                    Icons.home_rounded,
                    "Home",
                  ),
                  _buildNavItem(
                    1,
                    Icons.work_outline_rounded,
                    Icons.work_rounded,
                    "Jobs",
                  ),
                  _buildNavItem(
                    2,
                    Icons.credit_card_outlined,
                    Icons.credit_card_rounded,
                    "Plans",
                  ),
                  _buildNavItem(
                    3,
                    Icons.help_outline_rounded,
                    Icons.help_rounded,
                    "Help",
                  ),
                  _buildNavItem(
                    4,
                    Icons.person_outline_rounded,
                    Icons.person_rounded,
                    "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
