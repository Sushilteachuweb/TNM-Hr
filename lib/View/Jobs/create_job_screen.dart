import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../Provider/job_provider.dart';
import '../../services/user_storage.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();
  final _jobLocationController = TextEditingController();
  final _preferredLocationController = TextEditingController();
  final _officeAddressController = TextEditingController();
  final _floorDetailsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _totalExperienceController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final _openingsController = TextEditingController();
  final _documentsController = TextEditingController();
  final _jobTimingController = TextEditingController();
  
  // Dropdown values
  String _jobCategory = 'IT & Software';
  String _jobType = 'Full Time';
  String _planType = 'basic'; // Try 'basic' instead of 'free' or 'premium'
  String _salaryType = 'Fixed Only';
  String _workLocation = 'Work From Home';
  String _minimumEducation = "Bachelor's Degree";
  String _englishLevel = 'intermediate';
  String _gender = 'Both genders allowed';
  String _communicationPreference = 'phone';
  String _workingDays = 'monday-saturday';
  bool _isWalkInInterview = false;
  
  // Multi-select
  List<String> _selectedPerks = [];
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
    _loadCompanyName();
  }

  Future<void> _loadCompanyName() async {
    final userData = await UserStorage.getLoginData();
    _companyNameController.text = userData['company'] ?? '';
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

  Future<void> _createJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phone = await UserStorage.getPhone();
    final jobProvider = context.read<JobProvider>();

    final success = await jobProvider.createJob(
      hrPhone: phone,
      title: _titleController.text.trim(),
      companyName: _companyNameController.text.trim(),
      jobCategory: _jobCategory,
      jobType: _jobType,
      planType: _planType,
      salaryType: _salaryType,
      salaryRange: {
        'min': int.parse(_minSalaryController.text.trim()),
        'max': int.parse(_maxSalaryController.text.trim()),
      },
      workLocation: _workLocation,
      jobLocation: _jobLocationController.text.trim(),
      preferredLocation: _preferredLocationController.text.trim(),
      officeAddress: _officeAddressController.text.trim(),
      floorDetails: _floorDetailsController.text.trim(),
      coordinates: [
        double.parse(_latitudeController.text.trim()),
        double.parse(_longitudeController.text.trim()),
      ],
      minimumEducation: _minimumEducation,
      englishLevel: _englishLevel,
      totalExperience: _totalExperienceController.text.trim(),
      openingFor: 'Any', // Default value, you may want to add this to the form
      jobDescription: _jobDescriptionController.text.trim(),
      ageRange: {
        'min': int.parse(_minAgeController.text.trim()),
        'max': int.parse(_maxAgeController.text.trim()),
      },
      gender: _gender,
      openings: int.parse(_openingsController.text.trim()),
      isWalkInInterview: _isWalkInInterview,
      additionalPerks: _selectedPerks,
      documents: _documentsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      communicationPreference: _communicationPreference,
      workingDays: _workingDays,
      jobTiming: _jobTimingController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Job created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to create job. Please try again.'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _createJob(),
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
          'Create Job',
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work_outline, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Post a new job and find the perfect candidate',
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _titleController,
                label: 'Job Title',
                hint: 'e.g., Software Developer',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _companyNameController,
                label: 'Company Name',
                hint: 'e.g., TechNova Solutions',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jobDescriptionController,
                label: 'Job Description',
                hint: 'Detailed job description',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job description';
                  }
                  return null;
                },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jobLocationController,
                label: 'Job Location',
                hint: 'Noida, Uttar Pradesh',
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter office address';
                  }
                  return null;
                },
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
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      hint: '77.3649',
                      icon: Icons.map,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter experience';
                  }
                  return null;
                },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter openings';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _documentsController,
                label: 'Required Documents',
                hint: 'Resume',
                icon: Icons.description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter documents';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _jobTimingController,
                label: 'Job Timing',
                hint: '10:00 AM - 7:00 PM',
                icon: Icons.access_time,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter job timing';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Walk-in Interview'),
                value: _isWalkInInterview,
                onChanged: (value) {
                  setState(() {
                    _isWalkInInterview = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.buttonShadow],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createJob,
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Create Job',
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w600,
          ),
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
