import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'skeleton_loading.dart';

class SkeletonButton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const SkeletonButton({
    super.key,
    required this.isLoading,
    required this.child,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonLoading(
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
  }
}

class SkeletonIconButton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final VoidCallback? onPressed;
  final double size;

  const SkeletonIconButton({
    super.key,
    required this.isLoading,
    required this.child,
    this.onPressed,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonLoading(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: child,
    );
  }
}

class SkeletonTextField extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const SkeletonTextField({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonLoading(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
        ),
      );
    }

    return child;
  }
}