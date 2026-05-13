import '../../data/models/food_model.dart';

class SuggestionState {
  final FoodModel? currentFood;
  final List<String> excludeIds;
  final bool isLoading;

  SuggestionState({
    this.currentFood,
    this.excludeIds = const [],
    this.isLoading = false,
  });

  SuggestionState copyWith({
    FoodModel? currentFood,
    List<String>? excludeIds,
    bool? isLoading,
  }) {
    // CurrentFood can be null if nothing found
    final isCurrentFoodNull = currentFood == FoodModel(
        id: '', name: '', mealTypes: [], place: [], timeMinutes: 0, budget: '', dietTags: [], cuisine: '', difficulty: '', ingredients: [], description: '', imageEmoji: '', moodTags: [], weatherTags: [], calorieRange: '', popularityScore: 0
      );

    return SuggestionState(
      currentFood: isCurrentFoodNull ? null : (currentFood ?? this.currentFood),
      excludeIds: excludeIds ?? this.excludeIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // To explicitely set currentFood to null if needed
  SuggestionState clearCurrentFood() {
    return SuggestionState(
      currentFood: null,
      excludeIds: excludeIds,
      isLoading: isLoading,
    );
  }
}
