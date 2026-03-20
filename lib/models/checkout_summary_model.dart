class CheckoutSummary {
  final String planId;
  final String planName;
  final int validityDays;
  final int credits;
  final double originalPrice;
  final double discountPercent;
  final double discountAmount;
  final double basePrice;
  final double gstPercent;
  final double gstAmount;
  final double finalPrice;

  CheckoutSummary({
    required this.planId,
    required this.planName,
    required this.validityDays,
    required this.credits,
    required this.originalPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.basePrice,
    required this.gstPercent,
    required this.gstAmount,
    required this.finalPrice,
  });

  factory CheckoutSummary.fromJson(Map<String, dynamic> json) {
    return CheckoutSummary(
      planId: json['planId'] ?? '',
      planName: json['planName'] ?? '',
      validityDays: (json['validityDays'] ?? 0).toInt(),
      credits: (json['credits'] ?? 0).toInt(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      gstPercent: (json['gstPercent'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
    );
  }
}
