import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/job_provider.dart';
import '../Provider/credit_provider.dart';
import '../models/job_plan_model.dart';
import '../core/app_colors.dart';

class JobCreationService {
  /// Creates a job and deducts 1 credit
  /// Returns true if successful, false otherwise
  /// Note: This service does NOT handle navigation - calling code should handle it
  static Future<bool> createJobWithCreditDeduction({
    required BuildContext context,
    required Map<String, dynamic> jobData,
    JobPlan? selectedPlan,
  }) async {
    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      final creditProvider = Provider.of<CreditProvider>(context, listen: false);
      
      // Create the job
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
        // Deduct 1 credit for the job posting
        await creditProvider.deductCredits(1);
        return true;
      } else {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jobProvider.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Unable to create job. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }
}