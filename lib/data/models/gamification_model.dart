class GamificationModel {
  final int xp;
  final int streakDays;
  final List<String> unlockedBadges;
  final DateTime? lastActionDate; // to calculate streak

  GamificationModel({
    required this.xp,
    required this.streakDays,
    required this.unlockedBadges,
    this.lastActionDate,
  });

  GamificationModel copyWith({
    int? xp,
    int? streakDays,
    List<String>? unlockedBadges,
    DateTime? lastActionDate,
  }) {
    return GamificationModel(
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastActionDate: lastActionDate ?? this.lastActionDate,
    );
  }

  factory GamificationModel.fromJson(Map<String, dynamic> json) {
    return GamificationModel(
      xp: json['xp'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
      lastActionDate: json['lastActionDate'] != null ? DateTime.parse(json['lastActionDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'streakDays': streakDays,
    'unlockedBadges': unlockedBadges,
    'lastActionDate': lastActionDate?.toIso8601String(),
  };
}
