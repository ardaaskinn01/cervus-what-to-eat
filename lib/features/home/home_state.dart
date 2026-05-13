import '../../data/models/food_model.dart';

class HomeState {
  final String? selectedMood;
  final String? selectedMealType;
  final bool isLoading;
  final FoodModel? lastSuggestedFood;

  HomeState({
    this.selectedMood,
    this.selectedMealType,
    this.isLoading = false,
    this.lastSuggestedFood,
  });

  HomeState copyWith({
    String? selectedMood,
    String? selectedMealType,
    bool? isLoading,
    FoodModel? lastSuggestedFood,
  }) {
    return HomeState(
      selectedMood: selectedMood == '' ? null : (selectedMood ?? this.selectedMood),
      selectedMealType: selectedMealType == '' ? null : (selectedMealType ?? this.selectedMealType),
      isLoading: isLoading ?? this.isLoading,
      lastSuggestedFood: lastSuggestedFood == FoodModel(
        id: '', name: '', mealTypes: [], place: [], timeMinutes: 0, budget: '', dietTags: [], cuisine: '', difficulty: '', ingredients: [], description: '', imageEmoji: '', moodTags: [], weatherTags: [], calorieRange: '', popularityScore: 0
      ) ? null : (lastSuggestedFood ?? this.lastSuggestedFood),
    );
  }
}
