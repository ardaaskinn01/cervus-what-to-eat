import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_model.dart';
import 'suggestion_state.dart';
import '../../core/providers/filter_provider.dart';
import '../../data/repositories/food_repository.dart';
import '../home/home_notifier.dart';
import '../favorites/favorites_notifier.dart';
import '../settings/settings_notifier.dart';
import '../../core/services/ad_service.dart';

final suggestionNotifierProvider = StateNotifierProvider<SuggestionNotifier, SuggestionState>((ref) {
  return SuggestionNotifier(ref);
});

class SuggestionNotifier extends StateNotifier<SuggestionState> {
  final Ref _ref;

  SuggestionNotifier(this._ref) : super(SuggestionState());

  Future<void> suggestNext() async {
    // BUG 1: Separate Ad logic from State updates
    AdService.instance.onSuggestionRequested(() {});
    
    if (!mounted) return;
    state = state.copyWith(isLoading: true, currentFood: null);
    
    // Simulate thinking/loading
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final homeState = _ref.read(homeNotifierProvider);
    final globalFilter = _ref.read(filterProvider);
    final profile = _ref.read(settingsNotifierProvider);

    final filter = globalFilter.copyWith(
      mealType: globalFilter.mealType ?? homeState.selectedMealType,
      moodTag: globalFilter.moodTag ?? homeState.selectedMood,
    );

    final repo = _ref.read(foodRepositoryProvider);
    var nextFood = repo.getRandomFood(filter, state.excludeIds, profile: profile);

    // If no food is found, nextFood is correctly null and it will show "Not found"

    if (!mounted) return;
    if (nextFood != null) {
      final newExcludeIds = List<String>.from(state.excludeIds)..add(nextFood.id);
      if (newExcludeIds.length > 20) {
        newExcludeIds.removeAt(0); // Keep last 20
      }
      state = state.copyWith(
        currentFood: nextFood,
        excludeIds: newExcludeIds,
        isLoading: false,
      );
    } else {
      state = state.clearCurrentFood().copyWith(isLoading: false);
    }
  }

  void markAsFavorite() {
    if (state.currentFood != null) {
      _ref.read(favoritesNotifierProvider.notifier).toggleFavorite(state.currentFood!.id);
    }
  }

  void setCurrentFood(FoodModel food) {
    state = state.copyWith(currentFood: food);
  }

  void clearExcludeIds() {
    state = state.copyWith(excludeIds: []);
  }
}
