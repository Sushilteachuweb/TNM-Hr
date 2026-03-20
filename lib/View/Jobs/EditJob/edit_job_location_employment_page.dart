import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';
import '../../../Provider/job_provider.dart';
import '../../../utils/job_error_helper.dart';

class EditJobLocationEmploymentPage extends StatefulWidget {
  final String jobId;

  const EditJobLocationEmploymentPage({super.key, required this.jobId});

  @override
  State<EditJobLocationEmploymentPage> createState() =>
      _EditJobLocationEmploymentPageState();
}

class _EditJobLocationEmploymentPageState
    extends State<EditJobLocationEmploymentPage> {
  final _officeAddressController = TextEditingController();
  final _totalOpeningsController = TextEditingController();
  final _jobTimingController = TextEditingController();

  final _officeAddressKey = GlobalKey();
  final _officeAddressFocusNode = FocusNode();

  bool _isLoading = false;

  final List<String> workLocationTypes = [
    "Select Work Location Type",
    "Work From Home",
    "Work From Office",
    "Field Job",
  ];

  final List<String> communicationOptions = [
    "Yes, to myself",
    "Yes, to other recruiter",
    "No, I will contact candidates first",
  ];

  final List<String> additionalPerksList = [
    "Flexible Working Hours", "Weekly Payoff", "Overtime Pay",
    "Travel Allowance (TA)", "Mobile Allowance", "Internet Allowance",
    "Health Insurance", "Food/Meals", "Accommodation", "5 Working Days",
    "One-Way Cab", "Annual Bonus", "PF", "ESI (ESIC)", "Joining Bonus",
    "Petrol Allowance", "Two-Way Cab",
  ];

  final List<String> documentsList = [
    "Aadhar Card", "PAN Card", "Bank Account",
    "Passport", "Driving License", "Educational Certificates",
  ];

  final List<String> workingDaysList = [
    "Monday-Friday", "Monday-Saturday", "Others",
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

  Future<void> _submitUpdate() async {
    final formProvider = Provider.of<JobFormProvider>(context, listen: false);

    if (!formProvider.isPage2Valid()) {
      final msg = JobErrorHelper.page2ValidationMessage(
        workLocationType: formProvider.workLocationType,
        officeAddress: formProvider.officeAddress,
        totalOpenings: formProvider.totalOpenings,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);

      // Build update payload from form provider
      final p = formProvider;

      // Convert communication preference - send as-is (API expects full string)
      String commPref = p.communicationPreference;

      // Convert working days
      const daysUiToApi = {
        'Monday-Friday': 'monday-friday',
        'Monday-Saturday': 'monday-saturday',
        'Others': 'others',
      };

      // Convert salary type
      final salaryTypeMap = {
        'Fixed Only': 'Fixed Only',
        'Fixed + Incentive': 'Fixed + Incentive',
        'Incentive Only': 'Incentive Only',
      };

      // Convert job type - send as-is (API expects full string)
      final jobTypeMap = {
        'Full Time': 'Full Time',
        'Part Time': 'Part Time',
        'Both (Full - Part Time)': 'Both (Full - Part Time)',
      };

      // Convert education
      const eduUiToApi = {
        '10th or Below 10th': '10th Pass',
        '12th Pass': '12th Pass',
        'Diploma': 'Diploma',
        'Graduate': "Bachelor's Degree",
        'Post Graduate': 'Post Graduate',
      };

      // Convert experience
      const expUiToApi = {
        'Any': 'Any',
        'Experienced Only': 'Experience',
        'Fresher Only': 'Fresher',
      };

      // Convert gender
      const genderUiToApi = {
        'Both genders allowed': 'Both genders allowed',
        'Male only': 'Male only',
        'Female only': 'Female only',
      };

      // Convert work location
      const workLocUiToApi = {
        'Work From Home': 'Work From Home',
        'Work From Office': 'Work From Office',
        'Field Job': 'Field Job',
      };

      final success = await jobProvider.updateJob(
        jobId: widget.jobId,
        title: p.jobTitle,
        companyName: p.companyName,
        jobType: jobTypeMap[p.jobType] ?? p.jobType,
        salaryType: salaryTypeMap[p.salaryType] ?? p.salaryType,
        salaryRange: p.salaryType == 'Incentive Only'
            ? null
            : {
                'min': int.tryParse(p.minSalary.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
                'max': int.tryParse(p.maxSalary.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
              },
        workLocation: workLocUiToApi[p.workLocationType] ?? p.workLocationType,
        jobLocation: p.preferredLocation,
        preferredLocation: p.preferredLocation,
        officeAddress: p.officeAddress,
        floorDetails: 'N/A',
        coordinates: p.preferredCoordinates,
        minimumEducation: eduUiToApi[p.minimumEducation] ?? p.minimumEducation,
        englishLevel: p.englishLevel,
        totalExperience: expUiToApi[p.totalExperience] ?? p.totalExperience,
        jobDescription: p.jobDescription,
        ageRange: {'min': p.minAge, 'max': p.maxAge},
        gender: genderUiToApi[p.gender] ?? p.gender,
        openings: p.totalOpenings,
        isWalkInInterview: p.isWalkInInterview,
        additionalPerks: p.additionalPerks,
        documents: p.documentsRequired.isNotEmpty
            ? p.documentsRequired
            : ['Aadhar Card'],
        communicationPreference: commPref,
        workingDays: daysUiToApi[p.workingDays] ?? 'monday-friday',
        jobTiming: p.jobTiming,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      } else {
        final jobProvider = Provider.of<JobProvider>(context, listen: false);
        final friendlyMsg = JobErrorHelper.parse(jobProvider.rawErrorMessage);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitUpdate,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Edit job error: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to update job. Please check your connection and try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitUpdate,
          ),
        ),
      );
    }
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
          "Edit Job",
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
            child: const Icon(Icons.location_on_outlined,
                color: Colors.white, size: 24),
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
        Text("Interview Method and Communication Preferences",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text("Is this a walk-in interview?",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: formProvider.isWalkInInterview,
              onChanged: (v) => formProvider.setWalkInInterview(v!),
              activeColor: AppColors.primary,
            ),
            Text("Yes", style: AppTextStyles.body2),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: formProvider.isWalkInInterview,
              onChanged: (v) => formProvider.setWalkInInterview(v!),
              activeColor: AppColors.primary,
            ),
            Text("No", style: AppTextStyles.body2),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _totalOpeningsController,
          label: "Total Number of Openings",
          hint: "3",
          keyboardType: TextInputType.number,
          onChanged: (v) {
            int openings = int.tryParse(v) ?? 1;
            formProvider.setTotalOpenings(openings);
          },
        ),
        const SizedBox(height: 16),
        Text("Communication Preferences",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          "Do you want candidates to contact you via Call / WhatsApp after they apply? *",
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ...communicationOptions.map((option) => RadioListTile<String>(
              title: Text(option,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textPrimary)),
              value: option,
              groupValue: formProvider.communicationPreference,
              onChanged: (v) => formProvider.setCommunicationPreference(v!),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }

  Widget _buildJobLocationSection() {
    final formProvider = Provider.of<JobFormProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Job Location & Work Type",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDropdownWithPlaceholder(
          label: "Work Location Type *",
          value: formProvider.workLocationType.isEmpty
              ? workLocationTypes[0]
              : formProvider.workLocationType,
          items: workLocationTypes,
          placeholderIndex: 0,
          onChanged: (v) {
            if (v != null && v != workLocationTypes[0]) {
              formProvider.setWorkLocationType(v);
            }
          },
        ),
        const SizedBox(height: 16),
        Text("Office Address *",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
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
              hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
            countries: const ["in"],
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              String fullAddress = prediction.description ?? "";
              formProvider.setOfficeAddress(fullAddress);
              // If preferred coordinates are still [0,0], use office address coordinates as fallback
              if (prediction.lat != null && prediction.lng != null) {
                double lat = double.tryParse(prediction.lat ?? "0") ?? 0.0;
                double lng = double.tryParse(prediction.lng ?? "0") ?? 0.0;
                if (formProvider.preferredCoordinates[0] == 0.0 &&
                    formProvider.preferredCoordinates[1] == 0.0) {
                  formProvider.setPreferredCoordinates(lat, lng);
                }
              }
            },
            itemClick: (Prediction prediction) {
              _officeAddressController.text = prediction.description ?? "";
              _officeAddressController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
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
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Text("Do you offer any additional perks?",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: additionalPerksList.map((perk) {
            final isSelected = formProvider.additionalPerks.contains(perk);
            return GestureDetector(
              onTap: () => formProvider.toggleAdditionalPerk(perk),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(perk,
                    style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary)),
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
        Text("Employment Info",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text("Documents Required",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: documentsList.map((doc) {
            final isSelected = formProvider.documentsRequired.contains(doc);
            return GestureDetector(
              onTap: () => formProvider.toggleDocument(doc),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(doc,
                    style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: "Working Days",
          value: workingDaysList.contains(formProvider.workingDays)
              ? formProvider.workingDays
              : workingDaysList[0],
          items: workingDaysList,
          onChanged: (v) => formProvider.setWorkingDays(v!),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _jobTimingController,
          label: "Job Timing",
          hint: "9:30am - 6:00pm",
          onChanged: (v) => formProvider.setJobTimingSingle(v),
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
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Previous",
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text("Update Job",
                      style: AppTextStyles.button
                          .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
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
    List<TextInputFormatter>? inputFormatters;
    if (keyboardType == TextInputType.number) {
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final safeValue = items.contains(value) ? value : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        Text(label,
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return DropdownMenuItem<String>(
              value: item,
              enabled: index != placeholderIndex,
              child: Text(item,
                  style: TextStyle(
                    color: index == placeholderIndex
                        ? AppColors.textSecondary.withOpacity(0.6)
                        : AppColors.textPrimary,
                  )),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
