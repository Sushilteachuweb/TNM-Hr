import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';
import '../../../Provider/hr_profile_provider.dart';
import '../../../Provider/unified_billing_provider.dart';
import '../../../services/job_creation_service.dart';
import '../../bottomNavBar/bottomNavBar.dart';
import '../CreateNewJobDetails/subscription/subscription.dart';

class JobLocationEmploymentPage extends StatefulWidget {
  const JobLocationEmploymentPage({super.key});

  @override
  State<JobLocationEmploymentPage> createState() => _JobLocationEmploymentPageState();
}

class _JobLocationEmploymentPageState extends State<JobLocationEmploymentPage> {
  final _officeAddressController = TextEditingController();
  final _totalOpeningsController = TextEditingController();
  final _jobTimingController = TextEditingController();
  
  // Add a unique key for the Google Places widget
  final _officeAddressKey = GlobalKey();
  
  // Add FocusNode to manage focus
  final _officeAddressFocusNode = FocusNode();

  // Options based on website screenshots
  final List<String> workLocationTypes = [
    "Select Work Location Type",
    "Work From Home",
    "Work From Office", 
    "Field Job"
  ];

  final List<String> communicationOptions = [
    "Yes, to myself",
    "Yes, to other recruiter", 
    "No, I will contact candidates first"
  ];

  final List<String> additionalPerksList = [
    "Flexible Working Hours",
    "Weekly Payoff",
    "Overtime Pay", 
    "Travel Allowance (TA)",
    "Mobile Allowance",
    "Internet Allowance",
    "Health Insurance",
    "Food/Meals",
    "Accommodation",
    "5 Working Days",
    "One-Way Cab",
    "Annual Bonus",
    "PF",
    "ESI (ESIC)",
    "Joining Bonus",
    "Petrol Allowance",
    "Two-Way Cab"
  ];

  final List<String> documentsList = [
    "Aadhar Card",
    "PAN Card", 
    "Bank Account",
    "Passport",
    "Driving License",
    "Educational Certificates"
  ];

  final List<String> workingDaysList = [
    "Monday-Friday",
    "Monday-Saturday", 
    "Others"
  ];

  @override
  void initState() {
    super.initState();
    final formProvider = Provider.of<JobFormProvider>(context, listen: false);
    _officeAddressController.text = formProvider.officeAddress;
    _totalOpeningsController.text = formProvider.totalOpenings.toString();
    _jobTimingController.text = formProvider.jobTiming;
  }

  @override
  void dispose() {
    _officeAddressController.dispose();
    _totalOpeningsController.dispose();
    _jobTimingController.dispose();
    _officeAddressFocusNode.dispose();
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
      bottomNavigationBar: _buildSubmitButton(),
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
              Icons.location_on_outlined,
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
                  "Job Location & Employment Details",
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Step 2 of 2",
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
          _buildInterviewMethodSection(),
          const SizedBox(height: 32),
          _buildJobLocationSection(),
          const SizedBox(height: 32),
          _buildEmploymentInfoSection(),
        ],
      ),
    );
  }

  Widget _buildInterviewMethodSection() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Interview Method and Communication Preferences",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Walk-in Interview
        Text(
          "Is this a walk-in interview?",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: formProvider.isWalkInInterview,
              onChanged: (value) => formProvider.setWalkInInterview(value!),
              activeColor: AppColors.primary,
            ),
            Text("Yes", style: AppTextStyles.body2),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: formProvider.isWalkInInterview,
              onChanged: (value) => formProvider.setWalkInInterview(value!),
              activeColor: AppColors.primary,
            ),
            Text("No", style: AppTextStyles.body2),
          ],
        ),
        const SizedBox(height: 16),
        
        // Total Number of Openings
        _buildTextField(
          controller: _totalOpeningsController,
          label: "Total Number of Openings",
          hint: "3",
          keyboardType: TextInputType.number,
          onChanged: (value) {
            int openings = int.tryParse(value) ?? 1;
            formProvider.setTotalOpenings(openings);
          },
        ),
        const SizedBox(height: 16),
        
        // Communication Preferences
        Text(
          "Communication Preferences",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Do you want candidates to contact you via Call / WhatsApp after they apply? *",
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...communicationOptions.map((option) {
          return RadioListTile<String>(
            title: Text(
              option,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            value: option,
            groupValue: formProvider.communicationPreference,
            onChanged: (value) => formProvider.setCommunicationPreference(value!),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildJobLocationSection() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Job Location & Work Type",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Work Location Type
        _buildDropdownWithPlaceholder(
          label: "Work Location Type *",
          value: formProvider.workLocationType.isEmpty ? workLocationTypes[0] : formProvider.workLocationType,
          items: workLocationTypes,
          placeholderIndex: 0, // "Select Work Location Type" is at index 0
          onChanged: (value) {
            if (value != null && value != workLocationTypes[0]) {
              formProvider.setWorkLocationType(value);
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Office Address - Google Places Autocomplete
        Text(
          "Office Address *",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          key: _officeAddressKey,
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: _officeAddressController,
            focusNode: _officeAddressFocusNode,
            googleAPIKey: "AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154",
            boxDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            inputDecoration: InputDecoration(
              hintText: "Search for office address",
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(Icons.business, color: AppColors.primary),
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
              String fullAddress = prediction.description ?? "";
              formProvider.setOfficeAddress(fullAddress);
              print("🏢 Office address selected: $fullAddress");
            },
            itemClick: (Prediction prediction) {
              // Set the value directly without clearing
              _officeAddressController.text = prediction.description ?? "";
              _officeAddressController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
              // Unfocus to dismiss keyboard and prevent further input issues
              _officeAddressFocusNode.unfocus();
            },
            seperatedBuilder: const Divider(),
            containerHorizontalPadding: 10,
            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.business, color: AppColors.primary),
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
        const SizedBox(height: 8),
        Text(
          "Start typing your office address to see suggestions",
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Additional Perks
        Text(
          "Do you offer any additional perks?",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: additionalPerksList.map((perk) {
            final isSelected = formProvider.additionalPerks.contains(perk);
            return GestureDetector(
              onTap: () => formProvider.toggleAdditionalPerk(perk),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  perk,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmploymentInfoSection() {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Employment Info",
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Documents Required
        Text(
          "Documents Required",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Separate multiple documents with commas",
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: documentsList.map((document) {
            final isSelected = formProvider.documentsRequired.contains(document);
            return GestureDetector(
              onTap: () => formProvider.toggleDocument(document),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  document,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Working Days
        _buildDropdown(
          label: "Working Days",
          value: formProvider.workingDays,
          items: workingDaysList,
          onChanged: (value) => formProvider.setWorkingDays(value!),
        ),
        const SizedBox(height: 16),
        
        // Job Timing
        _buildTextField(
          controller: _jobTimingController,
          label: "Job Timing",
          hint: "9:30am - 6:00pm",
          onChanged: (value) => formProvider.setJobTimingSingle(value),
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

  Widget _buildSubmitButton() {
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
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Previous",
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                final formProvider = Provider.of<JobFormProvider>(context, listen: false);
                final hrProvider = Provider.of<HrProfileProvider>(context, listen: false);
                final unifiedBillingProvider = Provider.of<UnifiedBillingProvider>(context, listen: false);
                
                if (formProvider.isPage2Valid()) {
                  // Get HR profile data
                  await hrProvider.loadProfileFromLocal();
                  
                  // Ensure we have a valid phone number
                  String hrPhone = hrProvider.hrPhone;
                  if (hrPhone.isEmpty) {
                    // Try to get from UserStorage as fallback
                    final prefs = await SharedPreferences.getInstance();
                    hrPhone = prefs.getString('phone') ?? '';
                  }
                  
                  if (hrPhone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('HR phone number is required. Please update your profile.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  
                  // Prepare job data
                  final jobData = formProvider.getJobData(
                    hrPhone: hrPhone,
                  );
                  
                  // Always create job as draft first (new flow)
                  print("📝 Creating job as draft");
                  
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  try {
                    // Create job as draft (no credit check needed)
                    final jobId = await JobCreationService.createJobAsDraft(
                      context: context,
                      jobData: jobData,
                    );
                    
                    // Remove loading indicator
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.of(context).pop(); // Remove loading dialog
                    }
                    
                    if (jobId != null) {
                      // Job created as draft successfully
                      print("✅ Job created as draft with ID: $jobId");
                      
                      // Show success message and navigate to jobs screen
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Job saved as draft successfully! You can publish it from the Jobs screen.'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        
                        // Navigate to jobs screen where user can publish the draft
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const BottomNavBar(initialIndex: 1),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      }
                    } else {
                      // Job creation failed
                      print("❌ Failed to create job as draft");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Failed to create job. Please try again.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // Remove loading indicator on error
                    if (mounted && Navigator.canPop(context)) {
                      Navigator.of(context).pop(); // Remove loading dialog
                    }
                    
                    if (mounted) {
                      print("❌ Job creation error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Unable to create job. Please try again.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
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