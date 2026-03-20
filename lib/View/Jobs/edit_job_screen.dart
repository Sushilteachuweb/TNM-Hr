import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../Provider/job_provider.dart';

class EditJobScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _companyNameController;
  late TextEditingController _jobDescriptionController;
  late TextEditingController _minSalaryController;
  late TextEditingController _maxSalaryController;
  late TextEditingController _jobLocationController;
  late TextEditingController _preferredLocationController;
  late TextEditingController _officeAddressController;
  late TextEditingController _floorDetailsController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _totalExperienceController;
  late TextEditingController _minAgeController;
  late TextEditingController _maxAgeController;
  late TextEditingController _openingsController;
  late TextEditingController _documentsController;
  late TextEditingController _jobTimingController;

  // Dropdown values
  late String _jobCategory;
  late String _jobType;
  late String _salaryType;
  late String _workLocation;
  late String _minimumEducation;
  late String _englishLevel;
  late String _gender;
  late String _communicationPreference;
  late String _workingDays;
  late bool _isWalkInInterview;

  // Multi-select perks
  late List<String> _selectedPerks;
  final List<String> _availablePerks = [
    'Performance Bonus',
    'Health Insurance',
    'Snacks & Tea',
    'Flexible Hours',
    'Work From Home',
    'Paid Leave',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final j = widget.job;

    // Safe nested map extraction — API may return these as String or null
    Map<String, dynamic>? _asMap(dynamic v) =>
        v is Map<String, dynamic> ? v : null;
    List<dynamic>? _asList(dynamic v) => v is List ? v : null;

    final salaryRange = _asMap(j['salaryRange']);
    final locationDetails = _asMap(j['locationDetails']);
    final candidateReq = _asMap(j['candidateRequirements']);
    final employmentDetails = _asMap(j['employmentDetails']);
    final jobTimingMap = _asMap(j['jobTiming']);
    final ageRange = _asMap(candidateReq?['ageRange']);
    final coordinates = _asList(locationDetails?['coordinates']);

    _titleController = TextEditingController(text: j['title'] ?? '');
    _companyNameController = TextEditingController(text: j['companyName'] ?? '');
    _jobDescriptionController = TextEditingController(text: j['jobDescription'] ?? j['description'] ?? '');
    _minSalaryController = TextEditingController(
      text: salaryRange?['min']?.toString() ?? j['salaryRange']?['min']?.toString() ?? '',
    );
    _maxSalaryController = TextEditingController(
      text: salaryRange?['max']?.toString() ?? j['salaryRange']?['max']?.toString() ?? '',
    );
    _jobLocationController = TextEditingController(
      text: locationDetails?['jobLocation'] ?? j['jobLocation'] ?? j['location'] ?? '',
    );
    _preferredLocationController = TextEditingController(
      text: locationDetails?['preferredLocation'] ?? j['preferredLocation'] ?? '',
    );
    _officeAddressController = TextEditingController(
      text: locationDetails?['officeAddress'] ?? j['officeAddress'] ?? '',
    );
    _floorDetailsController = TextEditingController(
      text: locationDetails?['floorDetails'] ?? j['floorDetails'] ?? '',
    );
    _latitudeController = TextEditingController(
      text: coordinates != null && coordinates.length > 0
          ? coordinates[0].toString()
          : j['latitude']?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: coordinates != null && coordinates.length > 1
          ? coordinates[1].toString()
          : j['longitude']?.toString() ?? '',
    );
    _totalExperienceController = TextEditingController(
      text: candidateReq?['totalExperience'] ?? j['totalExperience'] ?? '',
    );
    _minAgeController = TextEditingController(
      text: ageRange?['min']?.toString() ?? j['minAge']?.toString() ?? '',
    );
    _maxAgeController = TextEditingController(
      text: ageRange?['max']?.toString() ?? j['maxAge']?.toString() ?? '',
    );
    _openingsController = TextEditingController(
      text: _asMap(employmentDetails)?['openings']?.toString() ?? j['openings']?.toString() ?? '',
    );
    _documentsController = TextEditingController(
      text: (j['documentsRequired'] is List)
          ? (j['documentsRequired'] as List).join(', ')
          : j['documents']?.toString() ?? '',
    );
    _jobTimingController = TextEditingController(
      text: jobTimingMap?['timing'] ?? (j['jobTiming'] is String ? j['jobTiming'] : '') ?? '',
    );

    // Dropdowns
    _jobCategory = j['jobCategory'] ?? 'IT & Software';
    _jobType = _asMap(employmentDetails)?['jobType'] ?? j['jobType'] ?? 'Full Time';
    _salaryType = salaryRange?['salaryType'] ?? j['salaryType'] ?? 'Fixed Only';
    _workLocation = _asMap(locationDetails)?['workLocation'] ?? j['workLocation'] ?? 'Work From Home';
    _minimumEducation = _asMap(candidateReq)?['minimumEducation'] ?? j['minimumEducation'] ?? "Bachelor's Degree";
    _englishLevel = _asMap(candidateReq)?['englishLevel'] ?? j['englishLevel'] ?? 'intermediate';
    _gender = _asMap(candidateReq)?['gender'] ?? j['gender'] ?? 'Both genders allowed';
    _communicationPreference = j['communicationPreference'] ?? 'phone';
    _workingDays = jobTimingMap?['workingDays'] ?? j['workingDays'] ?? 'monday-saturday';
    _isWalkInInterview = _asMap(employmentDetails)?['isWalkInInterview'] ?? j['isWalkInInterview'] ?? false;

    // Perks
    final perks = j['additionalPerks'];
    _selectedPerks = perks is List ? List<String>.from(perks) : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyNameController.dispose();
    _jobDescriptionController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _jobLocationController.dispose();
    _preferredLocationController.dispose();
    _officeAddressController.dispose();
    _floorDetailsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _totalExperienceController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _openingsController.dispose();
    _documentsController.dispose();
    _jobTimingController.dispose();
    super.dispose();
  }

  Future<void> _updateJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final jobId = widget.job['_id'] ?? widget.job['id'] ?? '';
    final jobProvider = context.read<JobProvider>();

    final success = await jobProvider.updateJob(
      jobId: jobId,
      title: _titleController.text.trim(),
      companyName: _companyNameController.text.trim(),
      jobType: _jobType,
      salaryType: _salaryType,
      salaryRange: {
        'min': int.tryParse(_minSalaryController.text.trim()) ?? 0,
        'max': int.tryParse(_maxSalaryController.text.trim()) ?? 0,
      },
      workLocation: _workLocation,
      jobLocation: _jobLocationController.text.trim(),
      preferredLocation: _preferredLocationController.text.trim(),
      officeAddress: _officeAddressController.text.trim(),
      floorDetails: _floorDetailsController.text.trim(),
      coordinates: [
        double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      ],
      minimumEducation: _minimumEducation,
      englishLevel: _englishLevel,
      totalExperience: _totalExperienceController.text.trim(),
      jobDescription: _jobDescriptionController.text.trim(),
      ageRange: {
        'min': int.tryParse(_minAgeController.text.trim()) ?? 0,
        'max': int.tryParse(_maxAgeController.text.trim()) ?? 0,
      },
      gender: _gender,
      openings: int.tryParse(_openingsController.text.trim()) ?? 1,
      isWalkInInterview: _isWalkInInterview,
      additionalPerks: _selectedPerks,
      documents: _documentsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      communicationPreference: _communicationPreference,
      workingDays: _workingDays,
      jobTiming: _jobTimingController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _updateJob,
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
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Job',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Job Category - disabled/read-only
              _buildDisabledCategoryField(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Job Title',
                hint: 'e.g., Software Developer',
                icon: Icons.title,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter job title' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _companyNameController,
                label: 'Company Name',
                hint: 'e.g., TechNova Solutions',
                icon: Icons.business,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jobDescriptionController,
                label: 'Job Description',
                hint: 'Detailed job description',
                icon: Icons.description,
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter job description' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _minSalaryController,
                      label: 'Min Salary',
                      hint: '25000',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _maxSalaryController,
                      label: 'Max Salary',
                      hint: '45000',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Job Type',
                value: _jobType,
                items: ['Full Time', 'Part Time', 'Contract', 'Internship', 'Freelance'],
                onChanged: (v) => setState(() => _jobType = v!),
                icon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Salary Type',
                value: _salaryType,
                items: ['Fixed Only', 'Fixed + Incentive', 'Incentive Only'],
                onChanged: (v) => setState(() => _salaryType = v!),
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Work Location',
                value: _workLocation,
                items: ['Work From Home', 'Work From Office', 'Hybrid'],
                onChanged: (v) => setState(() => _workLocation = v!),
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jobLocationController,
                label: 'Job Location',
                hint: 'Noida, Uttar Pradesh',
                icon: Icons.location_on,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _preferredLocationController,
                label: 'Preferred Location',
                hint: 'Delhi NCR',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _officeAddressController,
                label: 'Office Address',
                hint: 'TechNova Tower, Sector 62',
                icon: Icons.home_work,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter office address' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _floorDetailsController,
                label: 'Floor Details',
                hint: '4th Floor, Wing B',
                icon: Icons.stairs,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      hint: '28.6280',
                      icon: Icons.map,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      hint: '77.3649',
                      icon: Icons.map,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _totalExperienceController,
                label: 'Total Experience',
                hint: '1-3 years',
                icon: Icons.work_history,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter experience' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _minAgeController,
                      label: 'Min Age',
                      hint: '20',
                      icon: Icons.person,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _maxAgeController,
                      label: 'Max Age',
                      hint: '35',
                      icon: Icons.person,
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _openingsController,
                label: 'Number of Openings',
                hint: '3',
                icon: Icons.groups,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter openings' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Minimum Education',
                value: _minimumEducation,
                items: ["Bachelor's Degree", "Master's Degree", 'High School', 'Diploma', 'Any'],
                onChanged: (v) => setState(() => _minimumEducation = v!),
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'English Level',
                value: _englishLevel,
                items: ['beginner', 'intermediate', 'advanced', 'fluent'],
                onChanged: (v) => setState(() => _englishLevel = v!),
                icon: Icons.language,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Gender',
                value: _gender,
                items: ['Both genders allowed', 'Male only', 'Female only'],
                onChanged: (v) => setState(() => _gender = v!),
                icon: Icons.wc,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Communication Preference',
                value: _communicationPreference,
                items: ['phone', 'email', 'whatsapp'],
                onChanged: (v) => setState(() => _communicationPreference = v!),
                icon: Icons.contact_phone_outlined,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Working Days',
                value: _workingDays,
                items: ['monday-friday', 'monday-saturday', 'monday-sunday'],
                onChanged: (v) => setState(() => _workingDays = v!),
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jobTimingController,
                label: 'Job Timing',
                hint: '10:00 AM - 7:00 PM',
                icon: Icons.access_time,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter job timing' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _documentsController,
                label: 'Required Documents',
                hint: 'Resume, Aadhar Card',
                icon: Icons.description,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter documents' : null,
              ),
              const SizedBox(height: 16),
              // Perks multi-select
              _buildPerksSelector(),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Walk-in Interview', style: AppTextStyles.body1),
                value: _isWalkInInterview,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isWalkInInterview = v ?? false),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.buttonShadow],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: AppTextStyles.button.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Category',
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.category_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _jobCategory,
                  style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                ),
              ),
              Icon(Icons.lock_outline, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Job category cannot be changed',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPerksSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Perks',
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availablePerks.map((perk) {
            final selected = _selectedPerks.contains(perk);
            return FilterChip(
              label: Text(perk),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedPerks.add(perk);
                  } else {
                    _selectedPerks.remove(perk);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    // Ensure value is in items list, fallback to first item
    final safeValue = items.contains(value) ? value : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: safeValue,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
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
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
