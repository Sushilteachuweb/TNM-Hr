import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../Provider/Otp_provider.dart';
import '../../Provider/LoginProvider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/auth_api_service.dart';
import '../../services/app_data_manager.dart';
import '../CreateProfileScreen/CreateProfileScreen.dart';
import '../bottomNavBar/bottomNavBar.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final int otp;
  const OtpScreen({super.key, required this.phone, required this.otp});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp(OtpProvider provider) async {
    if (_otpController.text.length != 4) {
      _showSnackBar("Please enter a valid 4-digit OTP", isError: true);
      return;
    }

    await provider.verifyOtp(widget.phone, _otpController.text);

    if (provider.errorMessage.isNotEmpty) {
      _showSnackBar(provider.errorMessage, isError: true);
    } else if (provider.isExistingUser != null) {
      if (provider.isExistingUser!) {
        print("✅ Navigating to BottomNavBar (Existing User)");
        
        // Initialize app data for existing users
        print("🚀 Initializing app data after login...");
        await AppDataManager.initializeAppData(context);
        print("✅ App data initialization completed after login");
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        print("✅ Navigating to CreateProfileScreen (New User)");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
        );
      }
    } else {
      print(
        "❌ No error message but isExistingUser is null - this shouldn't happen",
      );
      _showSnackBar(
        "Verification completed but user status unclear. Please try again.",
        isError: true,
      );
    }
  }

  void _resendOtp() async {
    setState(() {});
    
    final result = await AuthApiService.resendOtp(widget.phone);

    if (result['success'] == true) {
      _showSnackBar(result['message'] ?? "OTP resent successfully!");
      _otpController.clear();
    } else {
      _showSnackBar(result['message'] ?? "Failed to resend OTP", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (_) => OtpProvider(),
      child: Consumer2<OtpProvider, LoginProvider>(
        builder: (context, otpProvider, loginProvider, child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.06),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [AppColors.buttonShadow],
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Verify OTP",
                        style: AppTextStyles.h1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Code sent to ", style: AppTextStyles.body2),
                          Text(
                            "+91 ${widget.phone}",
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LoginScreen(initialPhone: widget.phone),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.06),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [AppColors.cardShadow],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Enter 4-Digit Code",
                              style: AppTextStyles.subtitle2.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Pinput(
                              length: 4,
                              controller: _otpController,
                              defaultPinTheme: PinTheme(
                                width: 64,
                                height: 64,
                                textStyle: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                ),
                              ),
                              focusedPinTheme: PinTheme(
                                width: 64,
                                height: 64,
                                textStyle: AppTextStyles.h2.copyWith(
                                  color: AppColors.primary,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              submittedPinTheme: PinTheme(
                                width: 64,
                                height: 64,
                                textStyle: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            otpProvider.isLoading
                                ? CircularProgressIndicator(
                                    color: AppColors.primary,
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [AppColors.buttonShadow],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => _verifyOtp(otpProvider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Verify & Continue",
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Didn't receive code? ",
                                  style: AppTextStyles.body2,
                                ),
                                TextButton(
                                  onPressed: _resendOtp,
                                  child: Text(
                                    "Resend",
                                    style: AppTextStyles.subtitle2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
