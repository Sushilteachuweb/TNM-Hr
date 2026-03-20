import 'package:flutter/material.dart';
import '../models/job_category_model.dart';
import '../services/job_api_service.dart';
import '../data/indian_states_cities.dart';

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
  String jobType = "Full Time"; // Full Time, Part Time, Both (Full - Part Time)
  
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
  String jobDescriptionDelta = ""; // Delta JSON for re-editing
  
  // Preferred Requirements
  int minAge = 18;
  int maxAge = 50;
  String preferredLocation = ""; // City preference - will be set from dropdown
  String preferredState = ""; // State preference - new field for state selection
  String preferredCity = ""; // City preference - new field for city selection
  String gender = "Both genders allowed"; // Both genders allowed, Male only, Female only
  
  // Coordinates for preferred location
  List<double> preferredCoordinates = [0.0, 0.0];

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

  void setJobDescription(String value, {String? delta}) {
    jobDescription = value;
    if (delta != null) {
      jobDescriptionDelta = delta;
    }
    notifyListeners();
  }

  void setAgeRange(int min, int max) {
    minAge = min;
    maxAge = max;
    notifyListeners();
  }

  void setPreferredLocation(String value) {
    preferredLocation = value;
    // Don't overwrite city and state if they're already set (from Google Places)
    // Only parse if they're empty
    if (value.isNotEmpty && preferredCity.isEmpty && preferredState.isEmpty) {
      List<String> parts = value.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 2) {
        if (preferredCity.isEmpty) {
          preferredCity = parts[0];
        }
        if (preferredState.isEmpty && parts.length >= 3) {
          preferredState = parts[parts.length - 2];
        } else if (preferredState.isEmpty) {
          preferredState = parts[parts.length - 1];
        }
      }
    }
    notifyListeners();
  }

  void setPreferredState(String value) {
    preferredState = value;
    // Reset city when state changes
    preferredCity = "";
    // Update preferredLocation to combine state and city
    _updatePreferredLocation();
    notifyListeners();
  }

  void setPreferredCity(String value) {
    preferredCity = value;
    // Update preferredLocation to combine state and city
    _updatePreferredLocation();
    notifyListeners();
  }
  
  void setPreferredCoordinates(double lat, double lng) {
    preferredCoordinates = [lat, lng];
    print("🌍 Coordinates stored in provider: [$lat, $lng]");
    notifyListeners();
  }

  void _updatePreferredLocation() {
    if (preferredState.isNotEmpty && preferredCity.isNotEmpty) {
      preferredLocation = "$preferredCity, $preferredState";
    } else if (preferredState.isNotEmpty) {
      preferredLocation = preferredState;
    } else if (preferredCity.isNotEmpty) {
      preferredLocation = preferredCity;
    } else {
      preferredLocation = "";
    }
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

  // Pre-fill form from existing job data (for edit flow)
  void prefillFromJob(Map<String, dynamic> job) {
    Map<String, dynamic>? _m(dynamic v) => v is Map<String, dynamic> ? v : null;
    List<dynamic>? _l(dynamic v) => v is List ? v : null;

    final salaryRange = _m(job['salaryRange']);
    final locationDetails = _m(job['locationDetails']);
    final candidateReq = _m(job['candidateRequirements']);
    final employmentDetails = _m(job['employmentDetails']);
    final jobTimingMap = _m(job['jobTiming']);
    final ageRange = _m(candidateReq?['ageRange']);
    final coordinates = _l(locationDetails?['coordinates']);

    // PAGE 1
    companyName = job['companyName'] ?? companyName;
    jobTitle = job['title'] ?? '';
    jobCategory = job['jobCategory'] ?? '';

    // Map API jobType back to UI value
    final rawJobType = _m(employmentDetails)?['jobType'] ?? job['jobType'] ?? 'Full Time';
    const jobTypeApiToUi = {
      'Full Time': 'Full Time',
      'Part Time': 'Part Time',
      'Both (Full - Part Time)': 'Both (Full - Part Time)',
      // legacy values
      'Both': 'Both (Full - Part Time)',
      'Both (Full + Part Time)': 'Both (Full - Part Time)',
    };
    jobType = jobTypeApiToUi[rawJobType] ?? rawJobType;

    // Salary
    final rawSalaryType = salaryRange?['salaryType'] ?? job['salaryType'] ?? 'Fixed Only';
    salaryType = rawSalaryType;
    minSalary = salaryRange?['min']?.toString() ?? job['minSalary']?.toString() ?? '';
    maxSalary = salaryRange?['max']?.toString() ?? job['maxSalary']?.toString() ?? '';

    // Candidate requirements
    final rawEdu = candidateReq?['minimumEducation'] ?? job['minimumEducation'] ?? '10th or Below 10th';
    // Map API education back to UI value
    const eduApiToUi = {
      '10th Pass': '10th or Below 10th',
      '12th Pass': '12th Pass',
      'Graduate': 'Graduate',
      "Bachelor's Degree": 'Graduate',
      'Post Graduate': 'Post Graduate',
      'Diploma': 'Diploma',
    };
    minimumEducation = eduApiToUi[rawEdu] ?? rawEdu;

    // English level
    final rawEnglish = candidateReq?['englishLevel'] ?? job['englishLevel'] ?? '';
    const englishApiToUi = {
      'No English': 'No English',
      'Good English': 'Good English',
      'Fluent English': 'Fluent English',
      'beginner': 'No English',
      'intermediate': 'Good English',
      'advanced': 'Fluent English',
      'fluent': 'Fluent English',
    };
    englishLevel = englishApiToUi[rawEnglish] ?? rawEnglish;

    // Experience
    final rawExp = candidateReq?['totalExperience'] ?? job['totalExperience'] ?? 'Any';
    const expApiToUi = {
      'Any': 'Any',
      'Fresher': 'Fresher Only',
      'Experience': 'Experienced Only',
    };
    totalExperience = expApiToUi[rawExp] ?? 'Any';

    jobDescription = job['jobDescription'] ?? job['description'] ?? '';
    jobDescriptionDelta = '';

    // Age
    minAge = ageRange?['min'] ?? job['minAge'] ?? 18;
    maxAge = ageRange?['max'] ?? job['maxAge'] ?? 50;

    // Preferred location
    preferredLocation = locationDetails?['preferredLocation'] ?? job['preferredLocation'] ?? job['jobLocation'] ?? '';
    preferredCity = '';
    preferredState = '';
    if (preferredLocation.isNotEmpty) {
      final parts = preferredLocation.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 2) {
        preferredCity = parts[0];
        preferredState = parts[1];
      }
    }

    // Coordinates
    if (coordinates != null && coordinates.length >= 2) {
      preferredCoordinates = [
        (coordinates[0] as num).toDouble(),
        (coordinates[1] as num).toDouble(),
      ];
    }

    // Gender
    final rawGender = candidateReq?['gender'] ?? job['gender'] ?? 'Both genders allowed';
    const genderApiToUi = {
      'Both genders allowed': 'Both genders allowed',
      'Male only': 'Male only',
      'Female only': 'Female only',
    };
    gender = genderApiToUi[rawGender] ?? 'Both genders allowed';

    // PAGE 2
    isWalkInInterview = _m(employmentDetails)?['isWalkInInterview'] ?? job['isWalkInInterview'] ?? true;
    totalOpenings = _m(employmentDetails)?['openings'] ?? job['openings'] ?? 1;

    final rawCommPref = job['communicationPreference'] ?? 'Yes, to myself';
    // Support both old API format (phone/none) and new full string format
    if (rawCommPref == 'phone,whatsapp') {
      communicationPreference = 'Yes, to other recruiter';
    } else if (rawCommPref == 'none') {
      communicationPreference = 'No, I will contact candidates first';
    } else if (rawCommPref == 'phone') {
      communicationPreference = 'Yes, to myself';
    } else {
      // New format - use as-is if it matches known values
      const validPrefs = [
        'Yes, to myself',
        'Yes, to other recruiter',
        'No, I will contact candidates first',
      ];
      communicationPreference = validPrefs.contains(rawCommPref)
          ? rawCommPref
          : 'Yes, to myself';
    }

    // Work location
    final rawWorkLoc = locationDetails?['workLocation'] ?? job['workLocation'] ?? '';
    const workLocApiToUi = {
      'Work From Home': 'Work From Home',
      'Work From Office': 'Work From Office',
      'Field Job': 'Field Job',
    };
    workLocationType = workLocApiToUi[rawWorkLoc] ?? rawWorkLoc;

    officeAddress = locationDetails?['officeAddress'] ?? job['officeAddress'] ?? '';

    // Perks
    final perks = job['additionalPerks'];
    additionalPerks = perks is List ? List<String>.from(perks) : [];

    // Documents — flatten any comma-joined strings inside the list
    final docs = job['documentsRequired'] ?? job['documents'];
    if (docs is List) {
      documentsRequired = docs
          .expand((e) => e.toString().split(',').map((s) => s.trim()))
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (docs is String) {
      documentsRequired = docs.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      documentsRequired = [];
    }

    // Working days
    final rawDays = jobTimingMap?['workingDays'] ?? job['workingDays'] ?? 'Monday-Friday';
    const daysApiToUi = {
      'monday-friday': 'Monday-Friday',
      'monday-saturday': 'Monday-Saturday',
      'others': 'Others',
      'Monday-Friday': 'Monday-Friday',
      'Monday-Saturday': 'Monday-Saturday',
      'Others': 'Others',
    };
    workingDays = daysApiToUi[rawDays] ?? 'Monday-Friday';

    jobTiming = jobTimingMap?['timing'] ?? (job['jobTiming'] is String ? job['jobTiming'] : '') ?? '9:30am - 6:00pm';

    notifyListeners();
  }

  // Reset form data
  void resetForm() {
    // PAGE 1: Job Basic Details & Requirements
    companyName = "";
    jobTitle = "";
    jobCategory = "";
    jobType = "Full Time"; // Full Time, Part Time, Both (Full - Part Time)
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
    preferredState = "";
    preferredCity = "";
    preferredCoordinates = [0.0, 0.0];
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
    final salaryValid = salaryType == 'Incentive Only' ||
        (minSalary.isNotEmpty && maxSalary.isNotEmpty);
    return companyName.isNotEmpty &&
           jobTitle.isNotEmpty &&
           jobCategory.isNotEmpty &&
           jobType.isNotEmpty &&
           salaryValid &&
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
    final Map<String, String> jobTypeMap = {
      'Full Time': 'Full Time',
      'Part Time': 'Part Time',
      'Both (Full - Part Time)': 'Both (Full - Part Time)',
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
    List<double>? coordinates,
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

    // Convert communication preference to API format (send full string value)
    String apiCommunicationPreference = communicationPreference.isNotEmpty
        ? communicationPreference
        : 'Yes, to myself';

    // Ensure hrPhone is not empty
    String finalHrPhone = hrPhone.isNotEmpty ? hrPhone : "1234567890"; // Fallback phone
    
    // Use coordinates from Google Places if available, otherwise try to get from city data
    List<double> finalCoordinates = coordinates ?? preferredCoordinates;
    
    // If still [0.0, 0.0], try to get from IndianStatesAndCities
    if ((finalCoordinates[0] == 0.0 && finalCoordinates[1] == 0.0) && 
        preferredState.isNotEmpty && preferredCity.isNotEmpty) {
      final cityCoordinates = IndianStatesAndCities.getCoordinatesForCity(preferredState, preferredCity);
      finalCoordinates = cityCoordinates;
    }
    
    // If still [0.0, 0.0], use a default location (center of India)
    if (finalCoordinates[0] == 0.0 && finalCoordinates[1] == 0.0) {
      finalCoordinates = [20.5937, 78.9629]; // Center of India
      print("⚠️ Using default coordinates (center of India)");
    }
    
    // Debug logging
    print('🔍 Converting values:');
    print('  jobType: "$jobType" → "$apiJobType"');
    print('  workLocationType: "$workLocationType" → "$apiWorkLocation"');
    print('  gender: "$gender" → "$apiGender"');
    print('  minimumEducation: "$minimumEducation" → "$apiEducation"');
    print('  totalExperience: "$totalExperience" → "$apiExperience"');
    print('  hrPhone: "$hrPhone" → "$finalHrPhone"');
    print('🌍 LOCATION DATA:');
    print('  preferredState: "$preferredState"');
    print('  preferredCity: "$preferredCity"');
    print('  combined preferredLocation: "$preferredLocation"');
    print('  coordinates: $finalCoordinates');

    Map<String, dynamic> data = {
      'hrPhone': finalHrPhone,
      'title': jobTitle,
      'companyName': companyName,
      'jobCategory': jobCategory,
      'jobType': apiJobType,
      'planType': 'basic',
      'salaryType': apiSalaryType,
      if (apiSalaryType != 'Incentive Only') 'salaryRange': {
        'min': int.tryParse(minSalary.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
        'max': int.tryParse(maxSalary.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
      },
      'workLocation': apiWorkLocation,
      'jobLocation': preferredLocation,
      'preferredLocation': preferredLocation,
      'officeAddress': officeAddress,
      'floorDetails': floorDetails.isNotEmpty ? floorDetails : 'N/A',
      'coordinates': finalCoordinates,
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
      'documents': documentsRequired.isNotEmpty
          ? documentsRequired
          : ['Aadhar Card'],
      'communicationPreference': apiCommunicationPreference,
      'workingDays': apiWorkingDays,
      'jobTiming': jobTiming,
    };

    return data;
  }
}