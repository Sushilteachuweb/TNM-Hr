class JobCategory {
  final String id;
  final String image;
  final String jobCategory;
  final List<String> subcategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobCategory({
    required this.id,
    required this.image,
    required this.jobCategory,
    required this.subcategories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['_id'] ?? '',
      image: json['image'] ?? '',
      jobCategory: json['jobCategory'] ?? '',
      subcategories: List<String>.from(json['subcategories'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'jobCategory': jobCategory,
      'subcategories': subcategories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class JobCategoryResponse {
  final bool success;
  final String message;
  final List<JobCategory> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  JobCategoryResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory JobCategoryResponse.fromJson(Map<String, dynamic> json) {
    return JobCategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => JobCategory.fromJson(item))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}