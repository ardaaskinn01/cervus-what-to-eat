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
    Object? mealType = _sentinel,
    Object? place = _sentinel,
    Object? maxTime = _sentinel,
    Object? budget = _sentinel,
    Object? dietTag = _sentinel,
    Object? cuisine = _sentinel,
    Object? moodTag = _sentinel,
    Object? weatherTag = _sentinel,
    Object? minRating = _sentinel,
    Object? onlyOpenNow = _sentinel,
  }) {
    return FilterModel(
      mealType: mealType == _sentinel ? this.mealType : mealType as String?,
      place: place == _sentinel ? this.place : place as String?,
      maxTime: maxTime == _sentinel ? this.maxTime : maxTime as int?,
      budget: budget == _sentinel ? this.budget : budget as String?,
      dietTag: dietTag == _sentinel ? this.dietTag : dietTag as String?,
      cuisine: cuisine == _sentinel ? this.cuisine : cuisine as String?,
      moodTag: moodTag == _sentinel ? this.moodTag : moodTag as String?,
      weatherTag: weatherTag == _sentinel ? this.weatherTag : weatherTag as String?,
      minRating: minRating == _sentinel ? this.minRating : minRating as double?,
      onlyOpenNow: onlyOpenNow == _sentinel ? this.onlyOpenNow : onlyOpenNow as bool?,
    );
  }

  static const _sentinel = Object();


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
