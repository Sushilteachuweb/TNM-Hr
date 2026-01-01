import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_text_styles.dart';
import '../../../../Provider/job_form_provider.dart';

class JobFormPart2 extends StatefulWidget {
  const JobFormPart2({super.key});

  @override
  State<JobFormPart2> createState() => _JobFormPart2State();
}

class _JobFormPart2State extends State<JobFormPart2> {
  final TextEditingController perkController = TextEditingController();
  
  final benefits = ["Medical", "PF", "Cab", "Insurance"];
  final documents = ["Aadhar Card", "Pan Card", "Bank Account"];
  final workingDays = ["Mon - Friday", "Mon - Saturday", "Others"];

  @override
  void dispose() {
    perkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<JobFormProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Job Benefits",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: benefits.map((item) {
            final isSelected = formProvider.additionalPerks.contains(item);
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
                  formProvider.toggleAdditionalPerk(item);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: perkController,
                decoration: InputDecoration(
                  hintText: "Add more Perks...",
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
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppColors.buttonShadow],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (perkController.text.isNotEmpty) {
                    formProvider.addPerk(perkController.text);
                    perkController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Add +",
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          "Documents Required",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: documents.map((item) {
            final isSelected = formProvider.documentsRequired.contains(item);
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
                  formProvider.toggleDocument(item);
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Text(
          "Working Days",
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: workingDays.map((item) {
            final isSelected = formProvider.workingDays == item;
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
                  formProvider.setWorkingDays(item);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
