import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naukri_hr_app/View/Home/CreateNewJob/JobBasicDetailsPage.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../Provider/job_provider.dart';
import '../../Provider/user_provider.dart';
import '../../Provider/credit_provider.dart';
import '../../Provider/unified_billing_provider.dart';
import '../Users/browse_users_screen.dart';
import '../Jobs/job_details_screen.dart';
import '../Helps/help_screen.dart';
import '../../widgets/skeleton_components.dart';
import '../../services/app_data_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _appliedCandidatesCount = 0;
  bool _loadingCandidatesCount = false;
  bool _hasLoadedCandidatesCount = false; // Add caching for candidates count
  bool _forceShowContent = false; // Fallback to show content after timeout

  @override
  void initState() {
    super.initState();
    // Data is already loaded by AppDataManager, just load candidates count if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedCandidatesCount) {
        _loadAppliedCandidatesCount();
      }
      // Add a timeout fallback to prevent infinite skeleton loading
      _startSkeletonTimeout();
    });
  }

  /// Fallback mechanism to show content after 10 seconds even if providers haven't loaded
  void _startSkeletonTimeout() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        final jobProvider = context.read<JobProvider>();
        final creditProvider = context.read<CreditProvider>();
        final unifiedBillingProvider = context.read<UnifiedBillingProvider>();
        
        // If still showing skeleton after 10 seconds, force show content
        if (!jobProvider.hasLoadedOnce || !creditProvider.hasLoadedOnce || !unifiedBillingProvider.hasLoadedOnce) {
          print("⚠️ Skeleton timeout reached - forcing content display");
          setState(() {
            _forceShowContent = true;
          });
        }
      }
    });
  }

  Future<void> _loadInitialData() async {
    await context.read<JobProvider>().fetchJobs();
    await context.read<UserProvider>().fetchUsers();
    await context.read<CreditProvider>().calculateAvailableCredits();
    // Load applied candidates count after jobs are fetched - only if not already loaded
    if (!_hasLoadedCandidatesCount) {
      await _loadAppliedCandidatesCount();
    }
  }

  Future<void> _loadAppliedCandidatesCount() async {
    if (!mounted) return;

    setState(() {
      _loadingCandidatesCount = true;
    });

    try {
      final jobProvider = context.read<JobProvider>();
      final count = await jobProvider.getAppliedCandidatesCount();

      if (mounted) {
        setState(() {
          _appliedCandidatesCount = count;
          _loadingCandidatesCount = false;
          _hasLoadedCandidatesCount = true; // Mark as loaded
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appliedCandidatesCount = 0;
          _loadingCandidatesCount = false;
          _hasLoadedCandidatesCount = true; // Mark as loaded even on error
        });
      }
    }
  }

  Future<void> _refreshData() async {
    // Use AppDataManager for coordinated refresh
    await AppDataManager.refreshAllData(context);
    // Always refresh candidates count on manual refresh
    await _loadAppliedCandidatesCount();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final creditProvider = context.watch<CreditProvider>();
    final unifiedBillingProvider = context.watch<UnifiedBillingProvider>();
    
    // Show skeleton only if data hasn't been loaded yet AND we're loading candidates count for the first time
    // BUT allow force showing content after timeout
    bool shouldShowSkeleton = !_forceShowContent && 
                              ((!jobProvider.hasLoadedOnce || !creditProvider.hasLoadedOnce || !unifiedBillingProvider.hasLoadedOnce) || 
                              (_loadingCandidatesCount && !_hasLoadedCandidatesCount));
    
    if (shouldShowSkeleton) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const SafeArea(
          child: HomeScreenSkeleton(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildWelcomeCard(),
                const SizedBox(height: 18),
                _buildStatsGrid(),
                const SizedBox(height: 18),
                // _buildBrowseUsersButton(),
                // const SizedBox(height: 18),
                _buildJobsSection(context),
                const SizedBox(height: 18),
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseUsersButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BrowseUsersScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4ECDC4),
              Color(0xFF44A08D),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF4ECDC4).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.people_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse Database',
                    style: AppTextStyles.subtitle1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Search and filter candidates by skills, location & experience',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SizedBox(
      width: double.infinity,
      child: _buildActionCard(
        icon: Icons.chat_bubble_outline_rounded,
        title: "Chat With Us",
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF45B7D1), Color(0xFF3A9BC1)],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpScreen(),
            ),
          );
        },
      ),
    );
    // return Row(
    //   children: [
    //     Expanded(
    //       child: _buildActionCard(
    //         icon: Icons.chat_bubble_outline_rounded,
    //         title: "Chat With Us",
    //         gradient: LinearGradient(
    //           begin: Alignment.topLeft,
    //           end: Alignment.bottomRight,
    //           colors: [Color(0xFF45B7D1), Color(0xFF3A9BC1)],
    //         ),
    //         onTap: () {},
    //       ),
    //     ),
    //     const SizedBox(width: 16),
    //     Expanded(
    //       child: _buildActionCard(
    //         icon: Icons.campaign_rounded,
    //         title: "Refer Now",
    //         gradient: LinearGradient(
    //           begin: Alignment.topLeft,
    //           end: Alignment.bottomRight,
    //           colors: [Color(0xFF96CEB4), Color(0xFF85C1A3)],
    //         ),
    //         subtitle: "On 1 Refer Download = 10 Credits",
    //         onTap: () {},
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Gradient gradient,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Manage your hiring",
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Color(0xFF5B73E8), Color(0xFF4C63D2)],
        //     ),
        //     borderRadius: BorderRadius.circular(20),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Color(0xFF5B73E8).withOpacity(0.25),
        //         blurRadius: 10,
        //         offset: const Offset(0, 4),
        //         spreadRadius: 0,
        //       ),
        //     ],
        //   ),
        //   child: Row(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(3),
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //           shape: BoxShape.circle,
        //         ),
        //         child: Icon(Icons.circle, color: Colors.amber, size: 10),
        //       ),
        //       const SizedBox(width: 6),
        //       Text(
        //         "100+",
        //         style: AppTextStyles.subtitle2.copyWith(
        //           color: Colors.white,
        //           fontWeight: FontWeight.w700,
        //           fontSize: 13,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5B73E8),
            Color(0xFF4C63D2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF5B73E8).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back!",
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "TNM Recruiter",
                  style: AppTextStyles.subtitle2.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JobBasicDetailsPage()),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text("Post New Job"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF4C63D2),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.business_center_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final jobProvider = context.watch<JobProvider>();
    final unifiedBillingProvider = context.watch<UnifiedBillingProvider>();
    final jobCounts = jobProvider.jobCounts;

    final activeJobs = jobCounts['active'] ?? 0;
    final totalJobs = jobProvider.jobs.length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.0,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: "Active Jobs",
          value: activeJobs.toString(),
          icon: Icons.work_outline_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFF5B73E8), Color(0xFF4C63D2)],
          ),
        ),
        _buildStatCard(
          title: "Total Jobs",
          value: totalJobs.toString(),
          icon: Icons.folder_outlined,
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
          ),
        ),
        _buildStatCard(
          title: "Candidates",
          value: _loadingCandidatesCount ? "..." : _appliedCandidatesCount.toString(),
          icon: Icons.people_outline_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          ),
        ),
        _buildStatCard(
          title: "Credits",
          value: unifiedBillingProvider.isLoading ? "..." : unifiedBillingProvider.remainingCredits.toString(),
          icon: Icons.account_balance_wallet_outlined,
          gradient: LinearGradient(
            colors: [Color(0xFF45B7D1), Color(0xFF3A9BC1)],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white.withOpacity(0.8),
                  size: 10,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJobsSection(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        // Get all jobs and sort by creation date (most recent first)
        final allJobs = List<dynamic>.from(jobProvider.jobs);
        allJobs.sort((a, b) {
          try {
            final dateA = DateTime.parse(a['createdAt'] ?? '');
            final dateB = DateTime.parse(b['createdAt'] ?? '');
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });

        // Get the most recent jobs (limit to 3 for home screen)
        final recentJobs = allJobs.take(3).toList();

        return Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text("Recent Jobs", style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: 16),
            if (jobProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (jobProvider.errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        jobProvider.errorMessage,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              )
            else if (recentJobs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_off_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "No jobs created yet",
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Create your first job to get started",
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentJobs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final job = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 12),
                      _buildJobCard(
                        job: job,
                      ),
                    ],
                  );
                }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildJobCard({
    required Map<String, dynamic> job,
  }) {
    // Extract job data with fallbacks
    final title = job['title'] ?? 'Untitled Job';
    final salaryRange = job['salaryRange'] as Map<String, dynamic>?;
    final minSalary = salaryRange?['min'] ?? 0;
    final maxSalary = salaryRange?['max'] ?? 0;
    final salary = minSalary > 0 && maxSalary > 0
        ? "₹${_formatSalary(minSalary)} - ₹${_formatSalary(maxSalary)}/mo"
        : "Salary not specified";

    final location = job['jobLocation'] ?? job['workLocation'] ?? 'Location not specified';
    final status = job['status'] ?? 'pending';
    final applicantsCount = job['applicantsCount'] ?? 0;

    // Calculate days ago from createdAt
    final createdAt = job['createdAt'];
    String postedTime = 'Recently posted';
    if (createdAt != null) {
      try {
        final createdDate = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(createdDate).inDays;
        if (difference == 0) {
          postedTime = 'Today';
        } else if (difference == 1) {
          postedTime = '1 day ago';
        } else {
          postedTime = '$difference days ago';
        }
      } catch (e) {
        postedTime = 'Recently posted';
      }
    }

    // Status color and text
    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = AppColors.success;
        statusBgColor = AppColors.success.withOpacity(0.1);
        statusText = 'Active';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        statusText = 'Pending';
        break;
      case 'closed':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        statusText = 'Closed';
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
        statusText = 'Unknown';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$applicantsCount",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    salary,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    postedTime,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSalary(int amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(amount % 100000 == 0 ? 0 : 1)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K";
    } else {
      return amount.toString();
    }
  }
}