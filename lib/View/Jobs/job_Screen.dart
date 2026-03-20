import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../Provider/job_provider.dart';
import '../../services/job_creation_service.dart';
import '../bottomNavBar/bottomNavBar.dart';
import 'Applicants/applicants.dart';
import 'EditJob/edit_job_basic_details_page.dart';
import 'job_details_screen.dart';
import '../../widgets/skeleton_components.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  String selectedTab = "draft";

  @override
  void initState() {
    super.initState();
    // Data is already loaded by AppDataManager, but ensure jobs are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = context.read<JobProvider>();
      if (!jobProvider.hasLoadedOnce) {
        print("📊 Jobs not loaded yet, fetching now...");
        jobProvider.fetchJobs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    
    // Get jobs based on selected tab
    List<dynamic> jobs;
    if (selectedTab == "draft") {
      jobs = jobProvider.getDraftJobs();
    } else {
      jobs = jobProvider.getJobsByStatus(selectedTab);
    }
    
    final jobCounts = jobProvider.jobCounts;
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
          "Jobs",
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: jobProvider.isLoading
                ? const JobListSkeleton()
                : jobProvider.errorMessage.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () => jobProvider.fetchJobs(forceRefresh: true),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
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
                                    jobProvider.errorMessage,
                                    style: AppTextStyles.body1,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      jobProvider.fetchJobs(forceRefresh: true);
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : jobs.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () => jobProvider.fetchJobs(forceRefresh: true),
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.work_off_outlined,
                                        size: 64,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No ${selectedTab} jobs found',
                                        style: AppTextStyles.body1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => jobProvider.fetchJobs(forceRefresh: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: jobs.length,
                              itemBuilder: (context, index) {
                                final job = jobs[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildJobCard(
                                    job: job,
                                    jobId: job['_id'] ?? job['id'] ?? '',
                                    status: job['status'] ?? 'active',
                                    statusColor: _getStatusColor(
                                      job['status'] ?? 'active',
                                    ),
                                    title: job['title'] ?? 'No Title',
                                    description:
                                        job['description'] ?? 'No Description',
                                    salary: job['salaryRange'] != null
                                        ? '₹${job['salaryRange']['min']} - ₹${job['salaryRange']['max']}'
                                        : job['salary'] != null
                                            ? '₹${job['salary']}/mo'
                                            : 'Not specified',
                                    location: job['jobLocation'] ?? job['location'] ?? 'Not specified',
                                    posted: _formatDate(job['createdAt']),
                                    applicants:
                                        job['applicantsCount'] ?? 0,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final jobProvider = context.watch<JobProvider>();
    final jobCounts = jobProvider.jobCounts;
    final draftCount = jobProvider.getDraftJobs().length;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTab("Draft", draftCount.toString()),
          const SizedBox(width: 8),
          _buildTab("Active", jobCounts['active']?.toString() ?? "0"),
          const SizedBox(width: 8),
          _buildTab("Pending", jobCounts['pending']?.toString() ?? "0"),
          const SizedBox(width: 8),
          _buildTab("Closed", jobCounts['closed']?.toString() ?? "0"),
          const SizedBox(width: 8),
          _buildTab("Rejected", jobCounts['rejected']?.toString() ?? "0"),
        ],
      ),
    );
  }

  Widget _buildTab(String text, String count) {
    final isSelected = selectedTab == text.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = text.toLowerCase());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$text\n$count",
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle2.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required Map<String, dynamic> job,
    required String jobId,
    required String status,
    required Color statusColor,
    required String title,
    required String description,
    required String salary,
    required String location,
    required String posted,
    required int applicants,
  }) {
    final rejectionReason = job['rejectionReason'] as String?;
    return InkWell(
      onTap: () async {
        // Navigate to job details screen
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(job: job),
          ),
        );
        if (result == true) {
          context.read<JobProvider>().fetchJobs();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Only show applicants count for active jobs
              if (status.toLowerCase() == 'active')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$applicants",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.currency_rupee,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Text(salary, style: AppTextStyles.body2),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: AppTextStyles.body2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(posted, style: AppTextStyles.caption),
          // Show rejection reason if status is rejected
          if (status.toLowerCase() == 'rejected' && rejectionReason != null && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejection Reason',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rejectionReason,
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              // Show publish button for draft jobs
              if (status.toLowerCase() == 'draft') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPublishDialog(context, jobId, title),
                    icon: const Icon(Icons.publish, size: 18),
                    label: const Text("Publish Job"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196C4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] 
              // Show applicants button only for active jobs
              else if (status.toLowerCase() == 'active') ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Applicants(
                            jobId: jobId,
                            jobTitle: title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text("Applicants"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ]
              // For pending and closed jobs, show spacer to maintain layout
              else ...[
                const Expanded(child: SizedBox()),
                const SizedBox(width: 8),
              ],
              // Show edit button only for draft and rejected jobs
              if (status.toLowerCase() == 'draft' || status.toLowerCase() == 'rejected') ...[
                InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditJobBasicDetailsPage(job: job),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context.read<JobProvider>().fetchJobs(forceRefresh: true);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              InkWell(
                onTap: () => _showDeleteDialog(context, jobId, title),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.warning;
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'closed':
        return AppColors.error;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Recently posted';
    try {
      final DateTime dateTime = DateTime.parse(date.toString());
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays == 0) {
        return 'Posted today';
      } else if (difference.inDays == 1) {
        return 'Posted yesterday';
      } else if (difference.inDays < 7) {
        return 'Posted ${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Posted $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else {
        final months = (difference.inDays / 30).floor();
        return 'Posted $months ${months == 1 ? 'month' : 'months'} ago';
      }
    } catch (e) {
      return 'Recently posted';
    }
  }

  void _showPublishDialog(BuildContext context, String jobId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.publish,
                color: AppColors.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Publish Job', style: AppTextStyles.h4),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to publish "$title"?',
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildPublishInfoRow(
              Icons.check_circle_outline,
              'Check active subscription',
            ),
            const SizedBox(height: 8),
            _buildPublishInfoRow(
              Icons.stars_outlined,
              'Check available credits',
            ),
            const SizedBox(height: 8),
            _buildPublishInfoRow(
              Icons.remove_circle_outline,
              'Deduct 1 credit',
            ),
            const SizedBox(height: 8),
            _buildPublishInfoRow(
              Icons.rocket_launch_outlined,
              'Publish job live',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.subtitle2),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handlePublishJob(context, jobId, title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: Text('Publish Now', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePublishJob(BuildContext context, String jobId, String title) async {
    // Save navigator state before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Publishing job...',
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      // Publish the job
      final result = await JobCreationService.publishDraftJob(
        context: context,
        jobId: jobId,
      );
      
      print("📊 Publish result: $result");
      print("📊 needsPlan: ${result['needsPlan']}");
      print("📊 success: ${result['success']}");
      print("📊 message: ${result['message']}");
      
      // Always remove loading indicator first using saved navigator
      if (navigator.canPop()) {
        navigator.pop();
      }
      
      // Small delay to ensure dialog is dismissed
      await Future.delayed(const Duration(milliseconds: 200));
      
      if (result['success'] == true) {
        // Success - refresh jobs list
        if (context.mounted) {
          context.read<JobProvider>().fetchJobs(forceRefresh: true);
        }
      } else if (result['needsPlan'] == true) {
        // Show plan purchase dialog using root navigator
        print("📊 Showing no plan dialog - context.mounted: ${context.mounted}");
        showDialog(
          context: navigator.context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: AppColors.warning,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Credits Available',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result['message'] ?? 'Please buy a plan to get credits and publish the job',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Purchase a plan to get credits and publish your job',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Later',
                  style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // Navigate to plans screen using root navigator
                  Navigator.of(navigator.context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const BottomNavBar(initialIndex: 2), // Plans tab
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: const Text('Buy Plan'),
              ),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      } else {
        // Show generic error
        print("📊 Showing generic error snackbar");
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to publish job'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Ensure loading dialog is dismissed on error using saved navigator
      if (navigator.canPop()) {
        navigator.pop();
      }
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }


  void _showDeleteDialog(BuildContext context, String jobId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Delete Job', style: AppTextStyles.h4),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.subtitle2),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDeleteJob(context, jobId, title);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteJob(BuildContext context, String jobId, String title) async {
    // Save references before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Deleting job...',
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      final jobProvider = context.read<JobProvider>();
      final success = await jobProvider.deleteJob(jobId);
      
      // Dismiss loading dialog
      if (navigator.canPop()) {
        navigator.pop();
      }
      
      // Small delay to ensure dialog is dismissed
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Job "$title" deleted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text('Unable to delete job. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      // Ensure loading dialog is dismissed on error
      if (navigator.canPop()) {
        navigator.pop();
      }
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
