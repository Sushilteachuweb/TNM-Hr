import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../Provider/job_form_provider.dart';

class JobFormPart1 extends StatefulWidget {
  const JobFormPart1({super.key});

  @override
  State<JobFormPart1> createState() => _JobFormPart1State();
}

class _JobFormPart1State extends State<JobFormPart1> {
  final TextEditingController minExpController = TextEditingController();
  final TextEditingController maxExpController = TextEditingController();
  final TextEditingController minSalaryController = TextEditingController();
  final TextEditingController maxSalaryController = TextEditingController();

  final openings = ["Fresher", "Experience", "Any"];
  final salaryTypes = ["Fixed", "Fixed + Incentive"];

  @override
  void dispose() {
    minExpController.dispose();
    maxExpController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Opening For",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: openings.map((item) {
            final isSelected = formProvider.totalExperience == item;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [AppColors.cardShadow] : null,
              ),
              child: ChoiceChip(
                label: Text(
                  item,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onSelected: (_) {
                  formProvider.setTotalExperience(item);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Text(
          "Experience",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minExpController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  formProvider.setExperienceRange(value, maxExpController.text);
                },
                decoration: InputDecoration(
                  hintText: "Min exp.",
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textHint,
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxExpController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  formProvider.setExperienceRange(minExpController.text, value);
                },
                decoration: InputDecoration(
                  hintText: "Max exp.",
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textHint,
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          "Salary & Benefits",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: salaryTypes.map((item) {
            final isSelected = formProvider.salaryType == item;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [AppColors.cardShadow] : null,
              ),
              child: ChoiceChip(
                label: Text(
                  item,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onSelected: (_) {
                  formProvider.setSalaryType(item);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Salary Range (Monthly)",
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Min: Rs 10,000",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus && minSalaryController.text.isNotEmpty) {
                    final salary = int.tryParse(minSalaryController.text) ?? 0;
                    if (salary < 10000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Minimum salary must be Rs 10,000'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: TextField(
                  controller: minSalaryController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    formProvider.setSalaryRange(value, maxSalaryController.text);
                  },
                  decoration: InputDecoration(
                    prefixText: "Rs ",
                    prefixStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: "10,000",
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: maxSalaryController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  formProvider.setSalaryRange(minSalaryController.text, value);
                },
                decoration: InputDecoration(
                  prefixText: "Rs ",
                  prefixStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  hintText: "15,000",
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.textHint,
                  ),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
