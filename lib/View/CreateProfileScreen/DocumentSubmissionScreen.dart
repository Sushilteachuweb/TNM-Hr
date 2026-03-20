import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bottomNavBar/bottomNavBar.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../services/user_storage.dart';
import '../../services/auth_api_service.dart';
import '../../services/app_data_manager.dart';
import 'dart:io';

class DocumentSubmissionScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String companyName;
  final String totalEmp;
  final File? profileImage;

  const DocumentSubmissionScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.companyName,
    required this.totalEmp,
    this.profileImage,
  });

  @override
  State<DocumentSubmissionScreen> createState() => _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState extends State<DocumentSubmissionScreen> {
  File? _selectedDocument;
  String? _documentFileName;
  bool _isLoading = false;

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedDocument = File(result.files.single.path!);
          _documentFileName = result.files.single.name;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unable to select document: ${e.message}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Unable to select document. Please try again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageAsDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedDocument = File(image.path);
          _documentFileName = image.name;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unable to select image: ${e.message}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Unable to select image. Please try again."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDocumentPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
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
              Text("Select Document", style: AppTextStyles.h4),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.insert_drive_file_outlined,
                      title: "File",
                      subtitle: "PDF, JPG, PNG",
                      onTap: () {
                        Navigator.pop(context);
                        _pickDocument();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPickerOption(
                      icon: Icons.photo_library_outlined,
                      title: "Gallery",
                      subtitle: "Image",
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageAsDocument();
                      },
                    ),
                  ),
                ],
              ),
              if (_selectedDocument != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedDocument = null;
                        _documentFileName = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Remove Document"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.subtitle2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitProfile() async {
    if (_selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload a company verification document'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Get phone from storage
    final phone = await UserStorage.getPhone();

    // Call signup API with document
    final result = await AuthApiService.signupWithDocument(
      fullName: widget.fullName,
      phone: phone,
      email: widget.email,
      companyName: widget.companyName,
      totalEmp: widget.totalEmp,
      verificationDocument: _selectedDocument!,
      profilePhoto: widget.profileImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      // Save hrId and userId if returned from signup
      if (result['hrId'] != null || result['userId'] != null) {
        await UserStorage.saveLoginData(
          phone: phone,
          isExistingUser: false,
          hrId: result['hrId'],
          userId: result['userId'],
        );
      }

      // Extract profilePhoto and verificationDocument URLs from API response
      String? profilePhotoUrl;
      String? verificationDocumentUrl;
      
      // Check the response structure
      print('📦 Full API Response: ${result['data']}');
      
      if (result['data'] != null) {
        // Try nested data.data structure first
        if (result['data']['data'] != null) {
          profilePhotoUrl = result['data']['data']['profilePhoto']?.toString();
          verificationDocumentUrl = result['data']['data']['verificationDocument']?.toString();
          print('📸 Profile Photo URL (nested): $profilePhotoUrl');
          print('📄 Verification Document URL (nested): $verificationDocumentUrl');
        } else {
          // Try direct data structure
          profilePhotoUrl = result['data']['profilePhoto']?.toString();
          verificationDocumentUrl = result['data']['verificationDocument']?.toString();
          print('📸 Profile Photo URL (direct): $profilePhotoUrl');
          print('📄 Verification Document URL (direct): $verificationDocumentUrl');
        }
      }

      // Update local storage with API response data
      await UserStorage.updateUserProfile(
        userName: widget.fullName,
        userEmail: widget.email,
        company: widget.companyName,
        profileImage: profilePhotoUrl, // Use URL from API instead of local path
        verificationDocument: verificationDocumentUrl, // Save verification document URL
      );

      // Mark profile as fully completed
      await UserStorage.setProfileComplete(true);
      
      print('✅ Saved to storage - verificationDocument: $verificationDocumentUrl');

      print("✅ Profile created successfully");

      // Initialize app data for new users
      print("🚀 Initializing app data after profile creation...");
      await AppDataManager.initializeAppData(context);
      print("✅ App data initialization completed after profile creation");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomNavBar(
            showProfileCompletionSnackbar: true,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Unable to create profile. Please try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Document Verification",
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildDocumentSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
              _buildContactNote(),
              const SizedBox(height: 12),
              _buildSupportSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Document Verification Required",
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Upload any 1 company document to complete your profile",
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Company Verification Document",
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "(Note: DO NOT upload your personal documents)",
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildDocumentOptions(),
          const SizedBox(height: 20),
          if (_selectedDocument != null) _buildSelectedDocument(),
          if (_selectedDocument == null) _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildDocumentOptions() {
    final documents = [
      {"icon": "📄", "name": "Company GST Certificate"},
      {"icon": "🏢", "name": "Company PAN Card"},
      {"icon": "📋", "name": "FSSAI License"},
      {"icon": "🎓", "name": "Company Incorporation Certificate"},
      {"icon": "🏪", "name": "Shop & Establishment Certificate"},
      {"icon": "📊", "name": "MSME Registration Certificate"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Accepted Documents:",
          style: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ...documents.map((doc) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                doc["icon"]!,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  doc["name"]!,
                  style: AppTextStyles.body2,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSelectedDocument() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Document Selected",
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _documentFileName ?? "Document",
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDocument = null;
                _documentFileName = null;
              });
            },
            icon: Icon(
              Icons.close,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return InkWell(
      onTap: _showDocumentPickerOptions,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              "Upload Document",
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "PDF, JPG, PNG (Max 10MB)",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitProfile,
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
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Complete Profile",
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildContactNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "If you do not have any document as mentioned above, contact us for registration assistance.",
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: "Need help? Reach us at "),
            WidgetSpan(
              child: InkWell(
                onTap: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: '01169268889');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                },
                child: Text(
                  "01169268889",
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const TextSpan(text: " or visit our "),
            WidgetSpan(
              child: InkWell(
                onTap: () async {
                  final Uri url = Uri.parse('https://www.thenaukrimitra.com/contactus');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  "support page",
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
