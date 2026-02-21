import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../Provider/job_provider.dart';
import 'Applicants/applicants.dart';
import 'edit_job_screen.dart';
import '../../widgets/skeleton_components.dart';

class JobDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading time for demonstration
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Update applicant count for this job
        _updateApplicantCount();
      }
    });
  }

  /// Update applicant count for this specific job
  void _updateApplicantCount() {
    final jobId = widget.job['_id']?.toString() ?? widget.job['id']?.toString();
    if (jobId != null && jobId.isNotEmpty) {
      context.read<JobProvider>().updateJobApplicantCount(jobId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Job Details',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const JobDetailsSkeleton(),
      );
    }

    // Extract all job data with fallbacks
    final jobId = widget.job['_id']?.toString() ?? '';
    final title = widget.job['title']?.toString() ?? 'No Title';
    final companyName = widget.job['companyName']?.toString() ?? 'Company';
    final description = widget.job['jobDescription']?.toString() ?? widget.job['description']?.toString() ?? 'No description';
    final status = widget.job['status']?.toString() ?? 'active';
    final applicantsCount = widget.job['applicantsCount'] ?? 0;
    
    // Salary information
    final salaryType = widget.job['salaryType']?.toString() ?? 'Fixed Only';
    final salary = widget.job['salaryRange'] != null
        ? '₹${widget.job['salaryRange']['min']} - ₹${widget.job['salaryRange']['max']}'
        : widget.job['salary']?.toString() ?? 'Not specified';
    
    // Location details
    final jobLocation = widget.job['jobLocation']?.toString() ?? widget.job['location']?.toString() ?? 'Not specified';
    final workLocation = widget.job['workLocation']?.toString() ?? 'Not specified';
    final preferredLocation = widget.job['preferredLocation']?.toString() ?? '';
    final officeAddress = widget.job['officeAddress']?.toString() ?? '';
    final floorDetails = widget.job['floorDetails']?.toString() ?? '';
    
    // Job details
    final jobCategory = widget.job['jobCategory']?.toString() ?? 'Not specified';
    final jobType = widget.job['jobType']?.toString() ?? 'Not specified';
    
    // Requirements
    final experience = widget.job['totalExperience']?.toString() ?? 'Not specified';
    final education = widget.job['minimumEducation']?.toString() ?? 'Not specified';
    final englishLevel = widget.job['englishLevel']?.toString() ?? 'Not specified';
    final openings = widget.job['openings'] ?? 0;
    final gender = widget.job['gender']?.toString() ?? 'Any';
    final ageRange = widget.job['ageRange'];
    final minAge = ageRange != null ? ageRange['min'] ?? 18 : 18;
    final maxAge = ageRange != null ? ageRange['max'] ?? 50 : 50;
    
    // Employment details
    final workingDays = widget.job['workingDays']?.toString() ?? 'Not specified';
    final jobTiming = widget.job['jobTiming']?.toString() ?? 'Not specified';
    final isWalkInInterview = widget.job['isWalkInInterview'] ?? false;
    final communicationPreference = widget.job['communicationPreference']?.toString() ?? 'Not specified';
    
    // Additional info
    final hrPhone = widget.job['hrPhone']?.toString() ?? '';
    final createdAt = widget.job['createdAt'] != null 
        ? DateTime.tryParse(widget.job['createdAt'].toString()) 
        : null;
    final updatedAt = widget.job['updatedAt'] != null 
        ? DateTime.tryParse(widget.job['updatedAt'].toString()) 
        : null;
    
    // Handle perks - can be List or String
    final perks = widget.job['additionalPerks'] is List 
        ? widget.job['additionalPerks'] as List
        : (widget.job['additionalPerks'] != null ? [widget.job['additionalPerks']] : []);
    
    // Handle documents - can be List or String
    final documents = widget.job['documents'] is List
        ? widget.job['documents'] as List
        : widget.job['documentsRequired'] is List
            ? widget.job['documentsRequired'] as List
            : (widget.job['documents'] != null 
                ? [widget.job['documents']] 
                : widget.job['documentsRequired'] != null 
                    ? [widget.job['documentsRequired']] 
                    : []);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job Details',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.edit_outlined, color: AppColors.primary),
          //   onPressed: () async {
          //     final result = await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => EditJobScreen(job: widget.job),
          //       ),
          //     );
          //     if (result == true && context.mounted) {
          //       Navigator.pop(context, true);
          //     }
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context, title, companyName, status, applicantsCount, createdAt, updatedAt),
            const SizedBox(height: 20),
            
            // Job Overview Card
            _buildJobOverviewCard(jobCategory, jobType, salary, salaryType),
            const SizedBox(height: 20),
            
            // Location Details Card
            _buildLocationCard(jobLocation, workLocation, preferredLocation, officeAddress, floorDetails),
            const SizedBox(height: 20),
            
            // Job Description Card
            _buildDescriptionCard(description),
            const SizedBox(height: 20),
            
            // Requirements Card
            _buildRequirementsCard(experience, education, englishLevel, gender, minAge, maxAge, openings),
            const SizedBox(height: 20),
            
            // Employment Details Card
            _buildEmploymentCard(workingDays, jobTiming, isWalkInInterview, communicationPreference),
            
            // Additional Perks Card
            if (perks.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildPerksCard(perks),
            ],
            
            // Documents Required Card
            if (documents.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildDocumentsCard(documents),
            ],
            
            // Contact Information Card
            if (hrPhone.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildContactCard(hrPhone, communicationPreference),
            ],
            
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, jobId, title),
    );
  }

  // Header Card with job title, company, status, and timestamps
  Widget _buildHeaderCard(BuildContext context, String title, String companyName, 
      String status, int applicantsCount, DateTime? createdAt, DateTime? updatedAt) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        companyName,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$applicantsCount Applicants',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (createdAt != null || updatedAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (createdAt != null) ...[
                    Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Posted ${_formatDate(createdAt)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (updatedAt != null && createdAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.update, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Updated ${_formatDate(updatedAt)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Job Overview Card
  Widget _buildJobOverviewCard(String jobCategory, String jobType, String salary, String salaryType) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Overview',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.category_outlined, 'Category', jobCategory),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.work_outline, 'Job Type', jobType),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.currency_rupee, 'Salary', salary),
            if (salaryType != 'Fixed Only') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  'Type: $salaryType',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Location Details Card
  Widget _buildLocationCard(String jobLocation, String workLocation, String preferredLocation, 
      String officeAddress, String floorDetails) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on_outlined, 'Job Location', jobLocation),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.business_outlined, 'Work Type', workLocation),
            if (preferredLocation.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.location_city_outlined, 'Preferred Location', preferredLocation),
            ],
            if (officeAddress.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.home_work_outlined, 'Office Address', officeAddress),
            ],
            if (floorDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.apartment_outlined, 'Floor Details', floorDetails),
            ],
          ],
        ),
      ),
    );
  }

  // Job Description Card
  Widget _buildDescriptionCard(String description) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Description',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                description,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Requirements Card
  Widget _buildRequirementsCard(String experience, String education, String englishLevel, 
      String gender, int minAge, int maxAge, int openings) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requirements',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.work_history_outlined, 'Experience', experience),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.school_outlined, 'Education', education),
            if (englishLevel != 'Not specified') ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.language_outlined, 'English Level', englishLevel),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(Icons.people_outline, 'Gender', gender),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.cake_outlined, 'Age Range', '$minAge - $maxAge years'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.group_add_outlined, 'Openings', '$openings positions'),
          ],
        ),
      ),
    );
  }

  // Employment Details Card
  Widget _buildEmploymentCard(String workingDays, String jobTiming, bool isWalkInInterview, String communicationPreference) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employment Details',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.calendar_today_outlined, 'Working Days', workingDays),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time_outlined, 'Job Timing', jobTiming),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.meeting_room_outlined, 'Interview Type', 
                isWalkInInterview ? 'Walk-in Interview' : 'Scheduled Interview'),
            if (communicationPreference != 'Not specified') ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.contact_phone_outlined, 'Communication', communicationPreference),
            ],
          ],
        ),
      ),
    );
  }

  // Additional Perks Card
  Widget _buildPerksCard(List perks) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Perks',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: perks.map((perk) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, 
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      perk.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Documents Required Card
  Widget _buildDocumentsCard(List documents) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents Required',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...documents.map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, 
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doc.toString(),
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // Contact Information Card
  Widget _buildContactCard(String hrPhone, String communicationPreference) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.phone_outlined, 'HR Phone', hrPhone),
            if (communicationPreference != 'Not specified') ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.chat_outlined, 'Preferred Contact', communicationPreference),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Status badge widget
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'active':
        badgeColor = Colors.green;
        statusText = 'Active';
        break;
      case 'pending':
        badgeColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'closed':
        badgeColor = Colors.red;
        statusText = 'Closed';
        break;
      default:
        badgeColor = Colors.grey;
        statusText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.caption.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildBottomBar(BuildContext context, String jobId, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.buttonShadow],
              ),
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
                icon: const Icon(Icons.people_outline, size: 20, color: Colors.white,),
                label: Text(
                  'View Applicants',
                  style: AppTextStyles.button.copyWith(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}