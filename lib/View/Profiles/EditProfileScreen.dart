import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/user_storage.dart';
import '../../services/hr_profile_api_service.dart';
import '../../services/session_manager.dart';
import '../../Provider/hr_profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditProfileScreen({super.key, required this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _designationController;
  late TextEditingController _experienceController;
  late TextEditingController _locationController;
  late TextEditingController _skillsController;
  late TextEditingController _bioController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData['userName'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.initialData['userEmail'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.initialData['phone'] ?? '',
    );
    _companyController = TextEditingController(
      text: widget.initialData['company'] ?? '',
    );
    _designationController = TextEditingController(
      text: widget.initialData['designation'] ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.initialData['experience'] ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialData['location'] ?? '',
    );
    _skillsController = TextEditingController(
      text: widget.initialData['skills'] ?? '',
    );
    _bioController = TextEditingController(
      text: widget.initialData['bio'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      try {
        // Validate selected image if provided
        File? validatedImage;
        if (_selectedImage != null) {
          final fileName = _selectedImage!.path.toLowerCase();
          final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
          final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));
          
          if (hasValidExtension) {
            validatedImage = _selectedImage;
          } else {
            // Show error and return
            if (mounted) {
              Navigator.pop(context); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Only image files are allowed (jpg, jpeg, png, gif, webp)"),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            return;
          }
        }

        // Call HR Profile Update API
        final result = await HrProfileApiService.updateHrProfile(
          fullName: _nameController.text,
          companyName: _companyController.text,
          email: _emailController.text,
          designation: _designationController.text,
          experience: _experienceController.text,
          hrLocation: _locationController.text,
          bio: _bioController.text,
          skills: _skillsController.text,
          profilePhoto: validatedImage, // Only pass validated image
        );

        // Handle session expiry
        if (!await SessionManager.checkAndHandleResponse(context, result)) {
          return; // Session expired, user redirected to login
        }

        // Only update local storage if API call succeeds
        if (result['success'] == true) {
          await UserStorage.updateUserProfile(
            userName: _nameController.text,
            userEmail: _emailController.text,
            company: _companyController.text,
            designation: _designationController.text,
            experience: _experienceController.text,
            location: _locationController.text,
            skills: _skillsController.text,
            bio: _bioController.text,
            profileImage: validatedImage?.path,
          );

          // Update HR Profile Provider
          if (mounted) {
            final hrProfileProvider = Provider.of<HrProfileProvider>(context, listen: false);
            await hrProfileProvider.loadProfileFromLocal();
          }
        }

        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Profile updated successfully',
              ),
              backgroundColor: result['success'] == true
                  ? AppColors.success
                  : AppColors.warning,
            ),
          );

          if (result['success'] == true) {
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Unable to update profile. Please try again."),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _saveProfile(),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    await _pickImageFromSource(ImageSource.gallery);
  }

  Future<void> _pickImageFromCamera() async {
    await _pickImageFromSource(ImageSource.camera);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 80,
      );

      if (image != null) {
        // Validate file extension
        final fileName = image.path.toLowerCase();
        final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
        final hasValidExtension = validExtensions.any((ext) => fileName.endsWith(ext));
        
        if (!hasValidExtension) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Only image files are allowed (jpg, jpeg, png, gif, webp)"),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Unable to select image. Please try again."),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _pickImageFromSource(source),
            ),
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text("Select Profile Photo", style: AppTextStyles.h4),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library_outlined,
                    title: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt_outlined,
                    title: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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
          "Edit Profile",
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: _selectedImage != null
                        ? ClipOval(
                            child: Image.file(
                              _selectedImage!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_add_rounded,
                            size: 50,
                            color: AppColors.primary,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _showImagePickerOptions,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Change Photo",
                        style: AppTextStyles.subtitle2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                Icons.person_outlined,
                "Full Name",
                _nameController,
                "Enter your name",
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.email_outlined,
                "Official Email",
                _emailController,
                "Enter your official email",
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.phone_outlined,
                "Phone",
                _phoneController,
                "Enter your phone",
                enabled: false, // Make phone number non-editable
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.business_outlined,
                "Company",
                _companyController,
                "Enter your company",
                isRequired: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.work_outline,
                "Designation",
                _designationController,
                "Enter your designation",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.trending_up,
                "Experience",
                _experienceController,
                "Enter years of experience (e.g., 5)",
                isNumeric: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.location_on_outlined,
                "Location",
                _locationController,
                "Enter your location",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.psychology_outlined,
                "Skills",
                _skillsController,
                "Enter your skills",
              ),
              const SizedBox(height: 16),
              _buildTextField(
                Icons.description_outlined,
                "Bio",
                _bioController,
                "Enter your bio",
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.buttonShadow],
                ),
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Save Changes",
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                          fontSize: 16,
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

  Widget _buildTextField(
    IconData icon,
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool enabled = true,
    bool isRequired = false,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric 
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2), // Limit to 2 digits (max 99 years)
            ]
          : null,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (isNumeric && value != null && value.isNotEmpty) {
          final numValue = int.tryParse(value);
          if (numValue == null) {
            return '$label must be a valid number';
          }
          if (numValue < 0) {
            return '$label cannot be negative';
          }
          if (numValue > 50) {
            return '$label seems too large (max 50 years)';
          }
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey),
        filled: true,
        fillColor: enabled ? AppColors.surface : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
