import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';

class JobType extends StatelessWidget {
  const JobType({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    // Map display text to API values
    // Try different formats to match API expectations
    final Map<String, String> jobTypeOptions = {
      "Full Time": "Full Time",
      "Part Time": "Part Time", 
      "Internship": "Internship",
    };

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: jobTypeOptions.entries.map((entry) {
        final displayText = entry.key;
        final apiValue = entry.value;
        final isSelected = formProvider.jobType == apiValue;
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [AppColors.cardShadow] : null,
          ),
          child: ChoiceChip(
            label: Text(
              displayText,
              style: AppTextStyles.body2.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: isSelected,
            backgroundColor: AppColors.surfaceLight,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onSelected: (_) {
              formProvider.setJobType(apiValue);
            },
          ),
        );
      }).toList(),
    );
  }
}
