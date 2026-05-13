class WeeklyPlanModel {
  final Map<int, Map<String, String>> plan; // dayOfWeek (1-7) -> { 'Sabah': foodId, 'Öğle': foodId, 'Akşam': foodId }

  WeeklyPlanModel({required this.plan});

  factory WeeklyPlanModel.fromJson(Map<String, dynamic> json) {
    Map<int, Map<String, String>> parsedPlan = {};
    json.forEach((key, value) {
      final day = int.tryParse(key);
      if (day != null) {
        parsedPlan[day] = Map<String, String>.from(value as Map);
      }
    });
    return WeeklyPlanModel(plan: parsedPlan);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonStrMap = {};
    plan.forEach((key, value) {
      jsonStrMap[key.toString()] = value;
    });
    return jsonStrMap;
  }
}
