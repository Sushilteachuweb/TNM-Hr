import 'package:flutter/material.dart';
import 'package:naukri_hr_app/View/Home/HomeScreen.dart';
import 'package:naukri_hr_app/View/Jobs/job_Screen.dart';
import 'package:naukri_hr_app/View/Plans/plans_screen.dart';
import 'package:naukri_hr_app/View/Helps/help_screen.dart';
import 'package:naukri_hr_app/View/Profiles/profile_screen.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';

class BottomNavBar extends StatefulWidget {
  final int initialIndex;
  
  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;
  
  // Create screens once and preserve their state
  late final List<Widget> _screens;

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
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
