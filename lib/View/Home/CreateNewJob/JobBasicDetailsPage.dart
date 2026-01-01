import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';
import 'JobLocationEmploymentPage.dart';

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

  // Options based on website screenshots
  final List<String> jobTypes = ["Full Time", "Part Time", "Both (Full + Part Time)"];
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
    
    // Load job categories from API
    formProvider.fetchJobCategories();
    
    _companyNameController.text = formProvider.companyName;
    _jobTitleController.text = formProvider.jobTitle;
    _minSalaryController.text = formProvider.minSalary;
    _maxSalaryController.text = formProvider.maxSalary;
    _jobDescriptionController.text = formProvider.jobDescription;
    _minAgeController.text = formProvider.minAge.toString();
    _maxAgeController.text = formProvider.maxAge.toString();
    _minExpController.text = formProvider.minExperience;
    _maxExpController.text = formProvider.maxExperience;
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
        
        // Company Name
        _buildTextField(
          controller: _companyNameController,
          label: "Company Name *",
          hint: "Enter your company name",
          onChanged: (value) => formProvider.setCompanyName(value),
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
        
        // Salary Range
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
        _buildTextField(
          controller: _jobDescriptionController,
          label: "Job Description",
          hint: "Describe the job role and responsibilities...",
          maxLines: 4,
          onChanged: (value) => formProvider.setJobDescription(value),
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
        
        // Prefer applications from
        _buildDropdownWithPlaceholder(
          label: "Prefer applications from",
          value: formProvider.preferredLocation.isEmpty ? preferredLocations[0] : formProvider.preferredLocation,
          items: preferredLocations,
          placeholderIndex: 0, // "Select preferred location" is at index 0
          onChanged: (value) {
            if (value != null && value != preferredLocations[0]) {
              formProvider.setPreferredLocation(value);
            }
          },
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
    required String value,
    required List<String> items,
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
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
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
          value: value,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: AppColors.error,
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