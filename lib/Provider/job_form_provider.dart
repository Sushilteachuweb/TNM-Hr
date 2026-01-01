import 'package:flutter/material.dart';
import '../models/job_category_model.dart';
import '../services/job_api_service.dart';

class JobFormProvider with ChangeNotifier {
  // Job Categories
  List<JobCategory> _jobCategories = [];
  bool _isLoadingCategories = false;
  String _categoriesError = '';

  // Getters for job categories
  List<JobCategory> get jobCategories => _jobCategories;
  bool get isLoadingCategories => _isLoadingCategories;
  String get categoriesError => _categoriesError;
  
  // Get job category names for dropdown
  List<String> get jobCategoryNames {
    List<String> names = ['Select Category'];
    names.addAll(_jobCategories.map((category) => category.jobCategory));
    return names;
  }

  // PAGE 1: Job Basic Details & Requirements
  // Basic Details
  String companyName = "";
  String jobTitle = "";
  String jobCategory = "";
  String jobType = "Full Time"; // Full Time, Part Time, Both (Full + Part Time)
  
  // Salary Details
  String salaryType = "Fixed Only"; // Fixed Only, Fixed + Incentive, Incentive Only
  String minSalary = "";
  String maxSalary = "";
  
  // Candidate Requirements
  String minimumEducation = "10th or Below 10th"; // 10th or Below 10th, 12th Pass, Diploma, Graduate, Post Graduate
  String englishLevel = ""; // No English, Good English, Fluent English - single selection
  String totalExperience = "Any"; // Any, Experienced Only, Fresher Only
  String minExperience = "0";
  String maxExperience = "0";
  String jobDescription = "";
  
  // Preferred Requirements
  int minAge = 18;
  int maxAge = 50;
  String preferredLocation = ""; // City preference - will be set from dropdown
  String gender = "Both genders allowed"; // Both genders allowed, Male only, Female only

  // Additional properties for UI compatibility
  String get genderPreference => gender;
  String get minimumQualification => minimumEducation;
  String get selectedOpening => totalExperience;
  String get selectedSalaryType => salaryType;
  List<String> get selectedBenefits => additionalPerks;
  List<String> get selectedDocuments => documentsRequired;
  String get selectedWorkingDays => workingDays;
  String get jobLocationType => workLocationType;
  
  // Communication preferences
  bool allowCall = true;
  bool allowWhatsApp = false;

  // Additional properties for compatibility
  String get city => preferredLocation;
  String get locality => preferredLocation;
  int get numberOfOpenings => totalOpenings;

  // PAGE 2: Location, Employment & Interview Details
  // Interview Method
  bool isWalkInInterview = true;
  int totalOpenings = 1;
  
  // Communication Preferences
  String communicationPreference = "Yes, to myself"; // Yes, to myself | Yes, to other recruiter | No, I will contact candidates first
  
  // Job Location & Work Type
  String workLocationType = ""; // Office, Work from Home, Field Job
  String officeAddress = "";
  List<String> additionalPerks = []; // Flexible Working Hours, Weekly Payoff, Overtime Pay, Travel Allowance (TA), etc.
  
  // Employment Info
  List<String> documentsRequired = []; // Aadhar Card, PAN Card, Bank Account, etc.
  String workingDays = "Monday-Friday"; // Monday-Friday, Monday-Saturday, Others
  String jobTiming = "9:30am - 6:00pm";

  // PAGE 1 SETTERS: Job Basic Details & Requirements
  void setCompanyName(String value) {
    companyName = value;
    notifyListeners();
  }

  void setJobTitle(String value) {
    jobTitle = value;
    notifyListeners();
  }

  void setJobCategory(String value) {
    jobCategory = value;
    notifyListeners();
  }

  void setJobType(String value) {
    jobType = value;
    notifyListeners();
  }

  void setSalaryType(String value) {
    salaryType = value;
    notifyListeners();
  }

  void setSalaryRange(String min, String max) {
    minSalary = min;
    maxSalary = max;
    notifyListeners();
  }

  void setMinimumEducation(String value) {
    minimumEducation = value;
    notifyListeners();
  }

  void setEnglishLevel(String level) {
    englishLevel = level;
    notifyListeners();
  }

  void setTotalExperience(String value) {
    totalExperience = value;
    notifyListeners();
  }

  void setExperienceRange(String min, String max) {
    minExperience = min;
    maxExperience = max;
    notifyListeners();
  }

  void setJobDescription(String value) {
    jobDescription = value;
    notifyListeners();
  }

  void setAgeRange(int min, int max) {
    minAge = min;
    maxAge = max;
    notifyListeners();
  }

  void setPreferredLocation(String value) {
    preferredLocation = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  // Additional setter methods for UI compatibility
  void setOpening(String value) {
    setTotalExperience(value);
  }

  void setExperience(String min, String max) {
    setExperienceRange(min, max);
  }

  void toggleBenefit(String benefit) {
    toggleAdditionalPerk(benefit);
  }

  void addPerk(String perk) {
    if (perk.isNotEmpty && !additionalPerks.contains(perk)) {
      additionalPerks.add(perk);
      notifyListeners();
    }
  }

  void setCommunicationPreferences(bool call, bool whatsapp) {
    allowCall = call;
    allowWhatsApp = whatsapp;
    
    // Update communication preference based on settings
    if (call && whatsapp) {
      communicationPreference = "Yes, to other recruiter";
    } else if (call) {
      communicationPreference = "Yes, to myself";
    } else {
      communicationPreference = "No, I will contact candidates first";
    }
    notifyListeners();
  }

  // Override setJobTiming to accept two parameters for start and end time
  void setJobTiming(String startTime, String endTime) {
    jobTiming = "$startTime - $endTime";
    notifyListeners();
  }

  // Keep the single parameter version for backward compatibility
  void setJobTimingSingle(String value) {
    jobTiming = value;
    notifyListeners();
  }

  // Additional setters for missing properties
  void setCity(String value) {
    preferredLocation = value;
    notifyListeners();
  }

  void setLocality(String value) {
    // Add locality property if needed, for now map to preferredLocation
    preferredLocation = value;
    notifyListeners();
  }

  void setNumberOfOpenings(int value) {
    totalOpenings = value;
    notifyListeners();
  }

  // PAGE 2 SETTERS: Location, Employment & Interview Details
  void setWalkInInterview(bool value) {
    isWalkInInterview = value;
    notifyListeners();
  }

  void setTotalOpenings(int value) {
    totalOpenings = value;
    notifyListeners();
  }

  void setCommunicationPreference(String value) {
    communicationPreference = value;
    notifyListeners();
  }

  void setWorkLocationType(String value) {
    workLocationType = value;
    notifyListeners();
  }

  void setOfficeAddress(String value) {
    officeAddress = value;
    notifyListeners();
  }

  void setAdditionalPerks(List<String> perks) {
    additionalPerks = perks;
    notifyListeners();
  }

  void toggleAdditionalPerk(String perk) {
    if (additionalPerks.contains(perk)) {
      additionalPerks.remove(perk);
    } else {
      additionalPerks.add(perk);
    }
    notifyListeners();
  }

  void setDocumentsRequired(List<String> documents) {
    documentsRequired = documents;
    notifyListeners();
  }

  void toggleDocument(String document) {
    if (documentsRequired.contains(document)) {
      documentsRequired.remove(document);
    } else {
      documentsRequired.add(document);
    }
    notifyListeners();
  }

  void setWorkingDays(String value) {
    workingDays = value;
    notifyListeners();
  }

  // Reset form data
  void resetForm() {
    // PAGE 1: Job Basic Details & Requirements
    companyName = "";
    jobTitle = "";
    jobCategory = "";
    jobType = "Full Time";
    salaryType = "Fixed Only";
    minSalary = "";
    maxSalary = "";
    minimumEducation = "10th or Below 10th";
    englishLevel = "";
    totalExperience = "Any";
    minExperience = "0";
    maxExperience = "0";
    jobDescription = "";
    minAge = 18;
    maxAge = 50;
    preferredLocation = "";
    gender = "Both genders allowed";

    // PAGE 2: Location, Employment & Interview Details
    isWalkInInterview = true;
    totalOpenings = 1;
    communicationPreference = "Yes, to myself";
    workLocationType = "Work From Home"; // Set proper default
    officeAddress = "";
    additionalPerks = [];
    documentsRequired = [];
    workingDays = "Monday-Friday";
    jobTiming = "9:30am - 6:00pm";
    // Communication preferences
    allowCall = true;
    allowWhatsApp = false;
  }

  // Job Categories Management
  Future<void> fetchJobCategories() async {
    _isLoadingCategories = true;
    _categoriesError = '';
    notifyListeners();

    try {
      final response = await JobApiService.getAllJobCategories();
      if (response != null && response.success) {
        _jobCategories = response.data;
        _categoriesError = '';
      } else {
        _categoriesError = 'Failed to load job categories';
        // Fallback to hardcoded categories
        _setFallbackCategories();
      }
    } catch (e) {
      _categoriesError = 'Error loading job categories: $e';
      // Fallback to hardcoded categories
      _setFallbackCategories();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void _setFallbackCategories() {
    _jobCategories = [
      JobCategory(
        id: '1',
        image: '',
        jobCategory: 'Business Development Executive',
        subcategories: ['Business Development'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      JobCategory(
        id: '2',
        image: '',
        jobCategory: 'Sales Executive',
        subcategories: ['Sales'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      JobCategory(
        id: '3',
        image: '',
        jobCategory: 'Marketing Executive',
        subcategories: ['Marketing'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      JobCategory(
        id: '4',
        image: '',
        jobCategory: 'Customer Service',
        subcategories: ['Customer Support'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      JobCategory(
        id: '5',
        image: '',
        jobCategory: 'IT/Software',
        subcategories: ['Software Development'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      JobCategory(
        id: '6',
        image: '',
        jobCategory: 'Others',
        subcategories: ['General'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Validation methods
  bool isPage1Valid() {
    return companyName.isNotEmpty &&
           jobTitle.isNotEmpty &&
           jobCategory.isNotEmpty &&
           jobType.isNotEmpty &&
           minSalary.isNotEmpty &&
           maxSalary.isNotEmpty &&
           minimumEducation.isNotEmpty &&
           preferredLocation.isNotEmpty &&
           jobDescription.isNotEmpty;
  }

  bool isPage2Valid() {
    final validWorkLocations = ['Work From Home', 'Work From Office', 'Field Job'];
    return workLocationType.isNotEmpty &&
           validWorkLocations.contains(workLocationType) &&
           officeAddress.isNotEmpty &&
           totalOpenings > 0;
  }

  // Helper method to convert UI values to API format
  String _convertJobType(String uiValue) {
    // Use exact values that work in the existing create job screen
    final Map<String, String> jobTypeMap = {
      'Full Time': 'Full Time',
      'Part Time': 'Part Time',
      'Both (Full + Part Time)': 'Both',
    };
    return jobTypeMap[uiValue] ?? 'Full Time';
  }

  String _convertWorkLocation(String uiValue) {
    // Use exact values that work in the existing create job screen
    final Map<String, String> workLocationMap = {
      'Work From Office': 'Work From Office',
      'Work From Home': 'Work From Home',
      'Field Job': 'Field Job',
    };
    
    // Safety check - if the value is not in our map, log it and use default
    if (!workLocationMap.containsKey(uiValue)) {
      print('⚠️ Invalid work location value: "$uiValue", using default "Work From Home"');
      return 'Work From Home';
    }
    
    return workLocationMap[uiValue] ?? 'Work From Home';
  }

  String _convertGender(String uiValue) {
    // Use exact values that work in the existing create job screen
    final Map<String, String> genderMap = {
      'Both genders allowed': 'Both genders allowed',
      'Male only': 'Male only',
      'Female only': 'Female only',
    };
    return genderMap[uiValue] ?? 'Both genders allowed';
  }

  String _convertEducation(String uiValue) {
    // Use exact values that work in the existing create job screen
    final Map<String, String> educationMap = {
      '10th or Below 10th': '10th Pass',
      '12th Pass': '12th Pass',
      'Diploma': 'Graduate',
      'Graduate': "Bachelor's Degree",
      'Post Graduate': 'Post Graduate',
    };
    return educationMap[uiValue] ?? '10th Pass';
  }

  String _convertExperience(String uiValue) {
    // Use exact values that work in the existing create job screen
    final Map<String, String> experienceMap = {
      'Any': 'Any',
      'Experienced Only': 'Experience',
      'Fresher Only': 'Fresher',
    };
    return experienceMap[uiValue] ?? 'Any';
  }

  String _convertSalaryType(String uiValue) {
    if (uiValue.isEmpty) return 'Fixed Only';
    
    final Map<String, String> salaryTypeMap = {
      'Fixed Only': 'Fixed Only',
      'Fixed + Incentive': 'Fixed + Incentive',
      'Incentive Only': 'Incentive Only',
    };
    
    return salaryTypeMap[uiValue] ?? 'Fixed Only';
  }

  String _convertWorkingDays(String uiValue) {
    if (uiValue.isEmpty) return 'monday-friday';
    
    final Map<String, String> workingDaysMap = {
      'Monday-Friday': 'monday-friday',
      'Monday-Saturday': 'monday-saturday',
      'Others': 'others',
    };
    
    return workingDaysMap[uiValue] ?? 'monday-friday';
  }

  // Get complete job data for API
  Map<String, dynamic> getJobData({
    required String hrPhone,
    required List<double> coordinates,
    String floorDetails = "",
  }) {
    // Convert all values to API format
    String apiJobType = _convertJobType(jobType);
    String apiWorkLocation = _convertWorkLocation(workLocationType);
    String apiGender = _convertGender(gender);
    String apiEducation = _convertEducation(minimumEducation);
    String apiExperience = _convertExperience(totalExperience);
    String apiSalaryType = _convertSalaryType(salaryType);
    String apiWorkingDays = _convertWorkingDays(workingDays);

    // Convert experience to API format
    String experienceString = apiExperience;
    if (totalExperience == "Experienced Only" && minExperience.isNotEmpty && maxExperience.isNotEmpty) {
      experienceString = '$minExperience-$maxExperience years';
    }

    // Convert communication preference to API format
    String apiCommunicationPreference = 'phone';
    if (communicationPreference == "Yes, to myself") {
      apiCommunicationPreference = 'phone';
    } else if (communicationPreference == "Yes, to other recruiter") {
      apiCommunicationPreference = 'phone,whatsapp';
    } else {
      apiCommunicationPreference = 'none';
    }

    // Ensure hrPhone is not empty
    String finalHrPhone = hrPhone.isNotEmpty ? hrPhone : "1234567890"; // Fallback phone
    
    // Debug logging
    print('🔍 Converting values:');
    print('  jobType: "$jobType" → "$apiJobType"');
    print('  workLocationType: "$workLocationType" → "$apiWorkLocation"');
    print('  gender: "$gender" → "$apiGender"');
    print('  minimumEducation: "$minimumEducation" → "$apiEducation"');
    print('  totalExperience: "$totalExperience" → "$apiExperience"');
    print('  hrPhone: "$hrPhone" → "$finalHrPhone"');

    Map<String, dynamic> data = {
      'hrPhone': finalHrPhone,
      'title': jobTitle,
      'companyName': companyName,
      'jobCategory': jobCategory,
      'jobType': apiJobType,
      'planType': 'basic',
      'salaryType': apiSalaryType,
      'salaryRange': {
        'min': int.tryParse(minSalary.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
        'max': int.tryParse(maxSalary.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
      },
      'workLocation': apiWorkLocation,
      'jobLocation': preferredLocation,
      'preferredLocation': preferredLocation,
      'officeAddress': officeAddress,
      'floorDetails': floorDetails.isNotEmpty ? floorDetails : 'N/A',
      'coordinates': coordinates,
      'minimumEducation': apiEducation,
      'englishLevel': englishLevel.isNotEmpty ? englishLevel : 'intermediate',
      'totalExperience': experienceString,
      'openingFor': apiExperience,
      'jobDescription': jobDescription,
      'ageRange': {'min': minAge, 'max': maxAge},
      'gender': apiGender,
      'openings': totalOpenings,
      'isWalkInInterview': isWalkInInterview,
      'additionalPerks': additionalPerks,
      'documents': documentsRequired.isNotEmpty ? documentsRequired : ['Aadhar Card'],
      'communicationPreference': apiCommunicationPreference,
      'workingDays': apiWorkingDays,
      'jobTiming': jobTiming,
    };

    return data;
  }
}