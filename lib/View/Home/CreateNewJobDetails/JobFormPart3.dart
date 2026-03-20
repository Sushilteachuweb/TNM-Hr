import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../Provider/job_form_provider.dart';

class JobFormPart3 extends StatefulWidget {
  const JobFormPart3({super.key});

  @override
  State<JobFormPart3> createState() => _JobFormPart3State();
}

class _JobFormPart3State extends State<JobFormPart3> {
  final TextEditingController descriptionController = TextEditingController();

  // Time options
  final List<String> hours = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  final List<String> minutes = ['00', '15', '30', '45'];
  final List<String> periods = ['AM', 'PM'];

  String startHour = '09';
  String startMinute = '00';
  String startPeriod = 'AM';
  String endHour = '06';
  String endMinute = '00';
  String endPeriod = 'PM';

  @override
  void initState() {
    super.initState();
    // Set initial job timing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formProvider = Provider.of<JobFormProvider>(context, listen: false);
      formProvider.setJobTiming('$startHour:$startMinute $startPeriod', '$endHour:$endMinute $endPeriod');
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Job Timing",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Start Time
        Text(
          "Start Time",
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: startHour,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    items: hours.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        startHour = newValue!;
                        formProvider.setJobTiming(
                          '$startHour:$startMinute $startPeriod',
                          '$endHour:$endMinute $endPeriod',
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: startMinute,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    items: minutes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        startMinute = newValue!;
                        formProvider.setJobTiming(
                          '$startHour:$startMinute $startPeriod',
                          '$endHour:$endMinute $endPeriod',
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: startPeriod,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    items: periods.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        startPeriod = newValue!;
                        formProvider.setJobTiming(
                          '$startHour:$startMinute $startPeriod',
                          '$endHour:$endMinute $endPeriod',
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // End Time
        Text(
          "End Time",
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: endHour,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    items: hours.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        endHour = newValue!;
                        formProvider.setJobTiming(
                          '$startHour:$startMinute $startPeriod',
                          '$endHour:$endMinute $endPeriod',
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: endMinute,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    items: minutes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        endMinute = newValue!;
                        formProvider.setJobTiming(
                          '$startHour:$startMinute $startPeriod',
                          '$endHour:$endMinute $endPeriod',
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: endPeriod,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                    style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
                    items: periods.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        endPeriod = newValue!;
                        formProvider.setJobTiming(
                          '$startHour:$startMinute $startPeriod',
                          '$endHour:$endMinute $endPeriod',
                        );
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          "Job Description",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          maxLines: 6,
          onChanged: (value) {
            formProvider.setJobDescription(value);
          },
          style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText:
                "Describe the job responsibilities, requirements, and what makes this opportunity special...",
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
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
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          "Communication Preferences",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Do you want candidates to contact you after they apply? *",
          style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        ...["Yes, to myself", "Yes, to other recruiter", "No, I will contact candidates first"]
            .map((option) => RadioListTile<String>(
                  title: Text(
                    option,
                    style: AppTextStyles.body2.copyWith(color: AppColors.textPrimary),
                  ),
                  value: option,
                  groupValue: formProvider.communicationPreference,
                  onChanged: (v) => formProvider.setCommunicationPreference(v!),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                )),
      ],
    );
  }
}
