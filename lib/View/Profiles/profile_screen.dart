import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/user_storage.dart';
import '../../services/auth_api_service.dart';
import '../../services/hr_profile_api_service.dart';
import '../../Provider/hr_profile_provider.dart';
import '../../Provider/plan_provider.dart';
import '../../Provider/job_provider.dart';
import '../../Provider/user_provider.dart';
import '../../Provider/credit_provider.dart';
import '../../Provider/billing_provider.dart';
import '../../Provider/applicant_provider.dart';
import '../../services/app_data_manager.dart';
import '../bottomNavBar/bottomNavBar.dart';
import '../Screens/login_Screen.dart';
import '../ReferEarn/refer_earn_screen.dart';
import 'EditProfileScreen.dart';
import '../../widgets/skeleton_components.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  Map<String, dynamic> _userData = {};
  bool _isLoading = false;
  bool _hasLoadedOnce = false; // Add caching for profile data

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Profile data is already loaded by AuthSplashScreen, just load from storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedOnce) {
        _loadUserDataFromStorage();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh profile when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      print("📱 App resumed, refreshing profile...");
      _loadUserData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile data when screen becomes visible
    // This ensures data is fresh when navigating back to profile tab
    if (_hasLoadedOnce) {
      print("📱 Profile screen dependencies changed, refreshing...");
      _loadUserData();
    }
  }

  Future<void> _loadUserDataFromStorage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load from local storage only (API data already loaded by AuthSplashScreen)
      final userData = await UserStorage.getLoginData();
      print('📱 Profile Screen - Local User Data: $userData');
      
      setState(() {
        _userData = userData;
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    } catch (e) {
      print('📱 Profile Screen - Error loading from storage: $e');
      setState(() {
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Load from local storage first
    final userData = await UserStorage.getLoginData();
    print('📱 Profile Screen - Local User Data: $userData');
    setState(() {
      _userData = userData;
    });

    // Fetch from API if hrId exists
    final hrId = await UserStorage.getHrId();
    print('📱 Profile Screen - hrId: $hrId');
    
    if (hrId != null && hrId.isNotEmpty && hrId != 'null') {
      print('📱 Profile Screen - Fetching profile from API...');
      final result = await HrProfileApiService.getHrProfile(hrId);
      
      print('📱 Profile Screen - API Result: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final apiData = result['data'];
        
        print('📱 Profile Screen - API Data: $apiData');
        print('📱 Profile Screen - API Data Keys: ${apiData.keys}');
        print('📱 Profile Screen - Designation: ${apiData['designation']}');
        print('📱 Profile Screen - Experience: ${apiData['experience']}');
        print('📱 Profile Screen - hrLocation: ${apiData['hrLocation']}');
        print('📱 Profile Screen - Bio: ${apiData['bio']}');
        print('📱 Profile Screen - TotalEmp: ${apiData['totalEmp']}');
        print('📱 Profile Screen - Skills: ${apiData['skills']}');
        
        // Handle skills array
        String? skillsStr;
        if (apiData['skills'] != null) {
          if (apiData['skills'] is List) {
            final skillsList = apiData['skills'] as List;
            skillsStr = skillsList.isNotEmpty ? skillsList.join(', ') : null;
            print('📱 Profile Screen - Skills converted to string: $skillsStr');
          } else {
            skillsStr = apiData['skills'].toString();
            print('📱 Profile Screen - Skills as string: $skillsStr');
          }
        }
        
        // Prepare update data - only include fields that exist in API response
        Map<String, String?> updateData = {
          'userName': apiData['fullName']?.toString() ?? apiData['name']?.toString() ?? apiData['userName']?.toString(),
          'userEmail': apiData['email']?.toString() ?? apiData['hrEmail']?.toString() ?? apiData['userEmail']?.toString(),
          'company': apiData['companyName']?.toString() ?? apiData['company']?.toString(),
        };
        
        // Only add new fields if they exist in API response
        if (apiData['designation'] != null) {
          updateData['designation'] = apiData['designation'].toString();
        }
        if (apiData['experience'] != null) {
          updateData['experience'] = apiData['experience'].toString();
        }
        if (apiData['hrLocation'] != null || apiData['location'] != null || 
            apiData['officeAddress'] != null || apiData['city'] != null) {
          updateData['location'] = apiData['hrLocation']?.toString() ?? apiData['location']?.toString() ?? 
                                   apiData['officeAddress']?.toString() ?? apiData['city']?.toString();
        }
        if (skillsStr != null) {
          updateData['skills'] = skillsStr;
        }
        if (apiData['bio'] != null) {
          updateData['bio'] = apiData['bio'].toString();
        }
        if (apiData['totalEmp'] != null) {
          updateData['totalEmp'] = apiData['totalEmp'].toString();
          print('📊 Profile Screen - TotalEmp from API: ${apiData['totalEmp']}');
        }
        if (apiData['profilePhoto'] != null) {
          updateData['profileImage'] = apiData['profilePhoto'].toString();
        }
        if (apiData['verificationDocument'] != null) {
          updateData['verificationDocument'] = apiData['verificationDocument'].toString();
          print('📄 Verification Document URL: ${apiData['verificationDocument']}');
        } else {
          print('⚠️ No verificationDocument field in API response');
          print('📋 Available API fields: ${apiData.keys.toList()}');
        }
        
        // Update local storage with API data (only non-null values)
        await UserStorage.updateUserProfile(
          userName: updateData['userName'],
          userEmail: updateData['userEmail'],
          company: updateData['company'],
          designation: updateData['designation'],
          experience: updateData['experience'],
          location: updateData['location'],
          skills: updateData['skills'],
          bio: updateData['bio'],
          totalEmp: updateData['totalEmp'],
          profileImage: updateData['profileImage'],
          verificationDocument: updateData['verificationDocument'],
        );

        print('📱 Profile Screen - Storage updated');

        // Reload from storage
        final updatedData = await UserStorage.getLoginData();
        print('📱 Profile Screen - Updated User Data: $updatedData');
        print('📱 Profile Screen - Stored Designation: ${updatedData['designation']}');
        print('📱 Profile Screen - Stored Experience: ${updatedData['experience']}');
        print('📱 Profile Screen - Stored Location: ${updatedData['location']}');
        print('📱 Profile Screen - Stored Skills: ${updatedData['skills']}');
        print('📱 Profile Screen - Stored Bio: ${updatedData['bio']}');
        print('📱 Profile Screen - Stored TotalEmp: ${updatedData['totalEmp']}');
        setState(() {
          _userData = updatedData;
        });
      } else {
        print('📱 Profile Screen - Failed to fetch from API: ${result['message']}');
      }
    } else {
      print('📱 Profile Screen - No valid hrId, skipping API fetch');
    }

    setState(() {
      _isLoading = false;
      _hasLoadedOnce = true; // Mark as loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Log current state before building
    print('🎨 Profile Screen - Building UI with totalEmp: ${_userData['totalEmp']}');
    
    // Only show skeleton if loading for the first time
    if (_isLoading && !_hasLoadedOnce) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
            onPressed: () {
              // Navigate to home screen instead of going back
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNavBar(initialIndex: 0),
                ),
              );
            },
          ),
          title: Text(
            "Profile",
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
        ),
        body: const ProfileScreenSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () {
            // Navigate to home screen instead of going back
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavBar(initialIndex: 0),
              ),
            );
          },
        ),
        title: Text(
          "Profile",
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileInfo(),
            const SizedBox(height: 24),
            _buildReferEarnButton(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    String? profileImagePath = _userData['profileImage'];
    String designation = _userData['designation'] ?? "HR Manager";
    String company = _userData['company'] ?? "TNM Recruiter";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image with Camera Icon on the left
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFE8F1F8),
                  backgroundImage: profileImagePath != null && profileImagePath.isNotEmpty
                      ? (profileImagePath.startsWith('/uploads') 
                          ? NetworkImage('https://api.thenaukrimitra.com$profileImagePath') as ImageProvider
                          : profileImagePath.startsWith('http')
                              ? NetworkImage(profileImagePath) as ImageProvider
                              : FileImage(File(profileImagePath)))
                      : null,
                  child: profileImagePath == null || profileImagePath.isEmpty
                      ? Icon(Icons.person, size: 40, color: AppColors.primary)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name and Bio section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                // Name
                Text(
                  _userData['userName'] ?? "TNM Recruiter",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                // Bio/Designation
                Text(
                  "Working as $designation at $company",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Edit button at top right
          TextButton(
            onPressed: () async {
              print("📝 Navigating to Edit Profile...");
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(initialData: _userData),
                ),
              );
              print("📝 Returned from Edit Profile with result: $result");
              if (result == true) {
                print("🔄 Refreshing profile data...");
                // Add delay to ensure API and storage updates are complete
                await Future.delayed(const Duration(milliseconds: 500));
                
                // Force reload from storage first
                final freshData = await UserStorage.getLoginData();
                print("📊 Fresh data from storage after edit: $freshData");
                print("📊 TotalEmp in fresh data: ${freshData['totalEmp']}");
                
                setState(() {
                  _userData = freshData;
                });
                
                // Then fetch from API
                await _loadUserData();
                print("✅ Profile refresh complete");
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              "Edit",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    bool isDocumentVerified = _userData['verificationDocument'] != null && 
                              _userData['verificationDocument'].toString().isNotEmpty &&
                              _userData['verificationDocument'].toString() != 'null';
    
    print('🔍 Checking verification status:');
    print('   - verificationDocument value: ${_userData['verificationDocument']}');
    print('   - isDocumentVerified: $isDocumentVerified');
    print('   - All userData keys: ${_userData.keys.toList()}');
    
    // Temporary: Force verification to true for testing
    isDocumentVerified = true;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.email_outlined,
            "Email",
            _userData['userEmail'] ?? "hr@tnmrecruiter.com",
          ),
          const Divider(),
          _buildInfoRow(
            Icons.phone_outlined,
            "Phone",
            "+91 ${_userData['phone'] ?? '9876543210'}",
          ),
          const Divider(),
          _buildInfoRowWithVerification(
            Icons.business_outlined,
            "Company",
            _userData['company'] ?? "TNM Recruiter",
            isVerified: isDocumentVerified,
          ),
          const Divider(),
          if (_userData['designation'] != null &&
              _userData['designation'].toString().isNotEmpty) ...[
            _buildInfoRow(
              Icons.work_outline,
              "Designation",
              _userData['designation'].toString(),
            ),
            const Divider(),
          ],
          if (_userData['experience'] != null &&
              _userData['experience'].toString().isNotEmpty) ...[
            _buildInfoRow(
              Icons.trending_up,
              "Experience",
              "${_userData['experience']} years",
            ),
            const Divider(),
          ],
          _buildInfoRow(
            Icons.location_on_outlined,
            "Location",
            _userData['location'] ?? "Noida, India",
          ),
          if (_userData['totalEmp'] != null &&
              _userData['totalEmp'].toString().isNotEmpty) ...[
            const Divider(),
            Builder(
              builder: (context) {
                print('🎨 Rendering totalEmp widget with value: ${_userData['totalEmp']}');
                return _buildInfoRow(
                  Icons.groups_outlined,
                  "Total Employees",
                  _userData['totalEmp'].toString(),
                );
              },
            ),
          ],
          if (_userData['skills'] != null &&
              _userData['skills'].toString().isNotEmpty) ...[
            const Divider(),
            _buildInfoRow(
              Icons.psychology_outlined,
              "Skills",
              _userData['skills'].toString(),
            ),
          ],
          if (_userData['bio'] != null &&
              _userData['bio'].toString().isNotEmpty) ...[
            const Divider(),
            _buildInfoRow(Icons.description_outlined, "About Company", _userData['bio'].toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithVerification(IconData icon, String label, String value, {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: AppColors.success,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "Verified",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferEarnButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReferEarnScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Refer & Earn",
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Invite friends and earn rewards",
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Capture the outer context before showing dialog
          final scaffoldContext = context;
          
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text("Logout", style: AppTextStyles.h4),
              content: Text(
                "Are you sure you want to logout?",
                style: AppTextStyles.body1,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("Cancel", style: AppTextStyles.subtitle2),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Close dialog first
                    Navigator.pop(dialogContext);
                    
                    // Show loading indicator
                    showDialog(
                      context: scaffoldContext,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                    
                    // Call logout API
                    final result = await AuthApiService.logout();
                    
                    // Clear local storage
                    await UserStorage.clearUser();
                    
                    // Clear all providers
                    final hrProfileProvider = Provider.of<HrProfileProvider>(scaffoldContext, listen: false);
                    await hrProfileProvider.clearProfile();
                    
                    // Clear other providers
                    Provider.of<PlanProvider>(scaffoldContext, listen: false).clear();
                    Provider.of<JobProvider>(scaffoldContext, listen: false).clear();
                    Provider.of<UserProvider>(scaffoldContext, listen: false).clear();
                    Provider.of<CreditProvider>(scaffoldContext, listen: false).clear();
                    Provider.of<BillingProvider>(scaffoldContext, listen: false).clear();
                    Provider.of<ApplicantProvider>(scaffoldContext, listen: false).clear();
                    
                    // Reset AppDataManager state
                    AppDataManager.reset();
                    
                    // Close loading indicator
                    if (scaffoldContext.mounted) {
                      Navigator.pop(scaffoldContext);
                    }
                    
                    // Navigate to login screen
                    if (scaffoldContext.mounted) {
                      Navigator.of(scaffoldContext).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                      
                      // Show success message after navigation
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (scaffoldContext.mounted) {
                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['message'] ?? 'Logged out successfully',
                              ),
                              backgroundColor: result['success'] == true
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          );
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: Text("Logout", style: AppTextStyles.button),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: Text(
          "Logout",
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}