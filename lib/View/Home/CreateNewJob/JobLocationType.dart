import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_text_styles.dart';
import '../../../Provider/job_form_provider.dart';

class JobLocationType extends StatelessWidget {
  const JobLocationType({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<JobFormProvider>(context);
    final options = ["Work From Home", "Work From Office", "Field Job"];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: options.map((text) {
        final isSelected = formProvider.workLocationType == text;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [AppColors.cardShadow] : null,
          ),
          child: ChoiceChip(
            label: Text(
              text,
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
              formProvider.setWorkLocationType(text);
            },
          ),
        );
      }).toList(),
    );
  }
}
