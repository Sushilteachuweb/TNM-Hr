import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';
import '../../../Provider/hr_profile_provider.dart';
import '../../../services/user_storage.dart';
import '../../../data/indian_states_cities.dart';
import '../../../utils/job_error_helper.dart';
import 'JobLocationEmploymentPage.dart';
import '../CreateNewJobDetails/job_description_editor.dart';

class JobBasicDetailsPage extends StatefulWidget {
  const JobBasicDetailsPage({super.key});

  @override
  State<JobBasicDetailsPage> createState() => _JobBasicDetailsPageState();
}

class _JobBasicDetailsPageState extends State<JobBasicDetailsPage> {
  final _companyNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _minExpController = TextEditingController();
  final _maxExpController = TextEditingController();
  final _preferredLocationController = TextEditingController();
  
  // Add a unique key for the Google Places widget
  final _preferredLocationKey = GlobalKey();
  
  // Add FocusNode to manage focus
  final _preferredLocationFocusNode = FocusNode();

  // Options based on website screenshots
  final List<String> jobTypes = ["Full Time", "Part Time", "Both (Full - Part Time)"];
  final List<String> salaryTypes = ["Fixed Only", "Fixed + Incentive", "Incentive Only"];
  final List<String> educationLevels = [
    "10th or Below 10th", 
    "12th Pass", 
    "Diploma", 
    "Graduate", 
    "Post Graduate"
  ];
  final List<String> englishLevels = ["No English", "Good English", "Fluent English"];
  final List<String> experienceLevels = ["Any", "Experienced Only", "Fresher Only"];
  final List<String> genderOptions = ["Both genders allowed", "Male only", "Female only"];
  final List<String> preferredLocations = [
    "Select preferred location",
    "Entire Delhi-NCR",
    "Noida",
    "Mumbai", 
    "Bangalore",
    "Chennai",
    "Pune",
    "Hyderabad"
  ];

  @override
  void initState() {
    super.initState();
    final formProvider = Provider.of<JobFormProvider>(context, listen: false);
    final hrProfileProvider = Provider.of<HrProfileProvider>(context, listen: false);

    // Reset form so no stale data from a previous edit session leaks in
    formProvider.resetForm();

    // Load job categories from API after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      formProvider.fetchJobCategories();
      
      // Load company name from profile
      await hrProfileProvider.loadProfileFromLocal();
      String companyName = hrProfileProvider.companyName;
      
      // If not in profile provider, try UserStorage
      if (companyName.isEmpty) {
        final userData = await UserStorage.getLoginData();
        companyName = userData['company'] ?? '';
      }
      
      // Set company name in form provider and controller
      if (companyName.isNotEmpty) {
        formProvider.setCompanyName(companyName);
        _companyNameController.text = companyName;
      }
    });
    
    _companyNameController.text = formProvider.companyName;
    _jobTitleController.text = formProvider.jobTitle;
    _minSalaryController.text = formProvider.minSalary;
    _maxSalaryController.text = formProvider.maxSalary;
    _jobDescriptionController.text = formProvider.jobDescription;
    _minAgeController.text = formProvider.minAge.toString();
    _maxAgeController.text = formProvider.maxAge.toString();
    _minExpController.text = formProvider.minExperience;
    _maxExpController.text = formProvider.maxExperience;
    _preferredLocationController.text = formProvider.preferredLocation;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _jobDescriptionController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minExpController.dispose();
    _maxExpController.dispose();
    _preferredLocationController.dispose();
    _preferredLocationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Post A New Job",
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            _buildFormCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildNextButton(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work_outline,
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
                  "Enter Job Basic Details",
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Step 1 of 2",
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicDetails(),
          const SizedBox(height: 32),
          _buildSalaryDetails(),
          const SizedBox(height: 32),
          _buildCandidateRequirements(),
          const SizedBox(height: 32),
          _buildPreferredRequirements(),
        ],
      ),
    );
  }

  Widget _buildBasicDetails() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Basic Details",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Company Name (Read-only, auto-filled from profile)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Company Name *",
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.business, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _companyNameController.text.isEmpty 
                          ? "Loading from profile..." 
                          : _companyNameController.text,
                      style: AppTextStyles.body1.copyWith(
                        color: _companyNameController.text.isEmpty 
                            ? Colors.grey[500] 
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.lock_outline, color: Colors.grey[400], size: 18),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Company name is auto-filled from your profile",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Job Title
        _buildTextField(
          controller: _jobTitleController,
          label: "Job Designation / Title *",
          hint: "e.g. Software Engineer, Sales Executive",
          onChanged: (value) => formProvider.setJobTitle(value),
        ),
        const SizedBox(height: 16),
        
        // Job Category
        Consumer<JobFormProvider>(
          builder: (context, formProvider, child) {
            if (formProvider.isLoadingCategories) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Job Category / Role *",
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Loading categories...",
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (formProvider.categoriesError.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: "Job Category / Role *",
                    value: formProvider.jobCategory.isEmpty ? formProvider.jobCategoryNames[0] : formProvider.jobCategory,
                    items: formProvider.jobCategoryNames,
                    onChanged: (value) {
                      if (value != formProvider.jobCategoryNames[0]) {
                        formProvider.setJobCategory(value!);
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Using offline categories",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }

            return _buildDropdownWithPlaceholder(
              label: "Job Category / Role *",
              value: formProvider.jobCategory.isEmpty ? formProvider.jobCategoryNames[0] : formProvider.jobCategory,
              items: formProvider.jobCategoryNames,
              placeholderIndex: 0, // "Select Category" is at index 0
              onChanged: (value) {
                if (value != null && value != formProvider.jobCategoryNames[0]) {
                  formProvider.setJobCategory(value);
                }
              },
            );
          },
        ),
        const SizedBox(height: 16),
        
        // Job Type
        _buildRadioGroup(
          label: "Job Type *",
          options: jobTypes,
          selectedValue: formProvider.jobType,
          onChanged: (value) => formProvider.setJobType(value!),
        ),
      ],
    );
  }

  Widget _buildSalaryDetails() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Salary Details",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Salary Type
        _buildRadioGroup(
          label: "Salary Details *",
          options: salaryTypes,
          selectedValue: formProvider.salaryType,
          onChanged: (value) => formProvider.setSalaryType(value!),
        ),
        const SizedBox(height: 16),
        
        // Salary Range - hidden for Incentive Only
        if (formProvider.salaryType != 'Incentive Only') ...[
          Text(
            "Salary Range / Month *",
            style: AppTextStyles.subtitle2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minSalaryController,
                  label: "Minimum Salary",
                  hint: "₹ 10000",
                  keyboardType: TextInputType.number,
                  onChanged: (value) => formProvider.setSalaryRange(value, _maxSalaryController.text),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxSalaryController,
                  label: "Maximum Salary",
                  hint: "₹ 25000",
                  keyboardType: TextInputType.number,
                  onChanged: (value) => formProvider.setSalaryRange(_minSalaryController.text, value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Salary Range: ₹10,000 - ₹50,000 per month",
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCandidateRequirements() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Candidate Requirements",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Minimum Education
        _buildDropdown(
          label: "Minimum Education *",
          value: formProvider.minimumEducation,
          items: educationLevels,
          onChanged: (value) => formProvider.setMinimumEducation(value!),
        ),
        const SizedBox(height: 16),
        
        // English Level
        Text(
          "English level required *",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: englishLevels.map((level) {
            final isSelected = formProvider.englishLevel == level;
            return GestureDetector(
              onTap: () => formProvider.setEnglishLevel(level),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Total Experience
        _buildRadioGroup(
          label: "Total experience required *",
          options: experienceLevels,
          selectedValue: formProvider.totalExperience,
          onChanged: (value) => formProvider.setTotalExperience(value!),
        ),
        
        // Experience Range (show only if "Experienced Only" is selected)
        if (formProvider.totalExperience == "Experienced Only") ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minExpController,
                  label: "Min Experience",
                  hint: "0",
                  keyboardType: TextInputType.number,
                  onChanged: (value) => formProvider.setExperienceRange(value, _maxExpController.text),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxExpController,
                  label: "Max Experience",
                  hint: "5",
                  keyboardType: TextInputType.number,
                  onChanged: (value) => formProvider.setExperienceRange(_minExpController.text, value),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        
        // Job Description
        Text(
          "Job Description",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push<Map<String, String>>(
              context,
              MaterialPageRoute(
                builder: (context) => JobDescriptionEditor(
                  initialDescription: formProvider.jobDescription,
                  initialDelta: formProvider.jobDescriptionDelta.isNotEmpty 
                      ? formProvider.jobDescriptionDelta 
                      : null,
                ),
              ),
            );
            
            if (result != null) {
              final html = result['html'] ?? '';
              final delta = result['delta'] ?? '';
              print('📋 Received HTML in preview: $html');
              print('📋 Received Delta: $delta');
              formProvider.setJobDescription(html, delta: delta);
              _jobDescriptionController.text = html;
            }
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: formProvider.jobDescription.isEmpty 
                    ? AppColors.border 
                    : AppColors.primary,
                width: formProvider.jobDescription.isEmpty ? 1 : 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: formProvider.jobDescription.isEmpty
                      ? Text(
                          "Tap to write job description...",
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textHint,
                            height: 1.5,
                          ),
                        )
                      : Html(
                          data: formProvider.jobDescription,
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(16),
                              color: AppColors.textPrimary,
                              lineHeight: const LineHeight(1.5),
                            ),
                            "b": Style(
                              fontWeight: FontWeight.bold,
                            ),
                            "i": Style(
                              fontStyle: FontStyle.italic,
                            ),
                            "ul": Style(
                              margin: Margins.only(left: 0, top: 4, bottom: 4),
                              padding: HtmlPaddings.only(left: 20),
                              display: Display.block,
                            ),
                            "ol": Style(
                              margin: Margins.only(left: 0, top: 4, bottom: 4),
                              padding: HtmlPaddings.only(left: 20),
                              display: Display.block,
                            ),
                            "li": Style(
                              margin: Margins.only(bottom: 4),
                              padding: HtmlPaddings.zero,
                              display: Display.listItem,
                            ),
                          },
                        ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferredRequirements() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Preferred Requirements",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Age Range
        Text(
          "Age Range",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _minAgeController,
                label: "Min Age",
                hint: "18",
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int minAge = int.tryParse(value) ?? 18;
                  formProvider.setAgeRange(minAge, formProvider.maxAge);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _maxAgeController,
                label: "Max Age",
                hint: "50",
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int maxAge = int.tryParse(value) ?? 50;
                  formProvider.setAgeRange(formProvider.minAge, maxAge);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "18 - 50 years",
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Prefer applications from - Google Places Autocomplete
        Text(
          "Prefer applications from *",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Google Places Autocomplete for Location
        Container(
          key: _preferredLocationKey,
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: _preferredLocationController,
            focusNode: _preferredLocationFocusNode,
            googleAPIKey: "AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154",
            boxDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            inputDecoration: InputDecoration(
              hintText: "Search for city or location",
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            debounceTime: 600,
            countries: const ["in"], // Restrict to India
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              // Extract city and state from the prediction
              String fullAddress = prediction.description ?? "";
              
              // Parse the address to extract city and state
              List<String> parts = fullAddress.split(',').map((e) => e.trim()).toList();
              
              String city = "";
              String state = "";
              
              if (parts.length >= 3) {
                // Format: "City, State, Country"
                city = parts[0];
                state = parts[1];
              } else if (parts.length == 2) {
                // Format: "City, State" or "State, Country"
                city = parts[0];
                state = parts[1];
              } else if (parts.length == 1) {
                // Only one part, treat as city
                city = parts[0];
              }
              
              // Update provider with parsed values FIRST
              formProvider.setPreferredCity(city);
              formProvider.setPreferredState(state);
              
              // Then set the full location (this will use the city and state we just set)
              formProvider.setPreferredLocation(fullAddress);
              
              print("📍 Preferred Location selected: $fullAddress");
              print("🏙️ City: $city, State: $state");
              
              // Get coordinates if available
              if (prediction.lat != null && prediction.lng != null) {
                double lat = double.tryParse(prediction.lat ?? "0") ?? 0.0;
                double lng = double.tryParse(prediction.lng ?? "0") ?? 0.0;
                print("🌍 Coordinates: [$lat, $lng]");
                
                // Store coordinates in provider
                formProvider.setPreferredCoordinates(lat, lng);
              }
            },
            itemClick: (Prediction prediction) {
              // Set the value directly without clearing
              _preferredLocationController.text = prediction.description ?? "";
              _preferredLocationController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
              // Unfocus to dismiss keyboard and prevent further input issues
              _preferredLocationFocusNode.unfocus();
            },
            seperatedBuilder: const Divider(),
            containerHorizontalPadding: 10,
            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prediction.description ?? "",
                        style: AppTextStyles.body2,
                      ),
                    ),
                  ],
                ),
              );
            },
            isCrossBtnShown: true,
          ),
        ),
        
        if (formProvider.preferredLocation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "Selected: ${formProvider.preferredLocation}",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Gender
        _buildDropdown(
          label: "Gender",
          value: formProvider.gender,
          items: genderOptions,
          onChanged: (value) => formProvider.setGender(value!),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    // Add input formatters for number fields
    List<TextInputFormatter>? inputFormatters;
    if (keyboardType == TextInputType.number) {
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly, // Only allow digits
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<String> items,
    String? hint,
    bool enabled = true,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true, // This prevents overflow
          items: items.map((item) {
            if (item.isEmpty) {
              return DropdownMenuItem<String>(
                value: item,
                enabled: false,
                child: Text(
                  hint ?? "Select an option",
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                IndianStatesAndCities.getDisplayName(item),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownWithPlaceholder({
    required String label,
    required String value,
    required List<String> items,
    required int placeholderIndex,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            
            return DropdownMenuItem<String>(
              value: item,
              enabled: index != placeholderIndex, // Disable placeholder option
              child: Text(
                item,
                style: TextStyle(
                  color: index == placeholderIndex 
                    ? AppColors.textSecondary.withOpacity(0.6) // Grayed out placeholder
                    : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required List<String> options,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(
              option,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            value: option,
            groupValue: selectedValue,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: ElevatedButton(
              onPressed: () {
                final formProvider = Provider.of<JobFormProvider>(context, listen: false);
                if (formProvider.isPage1Valid()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobLocationEmploymentPage(),
                    ),
                  );
                } else {
                  final msg = JobErrorHelper.page1ValidationMessage(
                    companyName: formProvider.companyName,
                    jobTitle: formProvider.jobTitle,
                    jobCategory: formProvider.jobCategory,
                    jobType: formProvider.jobType,
                    salaryType: formProvider.salaryType,
                    minSalary: formProvider.minSalary,
                    maxSalary: formProvider.maxSalary,
                    minimumEducation: formProvider.minimumEducation,
                    preferredLocation: formProvider.preferredLocation,
                    jobDescription: formProvider.jobDescription,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Next",
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}