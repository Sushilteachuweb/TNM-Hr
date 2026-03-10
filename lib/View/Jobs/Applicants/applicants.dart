import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/applicant_provider.dart';
import '../../../Provider/job_provider.dart';
import '../../../widgets/skeleton_loading.dart';

class Applicants extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const Applicants({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<Applicants> createState() => _ApplicantsState();
}

class _ApplicantsState extends State<Applicants> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicantProvider>().fetchApplicants(widget.jobId);
      // Also update the job's applicant count in the job provider
      context.read<JobProvider>().updateJobApplicantCount(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicantProvider = context.watch<ApplicantProvider>();
    final applicants = selectedTab == 0
        ? applicantProvider.getNonContactedApplicants()
        : applicantProvider.getContactedApplicants();
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Applicants",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.jobTitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTabButton(
                "Applicants ${applicantProvider.applicantsCount - applicantProvider.contactedCount}",
                0,
              ),
              const SizedBox(width: 8),
              _buildTabButton(
                "Contacted ${applicantProvider.contactedCount}",
                1,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of Cards
          Expanded(
            child: applicantProvider.isLoading
                ? SkeletonLoading(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [AppColors.cardShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 120,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 80,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 180,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : applicantProvider.errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Unable to Load Applicants',
                                style: AppTextStyles.h4.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                applicantProvider.errorMessage,
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      applicantProvider
                                          .fetchApplicants(widget.jobId);
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.arrow_back, size: 18),
                                    label: const Text('Go Back'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      side: BorderSide(color: AppColors.border),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : applicants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  selectedTab == 0
                                      ? 'No applicants yet'
                                      : 'No contacted applicants',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => applicantProvider
                                .fetchApplicants(widget.jobId),
                            child: ListView.builder(
                              itemCount: applicants.length,
                              itemBuilder: (context, index) {
                                return _buildApplicantCard(applicants[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> applicant) {
    final applicantId = applicant['_id'] ?? applicant['id'] ?? '';
    final applicantProvider = context.read<ApplicantProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                backgroundImage: applicant['image'] != null && applicant['image'].toString().isNotEmpty
                    ? NetworkImage('https://api.thenaukrimitra.com/uploads/${applicant['image']}')
                    : null,
                child: applicant['image'] == null || applicant['image'].toString().isEmpty
                    ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                    : null,
                onBackgroundImageError: applicant['image'] != null
                    ? (exception, stackTrace) {
                        print('Error loading image: $exception');
                      }
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant['fullName'] ?? applicant['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailText(
                            Icons.account_balance_wallet_outlined,
                            applicant['currentSalary']?.toString() ?? 
                            applicant['expectedSalary']?.toString() ?? 
                            applicant['salary']?.toString() ?? 
                            'Not specified',
                            AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailText(
                            Icons.school_outlined,
                            applicant['education'] ?? 'Not specified',
                            AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailText(
                            Icons.work_outline,
                            '${applicant['totalExperience'] ?? applicant['experience'] ?? '0'} yrs',
                            AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (applicant['skills'] != null && applicant['skills'].toString().isNotEmpty)
                      _buildInfoRow(
                        'Skills',
                        applicant['skills'] is List
                            ? (applicant['skills'] as List).where((s) => s != null && s.toString().isNotEmpty).join(', ')
                            : applicant['skills'].toString(),
                      ),
                    if (applicant['skills'] != null && applicant['skills'].toString().isNotEmpty) 
                      const SizedBox(height: 8),
                    if ((applicant['userLocation'] ?? applicant['city'])?.toString().isNotEmpty == true)
                      _buildInfoRow('Location', applicant['userLocation'] ?? applicant['city'] ?? 'Not specified'),
                    if ((applicant['userLocation'] ?? applicant['city'])?.toString().isNotEmpty == true) 
                      const SizedBox(height: 8),
                    if (applicant['email'] != null && applicant['email'].toString().isNotEmpty)
                      _buildInfoRow('Email', applicant['email'] ?? 'Not specified'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showNumber(applicant['phone'] ?? 'N/A');
                    applicantProvider.markAsContacted(applicantId);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.phone_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Show Number',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _messageApplicant(applicant['phone'] ?? '');
                    applicantProvider.markAsContacted(applicantId);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.message_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'WhatsApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Commented out Invite for Interview button as requested
          // InkWell(
          //   onTap: () {
          //     _inviteForInterview(applicant['fullName'] ?? 'Applicant');
          //     applicantProvider.markAsContacted(applicantId);
          //   },
          //   borderRadius: BorderRadius.circular(16),
          //   child: Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(vertical: 14),
          //     decoration: BoxDecoration(
          //       gradient: const LinearGradient(
          //         colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //       ),
          //       borderRadius: BorderRadius.circular(16),
          //       boxShadow: [
          //         BoxShadow(
          //           color: const Color(0xFF6366F1).withOpacity(0.4),
          //           blurRadius: 12,
          //           spreadRadius: 1,
          //           offset: const Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: const Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.event_available_rounded,
          //           size: 20,
          //           color: Colors.white,
          //         ),
          //         SizedBox(width: 8),
          //         Text(
          //           'Invite for Interview',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.w600,
          //             fontSize: 14,
          //             letterSpacing: 0.5,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 12),
          // Removed "Remove" button as requested
          // Center(
          //   child: InkWell(
          //     onTap: () => _removeApplicant(applicantId),
          //     borderRadius: BorderRadius.circular(8),
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 6,
          //       ),
          //       child: Text(
          //         'Remove',
          //         style: TextStyle(
          //           color: AppColors.error,
          //           fontSize: 12,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDetailText(IconData icon, String text, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // Commented out as Remove button functionality is no longer needed
  // void _removeApplicant(String applicantId) {
  //   context.read<ApplicantProvider>().removeApplicant(applicantId);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text("Applicant removed"),
  //       backgroundColor: AppColors.success,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  void _showNumber(String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Phone Number"),
        content: Text(phone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _messageApplicant(String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Phone number not available"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Generate auto-message with job title
    String message = 'Hi! I am contacting from NaukriMitra HR App regarding the job "${widget.jobTitle}". Could you please provide more details?';
    
    // URL encode the message (spaces become %20)
    String encodedMessage = Uri.encodeComponent(message);
    
    // Create WhatsApp URL with pre-filled message
    String url = 'https://wa.me/$phone?text=$encodedMessage';
    Uri whatsappUri = Uri.parse(url);

    // Logging for debugging
    print('Generated WhatsApp Message: $message');
    print('Generated WhatsApp URL: $url');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("WhatsApp is not installed on your device"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Commented out as Invite for Interview button functionality is no longer needed
  // void _inviteForInterview(String name) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("Interview invitation sent to $name!"),
  //       backgroundColor: AppColors.success,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }
}
