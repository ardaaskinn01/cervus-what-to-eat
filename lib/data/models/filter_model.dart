class FilterModel {
  final String? mealType;
  final String? place;
  final int? maxTime;
  final String? budget;
  final String? dietTag;
  final String? cuisine;
  final String? moodTag;
  final String? weatherTag;
  
  // Map specific filters
  final double? minRating;
  final bool? onlyOpenNow;

  FilterModel({
    this.mealType,
    this.place,
    this.maxTime,
    this.budget,
    this.dietTag,
    this.cuisine,
    this.moodTag,
    this.weatherTag,
    this.minRating,
    this.onlyOpenNow,
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
    double? minRating,
    bool? onlyOpenNow,
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
      minRating: minRating ?? this.minRating,
      onlyOpenNow: onlyOpenNow ?? this.onlyOpenNow,
    );
  }

  FilterModel setMealType(String? value) => copyWith(mealType: value);
  FilterModel setPlace(String? value) => copyWith(place: value);
  FilterModel setMaxTime(int? value) => copyWith(maxTime: value);
  FilterModel setBudget(String? value) => copyWith(budget: value);
  FilterModel setDietTag(String? value) => copyWith(dietTag: value);
  FilterModel setCuisine(String? value) => copyWith(cuisine: value);
  FilterModel setMoodTag(String? value) => copyWith(moodTag: value);
  FilterModel setWeatherTag(String? value) => copyWith(weatherTag: value);
  FilterModel setMinRating(double? value) => copyWith(minRating: value);
  FilterModel setOnlyOpenNow(bool? value) => copyWith(onlyOpenNow: value);

  bool get isEmpty =>
      mealType == null &&
      place == null &&
      maxTime == null &&
      budget == null &&
      dietTag == null &&
      cuisine == null &&
      moodTag == null &&
      weatherTag == null &&
      minRating == null &&
      onlyOpenNow == null;

  int get activeFilterCount {
    int count = 0;
    if (mealType != null) count++;
    if (place != null) count++;
    if (maxTime != null) count++;
    if (budget != null) count++;
    if (dietTag != null) count++;
    if (cuisine != null) count++;
    if (moodTag != null) count++;
    if (weatherTag != null) count++;
    if (minRating != null) count++;
    if (onlyOpenNow == true) count++;
    return count;
  }
}
