class ActivePlan {
  final bool active;
  final String planName;
  final String expiresOn;
  final int remainingDays;
  final int totalCredits;
  final int remainingCredits;

  ActivePlan({
    required this.active,
    required this.planName,
    required this.expiresOn,
    required this.remainingDays,
    required this.totalCredits,
    required this.remainingCredits,
  });

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    return ActivePlan(
      active: json['active'] ?? false,
      planName: json['planName'] ?? '',
      expiresOn: json['expiresOn'] ?? '',
      remainingDays: json['remainingDays'] ?? 0,
      totalCredits: json['totalCredits'] ?? 0,
      remainingCredits: json['remainingCredits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'planName': planName,
      'expiresOn': expiresOn,
      'remainingDays': remainingDays,
      'totalCredits': totalCredits,
      'remainingCredits': remainingCredits,
    };
  }

  // Helper methods for UI display
  String get formattedExpiresOn {
    try {
      final date = DateTime.parse(expiresOn);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return expiresOn;
    }
  }

  String get remainingDaysText {
    if (remainingDays <= 0) return 'Expired';
    if (remainingDays == 1) return '1 day left';
    return '$remainingDays days left';
  }

  String get creditsText => '$remainingCredits/$totalCredits credits';
}