import 'package:flutter/material.dart';

class BillingHistory {
  final String id;
  final String date;
  final String time;
  final String planName;
  final String planId;
  final String expiresOn;
  final int amount;
  final String status;
  final String paymentId;
  final String orderId;
  final DateTime createdAt;

  BillingHistory({
    required this.id,
    required this.date,
    required this.time,
    required this.planName,
    required this.planId,
    required this.expiresOn,
    required this.amount,
    required this.status,
    required this.paymentId,
    required this.orderId,
    required this.createdAt,
  });

  factory BillingHistory.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String());
    
    return BillingHistory(
      id: json['_id'] ?? '',
      date: formatDate(createdAt),
      time: formatTime(createdAt),
      planName: json['planName'] ?? json['planDetails']?['planName'] ?? 'Unknown Plan',
      planId: json['planId'] ?? '',
      expiresOn: json['expiresOn'] ?? 'N/A',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'Pending',
      paymentId: json['paymentId'] ?? '',
      orderId: json['orderId'] ?? '',
      createdAt: createdAt,
    );
  }

  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)}';
  }

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'pm' : 'am';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedDateTime => '$date\n$time';
  String get formattedAmount => '₹$amount';
  
  // Get status color based on status
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return const Color(0xFF10B981); // AppColors.success
      case 'pending':
        return const Color(0xFFF59E0B); // AppColors.warning
      case 'failed':
      case 'cancelled':
        return const Color(0xFFEF4444); // AppColors.error
      default:
        return const Color(0xFF64748B); // AppColors.textSecondary
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'planName': planName,
      'planId': planId,
      'expiresOn': expiresOn,
      'amount': amount,
      'status': status,
      'paymentId': paymentId,
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}