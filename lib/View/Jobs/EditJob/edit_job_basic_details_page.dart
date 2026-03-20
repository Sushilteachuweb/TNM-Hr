import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';
import '../../../data/indian_states_cities.dart';
import '../../../utils/job_error_helper.dart';
import '../../Home/CreateNewJobDetails/job_description_editor.dart';
import 'edit_job_location_employment_page.dart';

class EditJobBasicDetailsPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const EditJobBasicDetailsPage({super.key, required this.job});

  @override
  State<EditJobBasicDetailsPage> createState() => _EditJobBasicDetailsPageState();
}

class _EditJobBasicDetailsPageState extends State<EditJobBasicDetailsPage> {
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

  final _preferredLocationKey = GlobalKey();
  final _preferredLocationFocusNode = FocusNode();

  final List<String> jobTypes = ["Full Time", "Part Time", "Both (Full - Part Time)"];
  final List<String> salaryTypes = ["Fixed Only", "Fixed + Incentive", "Incentive Only"];
  final List<String> educationLevels = [
    "10th or Below 10th", "12th Pass", "Diploma", "Graduate", "Post Graduate"
  ];
  final List<String> englishLevels = ["No English", "Good English", "Fluent English"];
  final List<String> experienceLevels = ["Any", "Experienced Only", "Fresher Only"];
  final List<String> genderOptions = ["Both genders allowed", "Male only", "Female only"];

  @override
  void initState() {
    super.initState();
    // Pre-fill provider with job data, then sync controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formProvider = Provider.of<JobFormProvider>(context, listen: false);
      formProvider.prefillFromJob(widget.job);
      _syncControllersFromProvider(formProvider);
    });
  }

  void _syncControllersFromProvider(JobFormProvider p) {
    _companyNameController.text = p.companyName;
    _jobTitleController.text = p.jobTitle;
    _minSalaryController.text = p.minSalary;
    _maxSalaryController.text = p.maxSalary;
    _jobDescriptionController.text = p.jobDescription;
    _minAgeController.text = p.minAge.toString();
    _maxAgeController.text = p.maxAge.toString();
    _minExpController.text = p.minExperience;
    _maxExpController.text = p.maxExperience;
    _preferredLocationController.text = p.preferredLocation;
    setState(() {});
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
            child: const Icon(Icons.work_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Job Basic Details",
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
        Text("Basic Details",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Company Name - read-only
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Company Name *",
                style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
                          ? "Loading..."
                          : _companyNameController.text,
                      style: AppTextStyles.body1.copyWith(
                          color: _companyNameController.text.isEmpty
                              ? Colors.grey[500]
                              : AppColors.textPrimary),
                    ),
                  ),
                  Icon(Icons.lock_outline, color: Colors.grey[400], size: 18),
                ],
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
          onChanged: (v) => formProvider.setJobTitle(v),
        ),
        const SizedBox(height: 16),

        // Job Category - DISABLED (cannot be changed)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Job Category / Role *",
                style: AppTextStyles.subtitle2.copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
                  Icon(Icons.category_outlined, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formProvider.jobCategory.isEmpty
                          ? widget.job['jobCategory'] ?? 'N/A'
                          : formProvider.jobCategory,
                      style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  Icon(Icons.lock_outline, color: Colors.grey[400], size: 18),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text("Job category cannot be changed",
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 16),

        // Job Type
        _buildRadioGroup(
          label: "Job Type *",
          options: jobTypes,
          selectedValue: jobTypes.contains(formProvider.jobType)
              ? formProvider.jobType
              : jobTypes[0],
          onChanged: (v) => formProvider.setJobType(v!),
        ),
      ],
    );
  }

  Widget _buildSalaryDetails() {
    final formProvider = Provider.of<JobFormProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Salary Details",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildRadioGroup(
          label: "Salary Details *",
          options: salaryTypes,
          selectedValue: salaryTypes.contains(formProvider.salaryType)
              ? formProvider.salaryType
              : salaryTypes[0],
          onChanged: (v) => formProvider.setSalaryType(v!),
        ),
        const SizedBox(height: 16),
        if (formProvider.salaryType != 'Incentive Only') ...[
          Text("Salary Range / Month *",
              style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _minSalaryController,
                  label: "Minimum Salary",
                  hint: "₹ 10000",
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      formProvider.setSalaryRange(v, _maxSalaryController.text),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxSalaryController,
                  label: "Maximum Salary",
                  hint: "₹ 25000",
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      formProvider.setSalaryRange(_minSalaryController.text, v),
                ),
              ),
            ],
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
        Text("Candidate Requirements",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildDropdown(
          label: "Minimum Education *",
          value: educationLevels.contains(formProvider.minimumEducation)
              ? formProvider.minimumEducation
              : educationLevels[0],
          items: educationLevels,
          onChanged: (v) => formProvider.setMinimumEducation(v!),
        ),
        const SizedBox(height: 16),
        Text("English level required *",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
                      color: isSelected ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(level,
                    style: AppTextStyles.body2.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildRadioGroup(
          label: "Total experience required *",
          options: experienceLevels,
          selectedValue: experienceLevels.contains(formProvider.totalExperience)
              ? formProvider.totalExperience
              : experienceLevels[0],
          onChanged: (v) => formProvider.setTotalExperience(v!),
        ),
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
                  onChanged: (v) =>
                      formProvider.setExperienceRange(v, _maxExpController.text),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _maxExpController,
                  label: "Max Experience",
                  hint: "5",
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      formProvider.setExperienceRange(_minExpController.text, v),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text("Job Description",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
                      ? Text("Tap to write job description...",
                          style: AppTextStyles.body1.copyWith(
                              color: AppColors.textHint, height: 1.5))
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
                          },
                        ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
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
        Text("Preferred Requirements",
            style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text("Age Range",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _minAgeController,
                label: "Min Age",
                hint: "18",
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  int minAge = int.tryParse(v) ?? 18;
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
                onChanged: (v) {
                  int maxAge = int.tryParse(v) ?? 50;
                  formProvider.setAgeRange(formProvider.minAge, maxAge);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text("Prefer applications from *",
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        // Google Places Autocomplete for preferred location
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
              hintText: "Search for location",
              hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
            countries: const ["in"],
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              String fullAddress = prediction.description ?? "";
              // Parse city/state from address parts
              final parts = fullAddress.split(',').map((e) => e.trim()).toList();
              String city = '';
              String state = '';
              if (parts.length >= 3) {
                city = parts[0];
                state = parts[1];
              } else if (parts.length == 2) {
                city = parts[0];
                state = parts[1];
              } else if (parts.length == 1) {
                city = parts[0];
              }
              formProvider.setPreferredCity(city);
              formProvider.setPreferredState(state);
              formProvider.setPreferredLocation(fullAddress);
              // Store coordinates
              if (prediction.lat != null && prediction.lng != null) {
                double lat = double.tryParse(prediction.lat ?? "0") ?? 0.0;
                double lng = double.tryParse(prediction.lng ?? "0") ?? 0.0;
                formProvider.setPreferredCoordinates(lat, lng);
              }
            },
            itemClick: (Prediction prediction) {
              _preferredLocationController.text = prediction.description ?? "";
              _preferredLocationController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
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
                  color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: "Gender",
          value: genderOptions.contains(formProvider.gender)
              ? formProvider.gender
              : genderOptions[0],
          items: genderOptions,
          onChanged: (v) => formProvider.setGender(v!),
        ),
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
      child: ElevatedButton(
        onPressed: () {
          final formProvider =
              Provider.of<JobFormProvider>(context, listen: false);
          if (formProvider.isPage1Valid()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditJobLocationEmploymentPage(
                  jobId: widget.job['_id'] ?? widget.job['id'] ?? '',
                ),
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
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text("Next",
            style: AppTextStyles.button.copyWith(color: Colors.white)),
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
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      IndianStatesAndCities.getDisplayName(item),
                      overflow: TextOverflow.ellipsis,
                    ),
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

  Widget _buildRadioGroup({
    required String label,
    required List<String> options,
    required String selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...options.map((option) => RadioListTile<String>(
              title: Text(option,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textPrimary)),
              value: option,
              groupValue: selectedValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }
}
