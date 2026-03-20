import 'package:flutter/material.dart';

class JobPlan {
  final String id;
  final String planName;
  final String description;
  final int pricePerMonth;
  final int originalPrice;
  final double discountPercent;
  final int credits;
  final int validityDays;
  final int jobActiveDays;
  final bool aiMatching;
  final int advancedFilters;
  final bool whatsappLead;
  final bool isRecommended;
  final bool isCustom;
  final int dbCredits;
  final double gstPercent;
  final double? gstAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobPlan({
    required this.id,
    required this.planName,
    required this.description,
    required this.pricePerMonth,
    required this.originalPrice,
    required this.discountPercent,
    required this.credits,
    required this.validityDays,
    required this.jobActiveDays,
    required this.aiMatching,
    required this.advancedFilters,
    required this.whatsappLead,
    required this.isRecommended,
    required this.isCustom,
    required this.dbCredits,
    required this.gstPercent,
    this.gstAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobPlan.fromJson(Map<String, dynamic> json) {
    return JobPlan(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      description: json['description'] ?? '',
      pricePerMonth: json['pricePerMonth'] ?? 0,
      originalPrice: json['originalPrice'] ?? 0,
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      credits: json['credits'] ?? 0,
      validityDays: json['validityDays'] ?? 0,
      jobActiveDays: json['jobActiveDays'] ?? 0,
      aiMatching: json['aiMatching'] ?? false,
      advancedFilters: json['advancedFilters'] ?? 0,
      whatsappLead: json['whatsappLead'] ?? false,
      isRecommended: json['isRecommended'] ?? false,
      isCustom: json['isCustom'] ?? false,
      dbCredits: json['dbCredits'] ?? 0,
      gstPercent: (json['gstPercent'] ?? 0).toDouble(),
      gstAmount: json['gstAmount'] != null ? (json['gstAmount']).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'description': description,
      'pricePerMonth': pricePerMonth,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'credits': credits,
      'validityDays': validityDays,
      'jobActiveDays': jobActiveDays,
      'aiMatching': aiMatching,
      'advancedFilters': advancedFilters,
      'whatsappLead': whatsappLead,
      'isRecommended': isRecommended,
      'isCustom': isCustom,
      'dbCredits': dbCredits,
      'gstPercent': gstPercent,
      if (gstAmount != null) 'gstAmount': gstAmount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get formattedPrice => "Rs. $pricePerMonth";
  String get formattedOriginalPrice => "Rs. $originalPrice";
  String get creditsText => "$credits Jobs Credits";
  String get validityText => "For ${_formatDays(validityDays)}";
  String get jobActiveText => "Job Active For $jobActiveDays Days";
  String get filtersText => "$advancedFilters + Advanced Filter";

  String _formatDays(int days) {
    if (days >= 30) {
      int months = (days / 30).round();
      return "$months Month${months > 1 ? 's' : ''}";
    }
    return "$days Days";
  }

  // Get gradient colors based on plan name
  List<Color> get gradientColors {
    switch (planName.toLowerCase()) {
      case 'silver plan':
      case 'silver':
        return [const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
      case 'gold plan':
      case 'gold':
        return [const Color(0xFFD97706), const Color(0xFFF59E0B)];
      case 'diamond plan':
      case 'diamond':
        return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
      default:
        return [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];
    }
  }
}