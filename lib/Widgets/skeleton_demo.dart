import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'skeleton_loading.dart';
import 'skeleton_components.dart';
import 'skeleton_button.dart';

class SkeletonDemo extends StatefulWidget {
  const SkeletonDemo({super.key});

  @override
  State<SkeletonDemo> createState() => _SkeletonDemoState();
}

class _SkeletonDemoState extends State<SkeletonDemo> {
  bool _showSkeleton = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Skeleton Loading Demo',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Switch(
            value: _showSkeleton,
            onChanged: (value) {
              setState(() {
                _showSkeleton = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Toggle the switch to see skeleton loading in action',
              style: AppTextStyles.body1,
            ),
            const SizedBox(height: 20),
            
            // Basic skeleton components
            Text('Basic Components:', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            
            SkeletonLoading(
              isLoading: _showSkeleton,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SkeletonAvatar(size: 50),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SkeletonText(width: double.infinity, height: 18),
                              const SizedBox(height: 6),
                              const SkeletonText(width: 150, height: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SkeletonText(width: double.infinity, height: 14),
                    const SizedBox(height: 8),
                    const SkeletonText(width: 200, height: 14),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Home screen skeleton
            Text('Home Screen Skeleton:', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            
            if (_showSkeleton)
              const SizedBox(
                height: 300,
                child: HomeScreenSkeleton(),
              )
            else
              Container(
                height: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dashboard', style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text('Manage your hiring', style: AppTextStyles.body2),
                    const SizedBox(height: 20),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Welcome Card',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Stats',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Stats',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Job list skeleton
            Text('Job List Skeleton:', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            
            if (_showSkeleton)
              const SizedBox(
                height: 200,
                child: JobListSkeleton(),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Active',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                            Text('5 Applicants', style: AppTextStyles.caption),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Software Developer', style: AppTextStyles.subtitle1),
                        const SizedBox(height: 4),
                        Text('₹25,000 - ₹40,000/mo', style: AppTextStyles.body2),
                        Text('Mumbai, Maharashtra', style: AppTextStyles.body2),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Button skeleton
            Text('Button Skeleton:', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: SkeletonButton(
                    isLoading: _showSkeleton,
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Primary Button'),
                  ),
                ),
                const SizedBox(width: 12),
                SkeletonIconButton(
                  isLoading: _showSkeleton,
                  onPressed: () {},
                  child: Icon(Icons.favorite, color: AppColors.primary),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Text field skeleton
            Text('Text Field Skeleton:', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            
            SkeletonTextField(
              isLoading: _showSkeleton,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}