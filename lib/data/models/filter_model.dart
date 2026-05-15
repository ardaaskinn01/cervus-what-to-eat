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

  FilterModel setMealType(String? value) => FilterModel(mealType: value, place: place, maxTime: maxTime, budget: budget, dietTag: dietTag, cuisine: cuisine, moodTag: moodTag, weatherTag: weatherTag);
  FilterModel setPlace(String? value) => FilterModel(mealType: mealType, place: value, maxTime: maxTime, budget: budget, dietTag: dietTag, cuisine: cuisine, moodTag: moodTag, weatherTag: weatherTag);
  FilterModel setMaxTime(int? value) => FilterModel(mealType: mealType, place: place, maxTime: value, budget: budget, dietTag: dietTag, cuisine: cuisine, moodTag: moodTag, weatherTag: weatherTag);
  FilterModel setBudget(String? value) => FilterModel(mealType: mealType, place: place, maxTime: maxTime, budget: value, dietTag: dietTag, cuisine: cuisine, moodTag: moodTag, weatherTag: weatherTag);
  FilterModel setDietTag(String? value) => FilterModel(mealType: mealType, place: place, maxTime: maxTime, budget: budget, dietTag: value, cuisine: cuisine, moodTag: moodTag, weatherTag: weatherTag);
  FilterModel setCuisine(String? value) => FilterModel(mealType: mealType, place: place, maxTime: maxTime, budget: budget, dietTag: dietTag, cuisine: value, moodTag: moodTag, weatherTag: weatherTag);
  FilterModel setMoodTag(String? value) => FilterModel(mealType: mealType, place: place, maxTime: maxTime, budget: budget, dietTag: dietTag, cuisine: cuisine, moodTag: value, weatherTag: weatherTag);
  FilterModel setWeatherTag(String? value) => FilterModel(mealType: mealType, place: place, maxTime: maxTime, budget: budget, dietTag: dietTag, cuisine: cuisine, moodTag: moodTag, weatherTag: value);


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
