import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/job_provider.dart';
import '../models/job_plan_model.dart';
import '../core/app_colors.dart';
import '../utils/job_error_helper.dart';

class JobCreationService {
  /// Creates a job as draft (no credit deduction)
  /// Returns the job ID if successful, null otherwise
  static Future<String?> createJobAsDraft({
    required BuildContext context,
    required Map<String, dynamic> jobData,
    JobPlan? selectedPlan,
  }) async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      
      // Create the job as draft
      final success = await jobProvider.createJob(
        hrPhone: jobData['hrPhone'] ?? '',
        title: jobData['title'] ?? '',
        companyName: jobData['companyName'] ?? '',
        jobCategory: jobData['jobCategory'] ?? '',
        jobType: jobData['jobType'] ?? '',
        planType: selectedPlan?.planName.toLowerCase().replaceAll(' ', '_') ?? 'basic',
        salaryType: jobData['salaryType'] ?? 'Fixed',
        salaryRange: jobData['salaryRange'] ?? {'min': 0, 'max': 0},
        workLocation: jobData['workLocation'] ?? 'Work From Home',
        jobLocation: jobData['jobLocation'] ?? 'Not specified',
        preferredLocation: jobData['preferredLocation'] ?? 'Not specified',
        officeAddress: jobData['officeAddress'] ?? 'Not specified',
        floorDetails: jobData['floorDetails'] ?? 'Ground Floor',
        coordinates: jobData['coordinates'] ?? [0.0, 0.0],
        minimumEducation: jobData['minimumEducation'] ?? "Bachelor's Degree",
        englishLevel: jobData['englishLevel'] ?? 'intermediate',
        totalExperience: jobData['totalExperience'] ?? '0-1 years',
        openingFor: jobData['openingFor'] ?? 'Any',
        jobDescription: jobData['jobDescription'] ?? 'Job description not provided',
        ageRange: jobData['ageRange'] ?? {'min': 18, 'max': 60},
        gender: jobData['gender'] ?? 'Both genders allowed',
        openings: jobData['openings'] ?? 1,
        isWalkInInterview: jobData['isWalkInInterview'] ?? false,
        additionalPerks: jobData['additionalPerks'] ?? [],
        documents: jobData['documents'] ?? ['Aadhar Card'],
        communicationPreference: jobData['communicationPreference'] ?? 'phone',
        workingDays: jobData['workingDays'] ?? 'monday-saturday',
        jobTiming: jobData['jobTiming'] ?? '9:00 AM - 6:00 PM',
      );

      if (success) {
        // Get the created job ID from the jobs list (last created job)
        final jobs = jobProvider.getDraftJobs();
        if (jobs.isNotEmpty) {
          final lastJob = jobs.last;
          return lastJob['_id']?.toString() ?? lastJob['id']?.toString();
        }
        return null;
      } else {
        // Show user-friendly error message
        if (context.mounted) {
          final msg = JobErrorHelper.parse(jobProvider.rawErrorMessage);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to create job. Please check your connection and try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return null;
    }
  }

  /// Publishes a draft job (checks credits and deducts 1 credit)
  /// Returns a map with success status and optional navigation flag
  static Future<Map<String, dynamic>> publishDraftJob({
    required BuildContext context,
    required String jobId,
  }) async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      
      // Publish the job (API will check credits and deduct)
      final result = await jobProvider.publishJob(jobId);
      
      if (result['success'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Job published successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return {
          'success': true,
          'needsPlan': false,
        };
      } else {
        // Check if error is about credits/plan
        final message = result['message'] ?? '';
        final needsPlan = message.toLowerCase().contains('plan') || 
                         message.toLowerCase().contains('credit');
        
        return {
          'success': false,
          'message': message,
          'needsPlan': needsPlan,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to publish job. Please try again.',
        'needsPlan': false,
      };
    }
  }
}