import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../config/razorpay_config.dart';
import '../../Provider/plan_provider.dart';
import '../../Provider/billing_provider.dart';
import '../../Provider/credit_provider.dart';
import '../../Provider/unified_billing_provider.dart';
import '../../models/job_plan_model.dart';
import '../../models/billing_history_model.dart';
import '../../models/payment_history_model.dart';
import '../../services/plan_api_service.dart';
import '../../services/payment_verification_service.dart';
import '../../services/user_storage.dart';
import '../bottomNavBar/bottomNavBar.dart';
import '../../widgets/skeleton_components.dart';
import 'payment_details_screen.dart';
import 'checkout_summary_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Razorpay _razorpay;
  late TabController _tabController;
  bool _isRazorpayInitialized = false;
  bool _isPaymentInProgress = false;
  
  // Store current order details for verification
  String? _currentOrderId;
  String? _currentPlanId;
  String? _currentUserId;
  int? _currentAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _initializeRazorpay();
    
    // Data is already loaded by AppDataManager, just initialize billing history
    // But also ensure plans are loaded in case AppDataManager wasn't called
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final unifiedBillingProvider = Provider.of<UnifiedBillingProvider>(context, listen: false);
      if (!unifiedBillingProvider.hasLoadedOnce || unifiedBillingProvider.paymentHistoryError.isNotEmpty) {
        print("📋 Unified billing data not loaded or has error, fetching now...");
        unifiedBillingProvider.fetchAllData(forceRefresh: unifiedBillingProvider.paymentHistoryError.isNotEmpty);
      }
      
      // Ensure plans are loaded
      final planProvider = Provider.of<PlanProvider>(context, listen: false);
      if (!planProvider.hasLoadedOnce) {
        print("📋 Plans not loaded yet, fetching now...");
        planProvider.fetchPlans();
      }
    });
  }

  void _initializeRazorpay() {
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _isRazorpayInitialized = true;
      
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'razorpay_initialized_successfully',
        }),
        name: 'PaymentFlow',
      );
    } catch (e, stackTrace) {
      _isRazorpayInitialized = false;
      
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'razorpay_initialization_failed',
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
        }),
        name: 'PaymentFlow',
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    developer.log(
      json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'event': 'app_lifecycle_changed',
        'state': state.toString(),
        'hasCurrentOrder': _currentOrderId != null,
      }),
      name: 'PaymentFlow',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    if (_isRazorpayInitialized) {
      try {
        _razorpay.clear();
      } catch (e) {
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'razorpay_clear_failed',
            'error': e.toString(),
          }),
          name: 'PaymentFlow',
        );
      }
    }
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final startTime = DateTime.now();
    
    // Log payment success details for backend developer
    developer.log(
      json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'event': 'razorpay_payment_success',
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signatureReceived': response.signature?.isNotEmpty ?? false,
        'currentOrderId': _currentOrderId,
        'currentPlanId': _currentPlanId,
        'currentMobileNumber': _currentUserId, // Now contains mobile number
        'currentAmount': _currentAmount,
      }),
      name: 'PaymentFlow',
    );
    
    // Check if widget is still mounted
    if (!mounted) {
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'payment_success_widget_not_mounted',
          'orderId': response.orderId,
        }),
        name: 'PaymentFlow',
      );
      return;
    }
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
    
    try {
      // Verify payment with backend
      final verificationResult = await PaymentVerificationService.verifyPayment(
        orderId: response.orderId ?? _currentOrderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
        planId: _currentPlanId ?? '',
        userId: _currentUserId ?? '',
        amount: _currentAmount ?? 0,
      );
      
      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (verificationResult['success'] == true) {
        // Payment verified successfully
        final billingProvider = Provider.of<BillingProvider>(context, listen: false);
        final creditProvider = Provider.of<CreditProvider>(context, listen: false);
        
        // Log successful verification
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'payment_verification_success',
            'orderId': response.orderId ?? _currentOrderId,
            'paymentId': response.paymentId,
            'processingTime': '${processingTime}ms',
            'verificationMessage': verificationResult['message'],
          }),
          name: 'PaymentFlow',
        );
        
        // Update billing record status to success
        await billingProvider.updateBillingRecordStatus(
          orderId: response.orderId ?? _currentOrderId ?? '',
          status: 'Success',
          paymentId: response.paymentId,
        );
        
        // Recalculate credits after successful payment
        await creditProvider.calculateAvailableCredits(forceRefresh: true);
        
        // Refresh unified billing data after successful payment
        final unifiedBillingProvider = Provider.of<UnifiedBillingProvider>(context, listen: false);
        await unifiedBillingProvider.refresh();
        
        // Clear current order details
        _clearCurrentOrderDetails();
        
        // Reset payment in progress flag
        if (mounted) {
          setState(() {
            _isPaymentInProgress = false;
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Payment completed successfully!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Payment verification failed
        final billingProvider = Provider.of<BillingProvider>(context, listen: false);
        
        // Log verification failure
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'payment_verification_failed',
            'orderId': response.orderId ?? _currentOrderId,
            'paymentId': response.paymentId,
            'processingTime': '${processingTime}ms',
            'failureReason': verificationResult['message'],
            'verificationResponse': verificationResult,
          }),
          name: 'PaymentFlow',
        );
        
        // Update billing record status to failed
        await billingProvider.updateBillingRecordStatus(
          orderId: response.orderId ?? _currentOrderId ?? '',
          status: 'Failed',
          paymentId: response.paymentId,
        );
        
        // Clear current order details
        _clearCurrentOrderDetails();
        
        // Reset payment in progress flag
        if (mounted) {
          setState(() {
            _isPaymentInProgress = false;
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Payment processing failed. Please contact support if amount was deducted.'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      
      // Log exception details
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'payment_verification_exception',
          'orderId': response.orderId ?? _currentOrderId,
          'paymentId': response.paymentId,
          'processingTime': '${processingTime}ms',
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
        }),
        name: 'PaymentFlow',
      );
      
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      // Update billing record status to failed
      final billingProvider = Provider.of<BillingProvider>(context, listen: false);
      await billingProvider.updateBillingRecordStatus(
        orderId: response.orderId ?? _currentOrderId ?? '',
        status: 'Failed',
        paymentId: response.paymentId,
      );
      
      // Clear current order details
      _clearCurrentOrderDetails();
      
      // Reset payment in progress flag
      if (mounted) {
        setState(() {
          _isPaymentInProgress = false;
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment processing temporarily unavailable. Please try again.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    // Log payment error details for backend developer
    developer.log(
      json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'event': 'razorpay_payment_error',
        'errorCode': response.code,
        'errorMessage': response.message,
        'currentOrderId': _currentOrderId,
        'currentPlanId': _currentPlanId,
        'currentMobileNumber': _currentUserId, // Now contains mobile number
        'currentAmount': _currentAmount,
      }),
      name: 'PaymentFlow',
    );
    
    // Check if widget is still mounted
    if (!mounted) {
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'payment_error_widget_not_mounted',
          'orderId': _currentOrderId,
        }),
        name: 'PaymentFlow',
      );
      return;
    }
    
    try {
      // Update billing record status to failed if order exists
      if (_currentOrderId != null) {
        final billingProvider = Provider.of<BillingProvider>(context, listen: false);
        await billingProvider.updateBillingRecordStatus(
          orderId: _currentOrderId!,
          status: 'Failed',
        );
      }
    } catch (e) {
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'billing_update_failed_in_error_handler',
          'error': e.toString(),
        }),
        name: 'PaymentFlow',
      );
    }
    
    // Clear current order details
    _clearCurrentOrderDetails();
    
    // Reset payment in progress flag
    if (mounted) {
      setState(() {
        _isPaymentInProgress = false;
      });
    }
    
    if (mounted) {
      // Determine user-friendly message based on error code
      String errorMessage = 'Payment failed. Please try again.';
      
      // Error code 0 = User cancelled (back button pressed)
      // Error code 2 = User cancelled (back button pressed) - most common
      if (response.code == 0 || response.code == 2) {
        errorMessage = 'Payment cancelled. You can try again when ready.';
      } else if (response.message?.toLowerCase().contains('network') ?? false) {
        errorMessage = 'Network error. Please check your connection and try again.';
      } else if (response.message?.toLowerCase().contains('insufficient') ?? false) {
        errorMessage = 'Insufficient balance. Please try a different payment method.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Log external wallet usage for backend developer
    developer.log(
      json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'event': 'razorpay_external_wallet',
        'walletName': response.walletName,
        'currentOrderId': _currentOrderId,
        'currentPlanId': _currentPlanId,
        'currentMobileNumber': _currentUserId, // Now contains mobile number
        'currentAmount': _currentAmount,
      }),
      name: 'PaymentFlow',
    );
    
    // Check if widget is still mounted
    if (!mounted) {
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'external_wallet_widget_not_mounted',
          'orderId': _currentOrderId,
        }),
        name: 'PaymentFlow',
      );
      return;
    }
    
    // Don't clear order details yet - wait for success/failure callback
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment redirected to ${response.walletName ?? 'external wallet'}'),
          backgroundColor: AppColors.info,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _clearCurrentOrderDetails() {
    developer.log(
      json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'event': 'order_details_cleared',
        'clearedOrderId': _currentOrderId,
        'clearedPlanId': _currentPlanId,
        'clearedMobileNumber': _currentUserId, // Now contains mobile number
        'clearedAmount': _currentAmount,
      }),
      name: 'PaymentFlow',
    );
    
    _currentOrderId = null;
    _currentPlanId = null;
    _currentUserId = null; // This now stores mobile number
    _currentAmount = null;
  }

  Future<void> _buyPlan(JobPlan plan) async {
    final startTime = DateTime.now();
    
    // Prevent multiple simultaneous payment attempts
    if (_isPaymentInProgress) {
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'buy_plan_blocked',
          'reason': 'payment_already_in_progress',
          'planId': plan.id,
        }),
        name: 'PaymentFlow',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please wait, payment is already in progress.'),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Check if Razorpay is initialized
    if (!_isRazorpayInitialized) {
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'buy_plan_failed',
          'reason': 'razorpay_not_initialized',
          'planId': plan.id,
        }),
        name: 'PaymentFlow',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment service is not ready. Please restart the app.'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    
    // Set payment in progress flag
    setState(() {
      _isPaymentInProgress = true;
    });
    
    try {
      // Get user data from UserStorage
      final mobileNumber = await UserStorage.getPhone();
      final userEmail = await UserStorage.getEmail();
      final loginData = await UserStorage.getLoginData();
      final userName = loginData['userName'] ?? 'Customer';
      
      if (mobileNumber.isEmpty) {
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'buy_plan_failed',
            'reason': 'mobile_number_not_found',
            'planId': plan.id,
            'planName': plan.planName,
          }),
          name: 'PaymentFlow',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please login again to continue.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      
      // Ensure mobile number is 10 digits without country code
      String cleanMobileNumber = mobileNumber.replaceAll('+91', '').replaceAll(' ', '').trim();
      if (cleanMobileNumber.length > 10) {
        cleanMobileNumber = cleanMobileNumber.substring(cleanMobileNumber.length - 10);
      }
      
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'buy_plan_started',
          'planId': plan.id,
          'planName': plan.planName,
          'amount': plan.pricePerMonth,
          'mobileNumber': cleanMobileNumber,
        }),
        name: 'PaymentFlow',
      );
      
      // Create order using mobile number as userId
      final orderResponse = await PlanApiService.buyPlan(
        planId: plan.id,
        userId: mobileNumber, // Using mobile number as userId
        amount: plan.pricePerMonth,
      );

      final orderCreationTime = DateTime.now().difference(startTime).inMilliseconds;

      if (orderResponse['success'] == true && orderResponse['order'] != null) {
        final order = orderResponse['order'];
        
        // Validate order data
        if (order['id'] == null || order['amount'] == null) {
          developer.log(
            json.encode({
              'timestamp': DateTime.now().toIso8601String(),
              'event': 'order_validation_failed',
              'reason': 'missing_required_fields',
              'order': order,
            }),
            name: 'PaymentFlow',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Invalid order data received. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'order_created_successfully',
            'orderId': order['id'],
            'amount': order['amount'],
            'currency': order['currency'],
            'planId': plan.id,
            'mobileNumber': cleanMobileNumber,
            'orderCreationTime': '${orderCreationTime}ms',
          }),
          name: 'PaymentFlow',
        );
        
        // Store current order details for verification
        _currentOrderId = order['id'];
        _currentPlanId = plan.id;
        _currentUserId = mobileNumber; // Store mobile number
        _currentAmount = plan.pricePerMonth;
        
        // Add billing record as pending
        await Provider.of<BillingProvider>(context, listen: false).addBillingRecord(
          planName: plan.planName,
          planId: plan.id,
          amount: plan.pricePerMonth,
          status: 'Pending',
          paymentId: '',
          orderId: order['id'],
        );
        
        // Start Razorpay payment with the order details
        // Match exactly with website implementation
        var options = <String, dynamic>{
          'key': RazorpayConfig.apiKey,
          'amount': order['amount'],
          'currency': order['currency'] ?? 'INR',
          'name': RazorpayConfig.companyName,
          'description': plan.planName,
          'order_id': order['id'],
          'prefill': <String, dynamic>{
            'name': userName,
            'contact': cleanMobileNumber,
            'email': userEmail.isNotEmpty ? userEmail : 'customer@thenaukrimitra.com'
          },
          'theme': <String, dynamic>{
            'color': RazorpayConfig.brandColor
          },
          'retry': <String, dynamic>{
            'enabled': true,
            'max_count': 3
          },
          'timeout': 600, // 10 minutes timeout for live mode
          'modal': <String, dynamic>{
            'confirm_close': true,
          },
        };
        
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'razorpay_dialog_opening',
            'orderId': order['id'],
            'amount': order['amount'],
            'currency': order['currency'],
            'mobileNumber': cleanMobileNumber,
            'razorpayOptions': {
              'key': options['key'],
              'amount': options['amount'],
              'currency': options['currency'],
              'order_id': options['order_id'],
              'name': options['name'],
              'description': options['description'],
              'prefill': {
                'name': options['prefill']['name'],
                'contact': options['prefill']['contact'],
                'email': options['prefill']['email'],
              }
            }
          }),
          name: 'PaymentFlow',
        );
        
        // Open Razorpay with error handling
        try {
          _razorpay.open(options);
          
          developer.log(
            json.encode({
              'timestamp': DateTime.now().toIso8601String(),
              'event': 'razorpay_dialog_opened_successfully',
              'orderId': order['id'],
            }),
            name: 'PaymentFlow',
          );
        } catch (e, stackTrace) {
          developer.log(
            json.encode({
              'timestamp': DateTime.now().toIso8601String(),
              'event': 'razorpay_dialog_open_failed',
              'orderId': order['id'],
              'error': e.toString(),
              'stackTrace': stackTrace.toString(),
            }),
            name: 'PaymentFlow',
          );
          
          // Update billing record to failed
          await Provider.of<BillingProvider>(context, listen: false).updateBillingRecordStatus(
            orderId: order['id'],
            status: 'Failed',
          );
          
          // Clear current order details
          _clearCurrentOrderDetails();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Unable to open payment screen. Please try again.'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    _buyPlan(plan);
                  },
                ),
              ),
            );
          }
        }
      } else {
        developer.log(
          json.encode({
            'timestamp': DateTime.now().toIso8601String(),
            'event': 'order_creation_failed',
            'planId': plan.id,
            'mobileNumber': mobileNumber,
            'orderCreationTime': '${orderCreationTime}ms',
            'apiResponse': orderResponse,
          }),
          name: 'PaymentFlow',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Unable to process payment. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'buy_plan_exception',
          'planId': plan.id,
          'processingTime': '${processingTime}ms',
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
        }),
        name: 'PaymentFlow',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment service temporarily unavailable. Please try again.'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _buyPlan(plan);
              },
            ),
          ),
        );
      }
    } finally {
      // Always reset payment in progress flag
      if (mounted) {
        setState(() {
          _isPaymentInProgress = false;
        });
      }
      
      developer.log(
        json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'event': 'buy_plan_completed',
          'planId': plan.id,
          'paymentInProgress': false,
        }),
        name: 'PaymentFlow',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          'Plans & Billing',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.subtitle2,
          tabs: const [
            Tab(text: 'Choose Plan'),
            Tab(text: 'Billing History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChoosePlanTab(),
          _buildBillingHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildChoosePlanTab() {
    return Consumer<PlanProvider>(
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
                  'Unable to load plans',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  planProvider.errorMessage,
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => planProvider.fetchPlans(forceRefresh: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (planProvider.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No plans available',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check back later',
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => planProvider.fetchPlans(forceRefresh: true),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the perfect plan for your hiring needs',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ...planProvider.plans.map((plan) => _buildPlanCard(plan)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillingHistoryTab() {
    return Consumer<UnifiedBillingProvider>(
      builder: (context, unifiedBillingProvider, child) {
        return RefreshIndicator(
          onRefresh: () => unifiedBillingProvider.refreshPaymentHistory(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildBillingHistorySection(unifiedBillingProvider),
          ),
        );
      },
    );
  }

  Widget _buildBillingHistorySection(UnifiedBillingProvider unifiedBillingProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Billing History',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterButton('All', unifiedBillingProvider.selectedFilter == 'all', unifiedBillingProvider),
                        _buildFilterButton('Success', unifiedBillingProvider.selectedFilter == 'success', unifiedBillingProvider),
                        _buildFilterButton('Pending', unifiedBillingProvider.selectedFilter == 'pending', unifiedBillingProvider),
                        _buildFilterButton('Failed', unifiedBillingProvider.selectedFilter == 'failed', unifiedBillingProvider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Date & Plan',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Billing history data
          if (unifiedBillingProvider.paymentHistoryLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: BillingHistorySkeleton(),
            )
          else if (unifiedBillingProvider.paymentHistoryError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      unifiedBillingProvider.paymentHistoryError,
                      style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (unifiedBillingProvider.filteredPaymentHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No billing history found',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...unifiedBillingProvider.filteredPaymentHistory.map((history) => _buildPaymentHistoryRow(history)),
          
          // Show results count
          if (!unifiedBillingProvider.paymentHistoryLoading && unifiedBillingProvider.paymentHistoryError.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Showing ${unifiedBillingProvider.filteredPaymentHistory.length} of ${unifiedBillingProvider.paymentHistory.length} results',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected, UnifiedBillingProvider unifiedBillingProvider) {
    return GestureDetector(
      onTap: () => unifiedBillingProvider.setFilter(text.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryRow(PaymentHistory history) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailsScreen(
              orderId: history.orderId,
              initialPayment: history,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.formattedDate,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    history.formattedTime,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Order: ${history.orderId}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  if (history.validityPeriod != 'N/A') ...[
                    const SizedBox(height: 2),
                    Text(
                      'Valid: ${history.validityPeriod}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                history.formattedAmount,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: history.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      history.status,
                      style: AppTextStyles.caption.copyWith(
                        color: history.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistoryRow(BillingHistory history) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.date,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  history.time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  history.planName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (history.expiresOn != 'N/A') ...[
                  const SizedBox(height: 2),
                  Text(
                    'Expires: ${history.expiresOn}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              history.formattedAmount,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: history.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    history.status,
                    style: AppTextStyles.caption.copyWith(
                      color: history.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement contact functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact support functionality coming soon'),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.contact_support_outlined,
                    color: AppColors.primary,
                    size: 18,
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
    return Consumer<UnifiedBillingProvider>(
      builder: (context, unifiedBillingProvider, child) {
        // Check if this plan is currently active based on active plan API
        bool isCurrentPlan = unifiedBillingProvider.hasActivePlan && 
                           unifiedBillingProvider.activePlan?.planName == plan.planName;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: plan.isRecommended 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primaryLight.withOpacity(0.05),
                    ],
                  )
                : isCurrentPlan
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.success.withOpacity(0.1),
                          AppColors.success.withOpacity(0.05),
                        ],
                      )
                    : null,
            color: plan.isRecommended || isCurrentPlan ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: plan.isRecommended 
                ? Border.all(color: AppColors.primary, width: 2)
                : isCurrentPlan
                    ? Border.all(color: AppColors.success, width: 2)
                    : Border.all(color: AppColors.border),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with plan name and badges
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.planName,
                            style: AppTextStyles.h4.copyWith(
                              color: plan.isRecommended 
                                  ? AppColors.primary 
                                  : isCurrentPlan
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        if (isCurrentPlan)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ACTIVE',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isCurrentPlan && plan.isRecommended)
                          const SizedBox(height: 8),
                        if (plan.isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Pricing section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${plan.pricePerMonth}',
                          style: AppTextStyles.h2.copyWith(
                            color: isCurrentPlan ? AppColors.success : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ ${_formatMonths(plan.validityDays)}',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (plan.discountPercent > 0) ...[
                          Text(
                            '₹${plan.originalPrice}',
                            style: AppTextStyles.body2.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${plan.discountPercent.toStringAsFixed(plan.discountPercent % 1 == 0 ? 0 : 2)}% OFF',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (plan.gstPercent > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+ ${plan.gstPercent.toStringAsFixed(0)}% GST extra',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Features section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem(
                      Icons.work_outline,
                      '${plan.credits} Job credits',
                      AppColors.primary,
                    ),
                    if (plan.dbCredits > 0)
                      _buildFeatureItem(
                        Icons.storage_outlined,
                        '${plan.dbCredits} DB unlock credits',
                        AppColors.secondary,
                      ),
                    _buildFeatureItem(
                      Icons.schedule_outlined,
                      'Use these credits in ${plan.validityDays} days',
                      AppColors.secondary,
                    ),
                    _buildFeatureItem(
                      Icons.visibility_outlined,
                      'Job will be active for ${plan.jobActiveDays} days',
                      AppColors.accent,
                    ),
                    if (plan.aiMatching)
                      _buildFeatureItem(
                        Icons.psychology_outlined,
                        'AI driven matching algorithm',
                        AppColors.info,
                      ),
                    if (plan.advancedFilters > 0)
                      _buildFeatureItem(
                        Icons.filter_list_outlined,
                        '${plan.advancedFilters}+ Advanced filters',
                        AppColors.primary,
                      ),
                    if (plan.whatsappLead)
                      _buildFeatureItem(
                        Icons.message_outlined,
                        'WhatsApp & Call based lead management',
                        AppColors.success,
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Buy button or Active status
              Container(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: isCurrentPlan
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Currently Active',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutSummaryScreen(
                                  plan: plan,
                                  onProceedToPay: () => _buyPlan(plan),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan.isRecommended 
                                ? AppColors.primary 
                                : AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: plan.isRecommended ? 8 : 2,
                          ),
                          child: Text(
                            'Buy Plan - ₹${plan.pricePerMonth}',
                            style: AppTextStyles.button,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMonths(int days) {
    if (days >= 30) {
      int months = (days / 30).round();
      return '$months Month${months > 1 ? 's' : ''}';
    }
    return '$days Days';
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body1,
            ),
          ),
        ],
      ),
    );
  }

}