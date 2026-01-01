import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:naukri_hr_app/View/Home/CreateNewJobDetails/subscription/subscription.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';
import '../../../Provider/hr_profile_provider.dart';
import '../../../services/user_storage.dart';

import 'JobFormPart1.dart';
import 'JobFormPart2.dart';
import 'JobFormPart3.dart';

class CreateNewJobDetails extends StatefulWidget {
  const CreateNewJobDetails({super.key});

  @override
  State<CreateNewJobDetails> createState() => _CreateNewJobDetailsState();
}

class _CreateNewJobDetailsState extends State<CreateNewJobDetails> {
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
              Icons.description_outlined,
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
                  "Job Details",
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
            "Complete Job Information",
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          JobFormPart1(),
          const SizedBox(height: 20),
          JobFormPart2(),
          const SizedBox(height: 20),
          JobFormPart3(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.buttonShadow],
        ),
        child: ElevatedButton(
          onPressed: () async {
            // Get providers
            final formProvider = Provider.of<JobFormProvider>(context, listen: false);
            final hrProfileProvider = Provider.of<HrProfileProvider>(context, listen: false);
            
            // Get phone number from profile provider or fallback to UserStorage
            String hrPhone = hrProfileProvider.hrPhone;
            if (hrPhone.isEmpty) {
              hrPhone = await UserStorage.getPhone();
            }
            
            // Validate required fields
            if (hrPhone.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Phone number is required. Please update your profile.'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            
            // Get job data with form values + HR profile data
            final jobData = formProvider.getJobData(
              hrPhone: hrPhone,
              coordinates: hrProfileProvider.coordinates,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Subscription(jobData: jobData),
              ),
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
                "Submit Job",
                style: AppTextStyles.button.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class Createnewjobdetails extends StatefulWidget {
//   const Createnewjobdetails({super.key});
//
//   @override
//   State<Createnewjobdetails> createState() => _CreatenewjobdetailsState();
// }
//
// class _CreatenewjobdetailsState extends State<Createnewjobdetails> {
//   String openingFor = 'Any';
//   String salaryType = 'Fixed + Incentived';
//   List<String> jobBenefits = [];
//   List<String> documentsRequired = [];
//   List<String> workingDays = [];
//   TimeOfDay? startTime;
//   TimeOfDay? endTime;
//   bool allowCall = true;
//   bool allowWhatsApp = true;
//
//   final TextEditingController minExpController = TextEditingController();
//   final TextEditingController maxExpController = TextEditingController();
//   final TextEditingController minSalaryController = TextEditingController();
//   final TextEditingController maxSalaryController = TextEditingController();
//   final TextEditingController jobDescriptionController =
//       TextEditingController();
//
//   Widget buildChoiceChip(
//     String label,
//     bool selected,
//     VoidCallback onTap, {
//     Color color = Colors.blue,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: selected ? color : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(color: selected ? Colors.white : Colors.black),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTimePicker(
//     String label,
//     TimeOfDay? time,
//     void Function(TimeOfDay) onPicked,
//   ) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () async {
//           TimeOfDay? picked = await showTimePicker(
//             context: context,
//             initialTime: time ?? TimeOfDay(hour: 9, minute: 0),
//           );
//           if (picked != null) onPicked(picked);
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Text(time != null ? time.format(context) : label),
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField(TextEditingController controller, String hint) {
//     return Expanded(
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           hintText: hint,
//           border: const OutlineInputBorder(),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 6,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Create Job Details',
//           style: TextStyle(
//             color: Color(0XFF1F64A6),
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Opening For",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               children: ['Fresher', 'Experience', 'Any']
//                   .map(
//                     (e) => buildChoiceChip(
//                       e,
//                       openingFor == e,
//                       () => setState(() => openingFor = e),
//                     ),
//                   )
//                   .toList(),
//             ),
//
//             const SizedBox(height: 15),
//             const Text("Experience"),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 buildTextField(minExpController, "Min exp."),
//                 const SizedBox(width: 10),
//                 buildTextField(maxExpController, "Max exp."),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text("Salary & Benefits"),
//             const SizedBox(height: 6),
//             Row(
//               children: ['Fixed', 'Fixed + Incentived']
//                   .map(
//                     (e) => buildChoiceChip(
//                       e,
//                       salaryType == e,
//                       () => setState(() => salaryType = e),
//                       color: Colors.orange,
//                     ),
//                   )
//                   .toList(),
//             ),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 buildTextField(minSalaryController, "Rs. Min"),
//                 const SizedBox(width: 10),
//                 buildTextField(maxSalaryController, "Rs. Max"),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text("Job Benefits"),
//             const SizedBox(height: 6),
//             Wrap(
//               spacing: 8,
//               children: ['Medical', 'PF', 'Cash', 'Insurance']
//                   .map(
//                     (e) => buildChoiceChip(
//                       e,
//                       jobBenefits.contains(e),
//                       () => setState(
//                         () => jobBenefits.contains(e)
//                             ? jobBenefits.remove(e)
//                             : jobBenefits.add(e),
//                       ),
//                       color: Colors.orange,
//                     ),
//                   )
//                   .toList(),
//             ),
//             const SizedBox(height: 12),
//             const Text("Documents Required"),
//             const SizedBox(height: 6),
//             Wrap(
//               spacing: 8,
//               children: ['Aadhar Card', 'Pan Card', 'Bank Account']
//                   .map(
//                     (e) => buildChoiceChip(
//                       e,
//                       documentsRequired.contains(e),
//                       () => setState(
//                         () => documentsRequired.contains(e)
//                             ? documentsRequired.remove(e)
//                             : documentsRequired.add(e),
//                       ),
//                       color: Colors.orange,
//                     ),
//                   )
//                   .toList(),
//             ),
//             const SizedBox(height: 12),
//             const Text("Working Days"),
//             const SizedBox(height: 6),
//             Wrap(
//               spacing: 8,
//               children: ['Mon - Friday', 'Mon - Saturday', 'Others']
//                   .map(
//                     (e) => buildChoiceChip(
//                       e,
//                       workingDays.contains(e),
//                       () => setState(
//                         () => workingDays.contains(e)
//                             ? workingDays.remove(e)
//                             : workingDays.add(e),
//                       ),
//                       color: Colors.orange,
//                     ),
//                   )
//                   .toList(),
//             ),
//             const SizedBox(height: 12),
//             const Text("Job Timing"),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 buildTimePicker(
//                   "09:00 am",
//                   startTime,
//                   (t) => setState(() => startTime = t),
//                 ),
//                 const SizedBox(width: 10),
//                 buildTimePicker(
//                   "06:00 pm",
//                   endTime,
//                   (t) => setState(() => endTime = t),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             const Text("Job Description"),
//             const SizedBox(height: 6),
//             TextField(
//               controller: jobDescriptionController,
//               maxLines: 5,
//               decoration: const InputDecoration(
//                 hintText: "USE HERE TEXT ",
//                 border: OutlineInputBorder(),
//                 contentPadding: EdgeInsets.all(12),
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text("Communication Preference"),
//             CheckboxListTile(
//               value: allowCall,
//               onChanged: (val) => setState(() => allowCall = val!),
//               title: const Text("Allow Call on +91XXXXXXX (Edit)"),
//             ),
//             CheckboxListTile(
//               value: allowWhatsApp,
//               onChanged: (val) => setState(() => allowWhatsApp = val!),
//               title: const Text("Whats App on +91XXXXXXX (Edit)"),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey,
//                     ),
//                     child: const Text("Back"),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     child: const Text("Next"),
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
