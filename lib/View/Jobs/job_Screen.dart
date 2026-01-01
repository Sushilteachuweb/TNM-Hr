import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../Provider/job_provider.dart';
import '../bottomNavBar/bottomNavBar.dart';
import 'Applicants/applicants.dart';
import 'create_job_screen.dart';
import 'edit_job_screen.dart';
import 'job_details_screen.dart';
import '../../widgets/skeleton_components.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  String selectedTab = "active";

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
    final jobs = jobProvider.getJobsByStatus(selectedTab);
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
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab("Active", jobCounts['active']?.toString() ?? "0"),
          _buildTab("Pending", jobCounts['pending']?.toString() ?? "0"),
          _buildTab("Closed", jobCounts['closed']?.toString() ?? "0"),
        ],
      ),
    );
  }

  Widget _buildTab(String text, String count) {
    final isSelected = selectedTab == text.toLowerCase();
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = text.toLowerCase());
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : Colors.transparent,
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
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
              Text(location, style: AppTextStyles.body2),
            ],
          ),
          const SizedBox(height: 6),
          Text(posted, style: AppTextStyles.caption),
          const SizedBox(height: 20),
          Row(
            children: [
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
                  label: Text("Applicants"),
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
              // InkWell(
              //   onTap: () async {
              //     final result = await Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => EditJobScreen(
              //           job: {
              //             '_id': jobId,
              //             'title': title,
              //             'description': description,
              //             'salary': int.tryParse(
              //               salary.replaceAll(RegExp(r'[^0-9]'), ''),
              //             ),
              //             'location': location,
              //             'status': status,
              //           },
              //         ),
              //       ),
              //     );
              //     if (result == true && context.mounted) {
              //       context.read<JobProvider>().fetchJobs();
              //     }
              //   },
              //   borderRadius: BorderRadius.circular(12),
              //   child: Container(
              //     padding: const EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: AppColors.surfaceLight,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Icon(
              //       Icons.edit_outlined,
              //       color: AppColors.primary,
              //       size: 20,
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 8),
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
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'closed':
        return AppColors.error;
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

  void _showDeleteDialog(BuildContext context, String jobId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Job', style: AppTextStyles.h4),
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
              final jobProvider = context.read<JobProvider>();
              final success = await jobProvider.deleteJob(jobId);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Job deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Unable to delete job. Please try again.'),
                    backgroundColor: AppColors.error,
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: Colors.white,
                      onPressed: () {
                        // Retry delete
                      },
                    ),
                  ),
                );
              }
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
}
