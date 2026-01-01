import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SkeletonLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration duration;

  const SkeletonLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isLoading) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(SkeletonLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.transparent,
                Colors.white54,
                Colors.transparent,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

// Basic skeleton container
class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

// Skeleton text line
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 16,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: width,
      height: height,
      margin: margin,
      borderRadius: BorderRadius.circular(height / 2),
    );
  }
}

// Skeleton avatar/circle
class SkeletonAvatar extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonAvatar({
    super.key,
    this.size = 40,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: size,
      height: size,
      margin: margin,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

// Skeleton card
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final List<Widget>? children;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: children != null ? null : (height ?? 120), // Only use fixed height for default content
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.cardShadow],
      ),
      child: children != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children!,
            )
          : SizedBox(
              height: height ?? 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonText(width: 80, height: 12),
                      const SkeletonText(width: 60, height: 12),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const SkeletonText(width: double.infinity, height: 14),
                  const SizedBox(height: 4),
                  const SkeletonText(width: 150, height: 12),
                ],
              ),
            ),
    );
  }
}