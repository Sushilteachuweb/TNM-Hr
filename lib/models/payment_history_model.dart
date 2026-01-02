import 'package:flutter/material.dart';

class PaymentHistory {
  final String id;
  final String userId;
  final String planId;
  final String orderId;
  final String? paymentId;
  final String? signature;
  final int amount;
  final String receipt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? validFrom;
  final DateTime? validUntil;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.planId,
    required this.orderId,
    this.paymentId,
    this.signature,
    required this.amount,
    required this.receipt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.validFrom,
    this.validUntil,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      planId: json['planId'] ?? '',
      orderId: json['orderId'] ?? '',
      paymentId: json['paymentId'],
      signature: json['signature'],
      amount: json['amount'] ?? 0,
      receipt: json['receipt'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom']).toLocal() : null,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'planId': planId,
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
      'amount': amount,
      'receipt': receipt,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year.toString().substring(2)}';
  }

  String get formattedTime {
    int hour = createdAt.hour;
    final period = hour >= 12 ? 'pm' : 'am';
    
    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12; // Midnight: 00:xx -> 12:xx am
    } else if (hour > 12) {
      hour = hour - 12; // Afternoon/Evening: 13:xx -> 1:xx pm
    }
    // hour == 12 stays as 12 (noon: 12:xx pm)
    
    return '${hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedUpdatedDate {
    return '${updatedAt.day.toString().padLeft(2, '0')}/${updatedAt.month.toString().padLeft(2, '0')}/${updatedAt.year.toString().substring(2)}';
  }

  String get formattedUpdatedTime {
    int hour = updatedAt.hour;
    final period = hour >= 12 ? 'pm' : 'am';
    
    // Convert to 12-hour format
    if (hour == 0) {
      hour = 12; // Midnight: 00:xx -> 12:xx am
    } else if (hour > 12) {
      hour = hour - 12; // Afternoon/Evening: 13:xx -> 1:xx pm
    }
    // hour == 12 stays as 12 (noon: 12:xx pm)
    
    return '${hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')} $period';
  }

  String get formattedUpdatedDateTime => '$formattedUpdatedDate $formattedUpdatedTime';
  String get formattedAmount => '₹$amount';

  // Get status color based on status
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xFF10B981); // AppColors.success
      case 'pending':
        return const Color(0xFFF59E0B); // AppColors.warning
      case 'failed':
        return const Color(0xFFEF4444); // AppColors.error
      default:
        return const Color(0xFF64748B); // AppColors.textSecondary
    }
  }

  String get validityPeriod {
    if (validFrom != null && validUntil != null) {
      final fromDate = '${validFrom!.day}/${validFrom!.month}/${validFrom!.year}';
      final toDate = '${validUntil!.day}/${validUntil!.month}/${validUntil!.year}';
      return '$fromDate - $toDate';
    }
    return 'N/A';
  }
}