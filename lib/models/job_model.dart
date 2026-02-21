import 'package:flutter/material.dart';

class Job {
  final String? id;
  final String hrPhone;
  final String? hrId;
  final String title;
  final String companyName;
  final String jobCategory;
  final String jobType;
  final List<String> planType; // Changed from String to List<String>
  final SalaryDetails salaryDetails;
  final LocationDetails locationDetails;
  final CandidateRequirements candidateRequirements;
  final EmploymentDetails employmentDetails;
  final JobTiming jobTiming;
  final List<String> additionalPerks;
  final List<String> documentsRequired;
  final String communicationPreference;
  final String jobDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status; // active, pending, closed, draft
  final bool isPublished;
  final bool isFeatured;
  final int views;
  final List<dynamic> applications;

  Job({
    this.id,
    required this.hrPhone,
    this.hrId,
    required this.title,
    required this.companyName,
    required this.jobCategory,
    required this.jobType,
    required this.planType,
    required this.salaryDetails,
    required this.locationDetails,
    required this.candidateRequirements,
    required this.employmentDetails,
    required this.jobTiming,
    required this.additionalPerks,
    required this.documentsRequired,
    required this.communicationPreference,
    required this.jobDescription,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.isPublished = false,
    this.isFeatured = false,
    this.views = 0,
    this.applications = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Handle planType - can be array or string
    List<String> planTypeList = [];
    if (json['planType'] != null) {
      if (json['planType'] is List) {
        planTypeList = List<String>.from(json['planType']);
      } else if (json['planType'] is String) {
        planTypeList = [json['planType']];
      }
    }

    return Job(
      id: json['_id'] ?? json['id'],
      hrPhone: json['hrPhone'] ?? '',
      hrId: json['hrId'],
      title: json['title'] ?? '',
      companyName: json['companyName'] ?? '',
      jobCategory: json['jobCategory'] ?? '',
      jobType: json['jobType'] ?? '',
      planType: planTypeList,
      salaryDetails: SalaryDetails.fromJson(json['salaryDetails'] ?? json),
      locationDetails: LocationDetails.fromJson(json['locationDetails'] ?? json),
      candidateRequirements: CandidateRequirements.fromJson(json['candidateRequirements'] ?? json),
      employmentDetails: EmploymentDetails.fromJson(json['employmentDetails'] ?? json),
      jobTiming: JobTiming.fromJson(json['jobTiming'] ?? json),
      additionalPerks: List<String>.from(json['additionalPerks'] ?? []),
      documentsRequired: _parseDocuments(json['documents'] ?? json['documentsRequired']),
      communicationPreference: json['communicationPreference'] ?? '',
      jobDescription: json['jobDescription'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: json['status'] ?? 'active',
      isPublished: json['isPublished'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      views: json['views'] ?? 0,
      applications: List<dynamic>.from(json['applications'] ?? []),
    );
  }

  // Helper method to parse documents (can be array or comma-separated string)
  static List<String> _parseDocuments(dynamic documents) {
    if (documents == null) return [];
    if (documents is List) {
      return List<String>.from(documents);
    }
    if (documents is String) {
      return documents.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'hrPhone': hrPhone,
      if (hrId != null) 'hrId': hrId,
      'title': title,
      'companyName': companyName,
      'jobCategory': jobCategory,
      'jobType': jobType,
      'planType': planType,
      'salaryType': salaryDetails.salaryType,
      'salaryRange': salaryDetails.toRangeJson(),
      'workLocation': locationDetails.workLocation,
      'jobLocation': locationDetails.jobLocation,
      'preferredLocation': locationDetails.preferredLocation,
      'officeAddress': locationDetails.officeAddress,
      'floorDetails': locationDetails.floorDetails,
      'coordinates': locationDetails.coordinates,
      'minimumEducation': candidateRequirements.minimumEducation,
      'englishLevel': candidateRequirements.englishLevel,
      'totalExperience': candidateRequirements.totalExperience,
      'openingFor': candidateRequirements.openingFor,
      'ageRange': candidateRequirements.ageRange.toJson(),
      'gender': candidateRequirements.gender,
      'openings': employmentDetails.openings,
      'isWalkInInterview': employmentDetails.isWalkInInterview,
      'workingDays': employmentDetails.workingDays,
      'additionalPerks': additionalPerks,
      'documents': documentsRequired.join(', '),
      'communicationPreference': communicationPreference,
      'jobTiming': jobTiming.toString(),
      'jobDescription': jobDescription,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (status != null) 'status': status,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'views': views,
      'applications': applications,
    };
  }

  // Helper methods
  String get formattedSalary => salaryDetails.formattedRange;
  String get locationSummary => locationDetails.summary;
  String get experienceRequirement => candidateRequirements.experienceSummary;
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isClosed => status == 'closed';
  bool get isDraft => status == 'draft';
  int get applicationsCount => applications.length;
  String get planTypeSummary => planType.isEmpty ? 'No plan' : planType.join(', ');
}

class SalaryDetails {
  final String salaryType; // Fixed Only, Fixed + Incentive, Incentive Only
  final int minSalary;
  final int maxSalary;

  SalaryDetails({
    required this.salaryType,
    required this.minSalary,
    required this.maxSalary,
  });

  factory SalaryDetails.fromJson(Map<String, dynamic> json) {
    // Handle both nested and flat structures
    final salaryRange = json['salaryRange'] ?? {};
    return SalaryDetails(
      salaryType: json['salaryType'] ?? 'Fixed Only',
      minSalary: salaryRange['min'] ?? json['minSalary'] ?? 0,
      maxSalary: salaryRange['max'] ?? json['maxSalary'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salaryType': salaryType,
      'minSalary': minSalary,
      'maxSalary': maxSalary,
    };
  }

  Map<String, int> toRangeJson() {
    return {
      'min': minSalary,
      'max': maxSalary,
    };
  }

  String get formattedRange => '₹$minSalary - ₹$maxSalary';
}

class LocationDetails {
  final String workLocation; // Office, Work from Home, Field Job
  final String jobLocation;
  final String preferredLocation;
  final String officeAddress;
  final String floorDetails;
  final List<double> coordinates;
  final Map<String, dynamic>? location; // GeoJSON location object

  LocationDetails({
    required this.workLocation,
    required this.jobLocation,
    required this.preferredLocation,
    required this.officeAddress,
    required this.floorDetails,
    required this.coordinates,
    this.location,
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    // Extract coordinates from either 'coordinates' field or 'location.coordinates'
    List<double> coords = [0.0, 0.0];
    if (json['coordinates'] != null) {
      coords = List<double>.from(json['coordinates']);
    } else if (json['location'] != null && json['location']['coordinates'] != null) {
      coords = List<double>.from(json['location']['coordinates']);
    }

    return LocationDetails(
      workLocation: json['workLocation'] ?? '',
      jobLocation: json['jobLocation'] ?? '',
      preferredLocation: json['preferredLocation'] ?? '',
      officeAddress: json['officeAddress'] ?? '',
      floorDetails: json['floorDetails'] ?? '',
      coordinates: coords,
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workLocation': workLocation,
      'jobLocation': jobLocation,
      'preferredLocation': preferredLocation,
      'officeAddress': officeAddress,
      'floorDetails': floorDetails,
      'coordinates': coordinates,
      if (location != null) 'location': location,
    };
  }

  String get summary => '$jobLocation ($workLocation)';
}

class CandidateRequirements {
  final String minimumEducation; // 10th Pass, 12th Pass, Graduate, etc.
  final String englishLevel; // No English, Good English, Fluent English
  final String totalExperience; // Any, Experience, Fresher
  final String openingFor; // Any, Experience, Fresher
  final AgeRange ageRange;
  final String gender; // Male only, Female only, Both genders allowed

  CandidateRequirements({
    required this.minimumEducation,
    required this.englishLevel,
    required this.totalExperience,
    required this.openingFor,
    required this.ageRange,
    required this.gender,
  });

  factory CandidateRequirements.fromJson(Map<String, dynamic> json) {
    return CandidateRequirements(
      minimumEducation: json['minimumEducation'] ?? '',
      englishLevel: json['englishLevel'] ?? '',
      totalExperience: json['totalExperience'] ?? '',
      openingFor: json['openingFor'] ?? '',
      ageRange: AgeRange.fromJson(json['ageRange'] ?? {}),
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumEducation': minimumEducation,
      'englishLevel': englishLevel,
      'totalExperience': totalExperience,
      'openingFor': openingFor,
      'ageRange': ageRange.toJson(),
      'gender': gender,
    };
  }

  String get experienceSummary {
    if (totalExperience == 'Any') return 'Any experience level';
    if (totalExperience == 'Fresher') return 'Freshers only';
    return 'Experienced candidates';
  }
}

class AgeRange {
  final int min;
  final int max;

  AgeRange({
    required this.min,
    required this.max,
  });

  factory AgeRange.fromJson(Map<String, dynamic> json) {
    return AgeRange(
      min: json['min'] ?? 18,
      max: json['max'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }

  String get formatted => '$min - $max years';
}

class EmploymentDetails {
  final int openings;
  final bool isWalkInInterview;
  final String workingDays; // Monday-Friday, Monday-Saturday, Others

  EmploymentDetails({
    required this.openings,
    required this.isWalkInInterview,
    required this.workingDays,
  });

  factory EmploymentDetails.fromJson(Map<String, dynamic> json) {
    return EmploymentDetails(
      openings: json['openings'] ?? 1,
      isWalkInInterview: json['isWalkInInterview'] ?? false,
      workingDays: json['workingDays'] ?? 'Monday-Friday',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openings': openings,
      'isWalkInInterview': isWalkInInterview,
      'workingDays': workingDays,
    };
  }
}

class JobTiming {
  final String startTime;
  final String endTime;

  JobTiming({
    required this.startTime,
    required this.endTime,
  });

  factory JobTiming.fromJson(dynamic json) {
    // Handle both string format "09:00 AM - 06:00 PM" and object format
    if (json is String) {
      final parts = json.split(' - ');
      return JobTiming(
        startTime: parts.isNotEmpty ? parts[0] : '09:00 AM',
        endTime: parts.length > 1 ? parts[1] : '06:00 PM',
      );
    }
    
    if (json is Map<String, dynamic>) {
      return JobTiming(
        startTime: json['startTime']?.toString() ?? '09:00 AM',
        endTime: json['endTime']?.toString() ?? '06:00 PM',
      );
    }

    return JobTiming(
      startTime: '09:00 AM',
      endTime: '06:00 PM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  @override
  String toString() => '$startTime - $endTime';
}

// Enums for better type safety
enum JobType {
  fullTime('Full Time'),
  partTime('Part Time'),
  both('Both');

  const JobType(this.value);
  final String value;
}

enum WorkLocationType {
  office('Office'),
  workFromHome('Work From Home'),
  fieldJob('Field Job');

  const WorkLocationType(this.value);
  final String value;
}

enum SalaryType {
  fixedOnly('Fixed Only'),
  fixedPlusIncentive('Fixed + Incentive'),
  incentiveOnly('Incentive Only');

  const SalaryType(this.value);
  final String value;
}

enum EducationLevel {
  tenthOrBelow('10th Pass'),
  twelfthPass('12th Pass'),
  graduate('Graduate'),
  postGraduate('Post Graduate');

  const EducationLevel(this.value);
  final String value;
}

enum ExperienceLevel {
  any('Any'),
  fresher('Fresher'),
  experienced('Experience');

  const ExperienceLevel(this.value);
  final String value;
}

enum GenderPreference {
  bothAllowed('Both genders allowed'),
  maleOnly('Male only'),
  femaleOnly('Female only');

  const GenderPreference(this.value);
  final String value;
}

enum JobStatus {
  draft('draft'),
  active('active'),
  pending('pending'),
  closed('closed');

  const JobStatus(this.value);
  final String value;
}