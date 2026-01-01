import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../Provider/job_provider.dart';
import '../../../../Provider/plan_provider.dart';
import '../../../../Provider/billing_provider.dart';
import '../../../../Provider/credit_provider.dart';
import '../../../../models/job_plan_model.dart';
import '../../../../services/plan_api_service.dart';
import '../../../../services/user_storage.dart';
import '../../../bottomNavBar/bottomNavBar.dart';
import '../../../../widgets/skeleton_components.dart';

class Subscription extends StatefulWidget {
  final Map<String, dynamic> jobData;
  
  const Subscription({super.key, required this.jobData});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    
    // Fetch plans when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlanProvider>(context, listen: false).fetchPlans();
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    final billingProvider = Provider.of<BillingProvider>(context, listen: false);
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    
    // Update billing record status to success
    if (planProvider.selectedPlan != null) {
      await billingProvider.updateBillingRecordStatus(
        orderId: response.orderId ?? '',
        status: 'Success',
        paymentId: response.paymentId,
      );
      
      // Add credits from the purchased plan
      await creditProvider.addCreditsFromPlan(
        planProvider.selectedPlan!.id,
        planProvider.selectedPlan!.planName,
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful: ${response.paymentId}'),
        backgroundColor: AppColors.success,
      ),
    );

    // Call create job API after successful payment with selected plan
    await _createJobAfterPayment(planProvider.selectedPlan);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _createJobAfterPayment(JobPlan? selectedPlan) async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      
      final success = await jobProvider.createJob(
        hrPhone: widget.jobData['hrPhone'] ?? '',
        title: widget.jobData['title'] ?? '',
        companyName: widget.jobData['companyName'] ?? '',
        jobCategory: widget.jobData['jobCategory'] ?? '',
        jobType: widget.jobData['jobType'] ?? '',
        planType: selectedPlan?.planName.toLowerCase().replaceAll(' ', '_') ?? 'basic',
        salaryType: widget.jobData['salaryType'] ?? 'Fixed',
        salaryRange: widget.jobData['salaryRange'] ?? {'min': 0, 'max': 0},
        workLocation: widget.jobData['workLocation'] ?? 'Work From Home',
        jobLocation: widget.jobData['jobLocation'] ?? 'Not specified',
        preferredLocation: widget.jobData['preferredLocation'] ?? 'Not specified',
        officeAddress: widget.jobData['officeAddress'] ?? 'Not specified',
        floorDetails: widget.jobData['floorDetails'] ?? 'Ground Floor',
        coordinates: widget.jobData['coordinates'] ?? [0.0, 0.0],
        minimumEducation: widget.jobData['minimumEducation'] ?? "Bachelor's Degree",
        englishLevel: widget.jobData['englishLevel'] ?? 'intermediate',
        totalExperience: widget.jobData['totalExperience'] ?? '0-1 years',
        openingFor: widget.jobData['openingFor'] ?? 'Any',
        jobDescription: widget.jobData['jobDescription'] ?? 'Job description not provided',
        ageRange: widget.jobData['ageRange'] ?? {'min': 18, 'max': 60},
        gender: widget.jobData['gender'] ?? 'Both genders allowed',
        openings: widget.jobData['openings'] ?? 1,
        isWalkInInterview: widget.jobData['isWalkInInterview'] ?? false,
        additionalPerks: widget.jobData['additionalPerks'] ?? [],
        documents: widget.jobData['documents'] ?? ['Aadhar Card'],
        communicationPreference: widget.jobData['communicationPreference'] ?? 'phone',
        workingDays: widget.jobData['workingDays'] ?? 'monday-saturday',
        jobTiming: widget.jobData['jobTiming'] ?? '9:00 AM - 6:00 PM',
      );

      if (success) {
        // Deduct 1 credit for the job posting
        final creditProvider = Provider.of<CreditProvider>(context, listen: false);
        await creditProvider.deductCredits(1);
        
        // Navigate to home screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(initialIndex: 1), // Go to Jobs tab
          ),
          (route) => false,
        );
        
        // Note: Success message will be shown by the destination screen
        // No need to show SnackBar here since we're navigating away
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jobProvider.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to create job. Please try again.'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _createJobAfterPayment(selectedPlan),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Select a Plan",
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.circle,
                      color: AppColors.accentLight,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "100",
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<PlanProvider>(
        builder: (context, planProvider, child) {
          if (planProvider.isLoading) {
            return const PlansScreenSkeleton();
          }

          if (planProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load plans',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    planProvider.errorMessage,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => planProvider.fetchPlans(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (planProvider.plans.isEmpty) {
            return const Center(
              child: Text('No plans available'),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              ...planProvider.plans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlanCard(plan),
              )).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.stars_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Your Plan",
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Unlock premium features",
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(JobPlan plan) {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    final isSelected = planProvider.selectedPlan?.id == plan.id;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          // Plan Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: plan.gradientColors),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.planName,
                            style: AppTextStyles.h4.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (plan.isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "RECOMMENDED",
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan.validityText,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (plan.discountPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${plan.discountPercent}% OFF",
                      style: AppTextStyles.caption.copyWith(
                        color: plan.gradientColors.first,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Plan Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Features
                _buildFeatureRow(Icons.work_outline, plan.creditsText),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.schedule_outlined, plan.jobActiveText),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.access_time, "Use Credits in ${plan.validityDays} Days"),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.filter_alt_outlined, plan.filtersText),
                if (plan.aiMatching) ...[
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.psychology_outlined, "AI Matching"),
                ],
                if (plan.whatsappLead) ...[
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.message_outlined, "WhatsApp Leads"),
                ],
                
                const SizedBox(height: 20),
                
                // Pricing
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.formattedPrice,
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (plan.originalPrice > plan.pricePerMonth)
                                Text(
                                  plan.formattedOriginalPrice,
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            plan.description,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectPlanAndProceed(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? AppColors.primary : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isSelected ? "Selected" : "Select Plan",
                        style: AppTextStyles.button,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _selectPlanAndProceed(JobPlan plan) {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    planProvider.selectPlan(plan);
    
    // Proceed with payment using new API
    _startPayment(plan);
  }

  Future<void> _startPayment(JobPlan plan) async {
    try {
      final billingProvider = Provider.of<BillingProvider>(context, listen: false);
      
      // Get user ID from UserStorage
      final userId = await UserStorage.getUserId();
      
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User not found. Please login again.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      // Create order using the new buy plan API
      final orderResponse = await PlanApiService.buyPlan(
        planId: plan.id,
        userId: userId,
        amount: plan.pricePerMonth,
      );

      if (orderResponse['success'] == true && orderResponse['order'] != null) {
        final order = orderResponse['order'];
        
        // Add billing record as pending
        await billingProvider.addBillingRecord(
          planName: plan.planName,
          planId: plan.id,
          amount: plan.pricePerMonth,
          status: 'Pending',
          paymentId: '',
          orderId: order['id'],
          expiresOn: _calculateExpiryDate(plan.validityDays),
        );
        
        // Start Razorpay payment with the order details
        var options = {
          'key': 'rzp_test_RSsp7FsCxepW8t',
          'amount': order['amount'], // Amount in paise from API response
          'name': 'Naukri Mitra',
          'description': '${plan.planName} - ${plan.description}',
          'order_id': order['id'], // Use order ID from API
          'prefill': {
            'contact': widget.jobData['hrPhone'] ?? '',
            'email': 'hr@example.com'
          },
          'external': {
            'wallets': ['paytm']
          },
          'theme': {
            'color': '#2563EB'
          }
        };

        _razorpay.open(options);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderResponse['message'] ?? 'Unable to create order. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to process payment. Please try again.'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              // Retry payment
            },
          ),
        ),
      );
    }
  }

  String _calculateExpiryDate(int validityDays) {
    final expiryDate = DateTime.now().add(Duration(days: validityDays));
    return '${expiryDate.day.toString().padLeft(2, '0')}/${expiryDate.month.toString().padLeft(2, '0')}/${expiryDate.year.toString().substring(2)}';
  }
}
