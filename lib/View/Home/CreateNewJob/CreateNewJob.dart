import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naukri_hr_app/View/Home/CreateNewJobDetails/CreateNewJobDetails.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';

import 'CustomTextField.dart';
import 'GenderSelector.dart';
import 'JobLocationType.dart';
import 'JobType.dart';
import 'MinimumQualification.dart';

class CreateNewJob extends StatefulWidget {
  const CreateNewJob({super.key});

  @override
  State<CreateNewJob> createState() => _CreateNewJobState();
}

class _CreateNewJobState extends State<CreateNewJob> {
  final _jobTitleController = TextEditingController();
  final _jobCategoryController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();
  final _openingsController = TextEditingController();

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
          "Create New Job",
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            _buildFormCard(),
            const SizedBox(height: 24),
            _buildNextButton(),
          ],
        ),
      ),
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
              Icons.work_outline_rounded,
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
                  "Job Information",
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Basic Job Details",
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          CustomTextField(label: "Job Title", controller: _jobTitleController),
          CustomTextField(
            label: "Job Category",
            controller: _jobCategoryController,
          ),
          CustomTextField(label: "Select City", controller: _cityController),
          CustomTextField(
            label: "Job Locality",
            controller: _localityController,
          ),
          CustomTextField(
            label: "Number of Openings",
            controller: _openingsController,
          ),

          const SizedBox(height: 20),
          _buildSectionTitle("Job Location Type"),
          const SizedBox(height: 12),
          const JobLocationType(),

          const SizedBox(height: 20),
          _buildSectionTitle("Job Type"),
          const SizedBox(height: 12),
          const JobType(),

          const SizedBox(height: 20),
          _buildSectionTitle("Gender Preference"),
          const SizedBox(height: 12),
          const GenderSelector(),

          const SizedBox(height: 20),
          _buildSectionTitle("Minimum Qualification"),
          const SizedBox(height: 12),
          const MinimumQualification(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subtitle2.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Save text field values to provider
          final formProvider = Provider.of<JobFormProvider>(context, listen: false);
          formProvider.setJobTitle(_jobTitleController.text);
          formProvider.setJobCategory(_jobCategoryController.text);
          formProvider.setCity(_cityController.text);
          formProvider.setLocality(_localityController.text);
          formProvider.setNumberOfOpenings(int.tryParse(_openingsController.text) ?? 1);
          
          // Selector widgets already save their values directly to provider
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateNewJobDetails()),
          );
        },
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
            Text(
              "Continue to Details",
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class CreateNewJob extends StatefulWidget {
//   const CreateNewJob({super.key});
//
//   @override
//   State<CreateNewJob> createState() => _CreateNewJobState();
// }
//
// class _CreateNewJobState extends State<CreateNewJob> {
//   final TextEditingController _jobTitleController = TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _officialMailController = TextEditingController();
//
//   String? selectedEmployeeSize;
//
//   final List<String> employeeSizes = [
//     "0 - 9",
//     "10 - 50",
//     "51 - 200",
//     "201 - 500",
//     "500+",
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: const Color(0xFFF6F8FE),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF6F8FE),
//         elevation: 0,
//         title: const Text(
//           "Create New Job",
//           style: TextStyle(
//             color: Color(0XFF1F64A6),
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//         ),
//         centerTitle: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Job Title
//             const Text(
//               "Job Title",
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _jobTitleController,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide: const BorderSide(color: Colors.black12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               "Company Name",
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _companyNameController,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide: const BorderSide(color: Colors.black12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Official Mail
//             const Text(
//               "Official Mail",
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             TextField(
//               controller: _officialMailController,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide: const BorderSide(color: Colors.black12),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Employee Size
//             const Text(
//               "Employee Size",
//               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             DropdownButtonFormField<String>(
//               value: selectedEmployeeSize,
//               items: employeeSizes
//                   .map(
//                     (size) => DropdownMenuItem(value: size, child: Text(size)),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedEmployeeSize = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                   borderSide: const BorderSide(color: Colors.black12),
//                 ),
//               ),
//             ),
//
//             SizedBox(height: 120),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0XFF1F64A6),
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       "Back",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0XFF1F64A6),
//                       elevation: 3,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () {},
//                     child: const Text(
//                       "Next",
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
