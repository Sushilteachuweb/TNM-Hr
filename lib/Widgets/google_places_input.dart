import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class GooglePlacesInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Function(Prediction) onPlaceSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;

  const GooglePlacesInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onPlaceSelected,
    this.validator,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GooglePlaceAutoCompleteTextField(
          textEditingController: controller,
          focusNode: focusNode,
          googleAPIKey: "AIzaSyAAxbBbwAa5E2Zr8PfLBVQeGNaJSYz6154",
          boxDecoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          inputDecoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(icon, color: enabled ? AppColors.primary : Colors.grey),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          debounceTime: 600,
          countries: const ["in"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            onPlaceSelected(prediction);
          },
          itemClick: (Prediction prediction) {
            controller.text = prediction.description ?? "";
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0),
            );
            // Unfocus to dismiss keyboard and prevent further input issues
            if (focusNode != null) {
              focusNode!.unfocus();
            }
          },
          seperatedBuilder: const Divider(),
          containerHorizontalPadding: 10,
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      prediction.description ?? "",
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
            );
          },
          isCrossBtnShown: true,
        ),
      ],
    );
  }
}
