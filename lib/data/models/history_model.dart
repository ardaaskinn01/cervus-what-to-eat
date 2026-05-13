class HistoryEntry {
  final String id;
  final String foodId;
  final String foodName;
  final DateTime date;
  final bool isEaten;
  final bool isRecommended;

  HistoryEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.date,
    required this.isEaten,
    required this.isRecommended,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'date': date.toIso8601String(),
      'isEaten': isEaten,
      'isRecommended': isRecommended,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      foodId: json['foodId'] as String,
      foodName: json['foodName'] as String,
      date: DateTime.parse(json['date'] as String),
      isEaten: json['isEaten'] as bool,
      isRecommended: json['isRecommended'] as bool,
    );
  }
}
