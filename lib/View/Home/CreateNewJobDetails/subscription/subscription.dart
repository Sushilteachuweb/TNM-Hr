import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../services/job_creation_service.dart';
import '../../../bottomNavBar/bottomNavBar.dart';

class Subscription extends StatefulWidget {
  final Map<String, dynamic> jobData;
  
  const Subscription({super.key, required this.jobData});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  @override
  void initState() {
    super.initState();
    
    // Create job as draft when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createJobAsDraft();
    });
  }

  /// Create job as draft
  Future<void> _createJobAsDraft() async {
    print("📝 Creating job as draft");
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Create job as draft (no credit check needed)
      final jobId = await JobCreationService.createJobAsDraft(
        context: context,
        jobData: widget.jobData,
      );
      
      // Remove loading indicator
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Remove loading dialog
      }
      
      if (jobId != null) {
        // Job created as draft successfully
        print("✅ Job created as draft with ID: $jobId");
        
        // Show success message and navigate to jobs screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Job saved as draft successfully! You can publish it from the Jobs screen.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate to jobs screen where user can publish the draft
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const BottomNavBar(initialIndex: 1),
            ),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Job creation failed
        print("❌ Failed to create job as draft");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to create job. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
          // Go back to previous screen
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Remove loading indicator on error
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Remove loading dialog
      }
      
      print("❌ Job creation failed with error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to create job. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
        // Go back to previous screen
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Creating your job...',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
