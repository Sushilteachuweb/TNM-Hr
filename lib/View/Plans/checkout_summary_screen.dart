import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/job_plan_model.dart';
import '../../models/checkout_summary_model.dart';
import '../../services/api_routes.dart';
import '../../services/cookie_manager.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  final JobPlan plan;
  final VoidCallback onProceedToPay;

  const CheckoutSummaryScreen({
    super.key,
    required this.plan,
    required this.onProceedToPay,
  });

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  CheckoutSummary? _summary;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCheckoutSummary();
  }

  Future<void> _fetchCheckoutSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final headers = await CookieManager.getHeadersWithCookie();
      final response = await http.get(
        Uri.parse(ApiConfig.checkoutSummary(widget.plan.id)),
        headers: headers,
      );

      developer.log('Checkout summary response: ${response.body}', name: 'CheckoutSummary');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _summary = CheckoutSummary.fromJson(data['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Unable to load checkout details. Please try again.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Unable to load checkout details. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Checkout summary error: $e', name: 'CheckoutSummary');
      setState(() {
        _errorMessage = 'Unable to load checkout details. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.toInt()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout Summary',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchCheckoutSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final summary = _summary!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 20),
                _buildPlanCard(summary),
                const SizedBox(height: 16),
                _buildPriceBreakdown(summary),
                const SizedBox(height: 16),
                _buildSavingsBanner(summary),
                const SizedBox(height: 100), // space for sticky button
              ],
            ),
          ),
        ),
        _buildStickyButton(summary),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Select a plan', true, completed: true),
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.primary,
          ),
        ),
        _buildStep(2, 'Checkout', true, completed: false),
      ],
    );
  }

  Widget _buildStep(int number, String label, bool isActive, {required bool completed}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: completed ? AppColors.success : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(CheckoutSummary summary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.planName,
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valid for ${summary.validityDays} days',
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'RECRUITER',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.work_outline, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.credits} Job Credits',
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Post up to ${summary.credits} jobs within ${summary.validityDays} days',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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

  Widget _buildPriceBreakdown(CheckoutSummary summary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Original price',
            _formatCurrency(summary.originalPrice),
            strikethrough: true,
          ),
          _buildDiscountRow(summary),
          Divider(color: AppColors.border, height: 1),
          _buildPriceRow('Subtotal', _formatCurrency(summary.basePrice)),
          _buildPriceRow(
            'GST (${summary.gstPercent.toStringAsFixed(0)}%)',
            _formatCurrency(summary.gstAmount),
            valueColor: AppColors.textSecondary,
          ),
          Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _formatCurrency(summary.finalPrice),
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {
    bool strikethrough = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.body1.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountRow(CheckoutSummary summary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Text(
                'Plan discount (${summary.discountPercent.toStringAsFixed(2)}% off)',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '-${_formatCurrency(summary.discountAmount)}',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsBanner(CheckoutSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings_outlined, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Text(
            "You're saving ${_formatCurrency(summary.discountAmount)} on this purchase!",
            style: AppTextStyles.body2.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyButton(CheckoutSummary summary) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onProceedToPay();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Pay ${_formatCurrency(summary.finalPrice)} Securely',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 4),
              Text('Encrypted', style: AppTextStyles.caption),
              const SizedBox(width: 12),
              Icon(Icons.verified_outlined, color: AppColors.success, size: 14),
              const SizedBox(width: 4),
              Text('Razorpay secured', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
