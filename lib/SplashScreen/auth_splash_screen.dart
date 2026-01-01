import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_storage.dart';
import '../services/app_data_manager.dart';
import '../Provider/hr_profile_provider.dart';
import '../View/Screens/Select_Services.dart';
import '../View/bottomNavBar/bottomNavBar.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class AuthSplashScreen extends StatefulWidget {
  const AuthSplashScreen({super.key});

  @override
  State<AuthSplashScreen> createState() => _AuthSplashScreenState();
}

class _AuthSplashScreenState extends State<AuthSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _textController.forward();
    });

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final isLoggedIn = await UserStorage.isLoggedIn();
      print("🔍 Auth Check - Is Logged In: $isLoggedIn");

      if (isLoggedIn) {
        final userData = await UserStorage.getLoginData();
        print("🔍 Auth Check - User Data: $userData");

        // Load HR profile data
        final hrProfileProvider = Provider.of<HrProfileProvider>(context, listen: false);
        await hrProfileProvider.loadProfileFromLocal();
        print("🔍 HR Profile loaded from local: ${hrProfileProvider.profileData}");

        // Fetch fresh data from API if hrId exists
        final hrId = await UserStorage.getHrId();
        if (hrId != null && hrId.isNotEmpty) {
          print("🔄 Fetching fresh HR profile from API with hrId: $hrId");
          await hrProfileProvider.fetchProfile(hrId);
          print("✅ Fresh HR profile loaded: ${hrProfileProvider.profileData}");
        }

        // Initialize all app data once
        print("🚀 Initializing app data...");
        await AppDataManager.initializeAppData(context);
        print("✅ App data initialization completed");

         Navigator.pushReplacement(
           context,
           PageRouteBuilder(
             pageBuilder: (context, animation, secondaryAnimation) =>
                 const BottomNavBar(),
             transitionsBuilder:
                 (context, animation, secondaryAnimation, child) {
                   return FadeTransition(opacity: animation, child: child);
                 },
             transitionDuration: const Duration(milliseconds: 600),
           ),
         );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SelectServices(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/splash1.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _textAnimation,
                  child: Column(
                    children: [
                      Text(
                        "Rozgar Ka",
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Digital Saathi",
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Your Hiring Partner",
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
