import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'suggestion_state.dart';
import '../../core/providers/filter_provider.dart';
import '../../data/repositories/food_repository.dart';
import '../home/home_notifier.dart';
import '../favorites/favorites_notifier.dart';
import '../history/history_notifier.dart';
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
    await AdService.instance.onSuggestionRequested(() {});
    
    if (!mounted) return;
    state = state.copyWith(isLoading: true);
    
    // Simulate thinking/loading
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final homeState = _ref.read(homeNotifierProvider);
    final globalFilter = _ref.read(filterProvider);
    final profile = _ref.read(settingsNotifierProvider);

    final filter = globalFilter.copyWith(
      mealType: homeState.selectedMealType ?? globalFilter.mealType,
      moodTag: homeState.selectedMood ?? globalFilter.moodTag,
    );

    final repo = _ref.read(foodRepositoryProvider);
    var nextFood = repo.getRandomFood(filter, state.excludeIds, profile: profile);

    // If nothing found and excludeIds is full, maybe we need to clear excludeIds.
    if (nextFood == null && state.excludeIds.isNotEmpty) {
       nextFood = repo.getRandomFood(filter, [], profile: profile);
       if (!mounted) return;
       state = state.copyWith(excludeIds: []); // Reset exclude ids
    }

    if (!mounted) return;
    if (nextFood != null) {
      final newExcludeIds = List<String>.from(state.excludeIds)..add(nextFood.id);
      if (newExcludeIds.length > 5) {
        newExcludeIds.removeAt(0); // Keep last 5
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

  // BUG 2: Make it async to handle badge popups in UI
  Future<List<String>> markAsEaten() async {
    if (state.currentFood != null) {
       final badges = _ref.read(historyNotifierProvider.notifier).addEntry(state.currentFood!, true);
       return badges;
    }
    return [];
  }
}
