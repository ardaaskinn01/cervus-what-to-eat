class FilterModel {
  final String? mealType;
  final String? place;
  final int? maxTime;
  final String? budget;
  final String? dietTag;
  final String? cuisine;
  final String? moodTag;
  final String? weatherTag;

  FilterModel({
    this.mealType,
    this.place,
    this.maxTime,
    this.budget,
    this.dietTag,
    this.cuisine,
    this.moodTag,
    this.weatherTag,
  });

  FilterModel copyWith({
    String? mealType,
    String? place,
    int? maxTime,
    String? budget,
    String? dietTag,
    String? cuisine,
    String? moodTag,
    String? weatherTag,
  }) {
    return FilterModel(
      mealType: mealType ?? this.mealType,
      place: place ?? this.place,
      maxTime: maxTime ?? this.maxTime,
      budget: budget ?? this.budget,
      dietTag: dietTag ?? this.dietTag,
      cuisine: cuisine ?? this.cuisine,
      moodTag: moodTag ?? this.moodTag,
      weatherTag: weatherTag ?? this.weatherTag,
    );
  }

  bool get isEmpty =>
      mealType == null &&
      place == null &&
      maxTime == null &&
      budget == null &&
      dietTag == null &&
      cuisine == null &&
      moodTag == null &&
      weatherTag == null;
}
