import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'skeleton_loading.dart';

// Home screen skeleton
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SkeletonText(width: 120, height: 24),
                    const SizedBox(height: 5),
                    const SkeletonText(width: 150, height: 16),
                  ],
                ),
                const SkeletonContainer(width: 80, height: 36, borderRadius: BorderRadius.all(Radius.circular(20))),
              ],
            ),
            const SizedBox(height: 18),
            
            // Welcome card skeleton
            const SkeletonCard(height: 140),
            const SizedBox(height: 18),
            
            // Stats grid skeleton
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(4, (index) => Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [AppColors.cardShadow],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonContainer(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(6))),
                        SkeletonContainer(width: 14, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))),
                      ],
                    ),
                    SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonText(width: 35, height: 14),
                        SizedBox(height: 2),
                        SkeletonText(width: 50, height: 10),
                      ],
                    ),
                  ],
                ),
              )),
            ),
            const SizedBox(height: 18),
            
            // Recent jobs section skeleton
            Row(
              children: [
                const SkeletonContainer(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(10))),
                const SizedBox(width: 12),
                const SkeletonText(width: 100, height: 20),
              ],
            ),
            const SizedBox(height: 16),
            
            // Job cards skeleton
            ...List.generate(3, (index) => const SkeletonCard(height: 200)),
          ],
        ),
      ),
    );
  }
}

// Job list skeleton
class JobListSkeleton extends StatelessWidget {
  const JobListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Tab bar skeleton
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(3, (index) => 
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkeletonText(width: 60, height: 14),
                        SizedBox(height: 4),
                        SkeletonText(width: 20, height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Job cards skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (context, index) => const SkeletonCard(height: 220),
            ),
          ),
        ],
      ),
    );
  }
}

// Plans screen skeleton
class PlansScreenSkeleton extends StatelessWidget {
  const PlansScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonText(width: 250, height: 16),
            const SizedBox(height: 24),
            
            // Plan cards skeleton
            ...List.generate(3, (index) => 
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SkeletonText(width: 120, height: 20),
                                const SizedBox(height: 4),
                                const SkeletonText(width: 180, height: 14),
                              ],
                            ),
                          ),
                          if (index == 0) const SkeletonContainer(width: 100, height: 24, borderRadius: BorderRadius.all(Radius.circular(20))),
                        ],
                      ),
                    ),
                    
                    // Pricing
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const SkeletonText(width: 80, height: 32),
                          const SizedBox(width: 8),
                          const SkeletonText(width: 60, height: 16),
                          const SizedBox(width: 8),
                          const SkeletonContainer(width: 60, height: 20, borderRadius: BorderRadius.all(Radius.circular(8))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Features
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (featureIndex) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const SkeletonContainer(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(8))),
                                const SizedBox(width: 12),
                                const SkeletonText(width: 150, height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: const SkeletonContainer(width: double.infinity, height: 48, borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Job details skeleton
class JobDetailsSkeleton extends StatelessWidget {
  const JobDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header card skeleton
            const SkeletonCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonText(width: double.infinity, height: 24),
                          SizedBox(height: 4),
                          SkeletonText(width: 120, height: 16),
                        ],
                      ),
                    ),
                    SkeletonContainer(width: 80, height: 28, borderRadius: BorderRadius.all(Radius.circular(20))),
                  ],
                ),
                SizedBox(height: 16),
                SkeletonContainer(width: double.infinity, height: 40, borderRadius: BorderRadius.all(Radius.circular(8))),
                SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonText(width: 100, height: 12),
                    SizedBox(width: 16),
                    SkeletonText(width: 120, height: 12),
                  ],
                ),
              ],
            ),
            
            // Multiple info cards skeleton
            ...List.generate(6, (index) => 
              SkeletonCard(
                children: [
                  SkeletonText(width: 150, height: 18),
                  SizedBox(height: 12),
                  ...List.generate(2, (i) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SkeletonContainer(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(4))),
                          SizedBox(width: 12),
                          SkeletonText(width: 180, height: 12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile screen skeleton
class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile header skeleton
            const SkeletonAvatar(size: 100),
            const SizedBox(height: 16),
            const SkeletonText(width: 150, height: 20),
            const SizedBox(height: 8),
            const SkeletonText(width: 200, height: 16),
            const SizedBox(height: 32),
            
            // Profile info cards skeleton
            ...List.generate(5, (index) => 
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SkeletonContainer(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(4))),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SkeletonText(width: 120, height: 16),
                          SizedBox(height: 4),
                          SkeletonText(width: 180, height: 14),
                        ],
                      ),
                    ),
                    const SkeletonContainer(width: 16, height: 16, borderRadius: BorderRadius.all(Radius.circular(4))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Billing history skeleton
class BillingHistorySkeleton extends StatelessWidget {
  const BillingHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoading(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SkeletonContainer(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(4))),
                      const SizedBox(width: 12),
                      const SkeletonText(width: 120, height: 18),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Filter buttons
                  Row(
                    children: List.generate(4, (index) => 
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const SkeletonContainer(width: 60, height: 28, borderRadius: BorderRadius.all(Radius.circular(6))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: SkeletonText(width: 80, height: 14)),
                  Expanded(flex: 2, child: SkeletonText(width: 60, height: 14)),
                  Expanded(flex: 2, child: SkeletonText(width: 50, height: 14)),
                ],
              ),
            ),
            
            // Table rows
            ...List.generate(5, (index) => 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SkeletonText(width: 100, height: 14),
                          const SizedBox(height: 2),
                          const SkeletonText(width: 80, height: 12),
                          const SizedBox(height: 4),
                          const SkeletonText(width: 90, height: 12),
                        ],
                      ),
                    ),
                    const Expanded(flex: 2, child: SkeletonText(width: 60, height: 14)),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: SkeletonContainer(width: 60, height: 20, borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          const SizedBox(width: 8),
                          const SkeletonContainer(width: 18, height: 18, borderRadius: BorderRadius.all(Radius.circular(4))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}