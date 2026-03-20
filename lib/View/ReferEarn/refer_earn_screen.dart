import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/refer_earn_api_service.dart';
import '../bottomNavBar/bottomNavBar.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _redeemController = TextEditingController();
  final GlobalKey<FormState> _redeemFormKey = GlobalKey<FormState>();
  
  String? _generatedCode;
  bool _isGenerating = false;
  bool _isRedeeming = false;
  bool _isLoadingStats = true;
  
  // User stats from API
  Map<String, dynamic> _userStats = {
    'referralCode': null,
    'hasGeneratedCode': false,
    'totalReferrals': 0,
    'successfulReferrals': 0,
    'availableCredits': 0,
    'totalCredits': 0,
    'isRedeemed': false,
    'usableForJobPosting': false,
    'subscriptionStatus': 'Inactive',
    'expiryDate': null,
    'referralHistory': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReferralStats();
  }

  Future<void> _loadReferralStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await ReferEarnApiService.getReferralStats();
      setState(() {
        _userStats = stats;
        // If user already has a generated code, show it
        if (stats['hasGeneratedCode'] == true && stats['referralCode'] != null) {
          _generatedCode = stats['referralCode'];
        }
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading referral stats: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _redeemController.dispose();
    super.dispose();
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
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavBar(initialIndex: 4), // Profile tab
              ),
            );
          },
        ),
        title: Text(
          "Refer & Earn",
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.subtitle2,
          tabs: const [
            Tab(text: "Generate Code"),
            Tab(text: "Redeem Code"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateTab(),
          _buildRedeemTab(),
        ],
      ),
    );
  }

  Widget _buildGenerateTab() {
    return RefreshIndicator(
      onRefresh: _loadReferralStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildGenerateSection(),
            const SizedBox(height: 24),
            _buildHowItWorksSection(),
            const SizedBox(height: 24),
            _buildBenefitsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRedeemTab() {
    return RefreshIndicator(
      onRefresh: _loadReferralStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRedeemSection(),
            const SizedBox(height: 24),
            _buildRedeemBenefitsSection(),
            const SizedBox(height: 24),
            _buildTermsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (_isLoadingStats) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.buttonShadow],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your Database Access Credits",
                  style: AppTextStyles.h4.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Referrals",
                  "${_userStats['totalReferrals'] ?? 0}",
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Successful",
                  "${_userStats['successfulReferrals'] ?? 0}",
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Available Credits",
                  "${_userStats['availableCredits'] ?? 0}",
                  Icons.stars_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Total Credits",
                  "${_userStats['totalCredits'] ?? 0}",
                  Icons.workspace_premium_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Generate Referral Code",
                      style: AppTextStyles.h4,
                    ),
                    Text(
                      "Share with friends and 10 earn database access credits",
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_generatedCode != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Your Referral Code",
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _generatedCode!,
                            style: AppTextStyles.h4.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyToClipboard(_generatedCode!),
                          icon: Icon(Icons.copy, color: AppColors.primary),
                          tooltip: "Copy Code",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareReferralCode(_generatedCode!),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text("Share Code"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generateNewCode,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("New Code"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textSecondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReferralCode,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.card_giftcard, size: 18),
                label: Text(_isGenerating ? "Generating..." : "Generate My Code"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRedeemSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Form(
        key: _redeemFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.redeem,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Redeem Referral Code",
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        "Enter a friend's referral code to get database access credits",
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _redeemController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "Enter referral code (e.g., REF123ABC)",
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textHint,
                ),
                prefixIcon: Icon(Icons.confirmation_number, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a referral code';
                }
                if (value.trim().length < 6) {
                  return 'Referral code must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRedeeming ? null : _redeemReferralCode,
                icon: _isRedeeming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.redeem, size: 18),
                label: Text(_isRedeeming ? "Redeeming..." : "Redeem Code"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("How It Works", style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildStepItem(
            1,
            "Generate Code",
            "Create your unique referral code",
            Icons.card_giftcard,
          ),
          _buildStepItem(
            2,
            "Share with Friends",
            "Send your code to friends and colleagues",
            Icons.share,
          ),
          _buildStepItem(
            3,
            "They Sign Up",
            "Friends register using your referral code",
            Icons.person_add,
          ),
          _buildStepItem(
            4,
            "Earn Credits",
            "Get database access credits to view candidate profiles",
            Icons.stars,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    int step,
    String title,
    String description,
    IconData icon, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  step.toString(),
                  style: AppTextStyles.subtitle2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.subtitle2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Referral Benefits", style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildBenefitItem(
            Icons.stars,
            "Database Access Credits",
            "Get free credits to view and download candidate profiles",
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemStatsCard() {
    if (_isLoadingStats) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.buttonShadow],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Referral Credits Earned",
                  style: AppTextStyles.h4.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Credits",
                  "${_userStats['totalCredits'] ?? 0}",
                  Icons.stars_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Successful",
                  "${_userStats['successfulReferrals'] ?? 0}",
                  Icons.verified_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Redeem Benefits", style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildBenefitItem(
            Icons.stars,
            "Database Access Credits",
            "Get 5 credits to unlock and view candidate contact details and profiles",
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text("Terms & Conditions", style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: 16),
          _buildTermItem("• Each referral code can only be used once"),
          _buildTermItem("• Database access credits are credited within 24-48 hours"),
          _buildTermItem("• You cannot use your own referral code"),
          _buildTermItem("• Referred user must complete profile setup"),
          _buildTermItem("• Credits can be used to view candidate profiles and contact details"),
          _buildTermItem("• Credits are separate from job posting credits"),
          _buildTermItem("• Terms and conditions may change without notice"),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  // Methods for functionality
  Future<void> _generateReferralCode() async {
    // If user already has a code, just show it
    if (_userStats['hasGeneratedCode'] == true && _userStats['referralCode'] != null) {
      setState(() {
        _generatedCode = _userStats['referralCode'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Your existing referral code is displayed'),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final code = await ReferEarnApiService.generateReferralCode();
      setState(() {
        _generatedCode = code;
        _isGenerating = false;
      });

      // Reload stats after generating code
      await _loadReferralStats();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Referral code generated successfully!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _showErrorSnackBar('Failed to generate referral code. Please try again.');
    }
  }

  Future<void> _generateNewCode() async {
    setState(() {
      _generatedCode = null;
    });
    await _generateReferralCode();
  }

  Future<void> _redeemReferralCode() async {
    if (_redeemFormKey.currentState!.validate()) {
      setState(() {
        _isRedeeming = true;
      });

      try {
        final result = await ReferEarnApiService.redeemReferralCode(
          _redeemController.text.trim().toUpperCase(),
        );

        setState(() {
          _isRedeeming = false;
        });

        if (result['success']) {
          // Reload stats to show updated credits
          await _loadReferralStats();
          
          final credits = result['credits'];
          final message = credits != null 
              ? 'You received $credits database access credits to view candidate profiles!'
              : result['message'] ?? 'Database access credits have been added to your account.';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Referral code redeemed successfully!'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          _redeemController.clear();
        } else {
          _showErrorSnackBar(result['message'] ?? 'Invalid referral code.');
        }
      } catch (e) {
        setState(() {
          _isRedeeming = false;
        });
        _showErrorSnackBar('Failed to redeem code. Please try again.');
      }
    }
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Referral code copied: $code'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _shareReferralCode(String code) {
    try {
      final message = '''🎉 Join Naukri Mitra and get FREE database access credits! 🎉

Use my referral code: $code

Download the app and start hiring today!
Get credits to view candidate profiles and contact details.

#NaukriMitra #Hiring #Referral''';

      Share.share(
        message,
        subject: 'Join Naukri Mitra - Referral Code: $code',
      ).then((_) {
        print('Share completed successfully');
      }).catchError((error) {
        print('Share error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to share. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      });
    } catch (e) {
      print('Share exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share referral code'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}