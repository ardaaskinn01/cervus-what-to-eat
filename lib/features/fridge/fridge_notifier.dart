import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_model.dart';
import '../../data/datasources/food_dataset.dart';

class FridgeState {
  final Set<String> selectedIngredients;
  final List<Map<String, dynamic>> matchedFoods;

  FridgeState({
    required this.selectedIngredients,
    required this.matchedFoods,
  });

  FridgeState copyWith({
    Set<String>? selectedIngredients,
    List<Map<String, dynamic>>? matchedFoods,
  }) {
    return FridgeState(
      selectedIngredients: selectedIngredients ?? this.selectedIngredients,
      matchedFoods: matchedFoods ?? this.matchedFoods,
    );
  }
}

final fridgeNotifierProvider = StateNotifierProvider<FridgeNotifier, FridgeState>((ref) {
  return FridgeNotifier();
});

class FridgeNotifier extends StateNotifier<FridgeState> {
  FridgeNotifier() : super(FridgeState(selectedIngredients: {}, matchedFoods: []));

  void toggleIngredient(String ingredient) {
    final newSet = Set<String>.from(state.selectedIngredients);
    if (newSet.contains(ingredient)) {
      newSet.remove(ingredient);
    } else {
      newSet.add(ingredient);
    }
    state = state.copyWith(selectedIngredients: newSet);
    calculateMatches();
  }

  void clearAll() {
    state = state.copyWith(selectedIngredients: {}, matchedFoods: []);
  }

  void calculateMatches() {
    if (state.selectedIngredients.isEmpty) {
      state = state.copyWith(matchedFoods: []);
      return;
    }

    final List<Map<String, dynamic>> matches = [];
    for (var food in foodDataset) {
      int matchCount = 0;
      for (var reqIng in food.ingredients) {
        if (state.selectedIngredients.any((s) => reqIng.toLowerCase().contains(s.toLowerCase()))) {
          matchCount++;
        }
      }

      if (matchCount > 0) {
        double ratio = matchCount / food.ingredients.length;
        matches.add({
          'food': food,
          'matchCount': matchCount,
          'total': food.ingredients.length,
          'ratio': ratio,
        });
      }
    }

    matches.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));
    state = state.copyWith(matchedFoods: matches);
  }
}
