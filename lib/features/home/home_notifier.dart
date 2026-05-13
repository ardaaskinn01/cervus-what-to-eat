import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'home_state.dart';
import '../../data/models/filter_model.dart';
import '../../data/models/food_model.dart';
import '../../data/repositories/food_repository.dart';
import '../settings/settings_notifier.dart';
import '../history/history_notifier.dart';
import '../favorites/favorites_notifier.dart';

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref);
});

class HomeNotifier extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeNotifier(this._ref) : super(HomeState());

  void setMood(String mood) {
    if (state.selectedMood == mood) {
      state = state.copyWith(selectedMood: ''); // Unselect
    } else {
      state = state.copyWith(selectedMood: mood);
    }
  }

  void setMealType(String mealType) {
    if (state.selectedMealType == mealType) {
      state = state.copyWith(selectedMealType: ''); // Unselect
    } else {
      state = state.copyWith(selectedMealType: mealType);
    }
  }

  Future<FoodModel?> suggestFood() async {
    state = state.copyWith(isLoading: true);
    
    // Yüklenme animasyonunu göstermek için minik bir gecikme
    await Future.delayed(const Duration(milliseconds: 500));
    
    final filter = FilterModel(
      mealType: state.selectedMealType,
      moodTag: state.selectedMood,
    );

    // DÜZELTME: Algoritma için gerekli tüm veriler toplanıyor
    final profile = _ref.read(settingsNotifierProvider);
    final history = _ref.read(historyNotifierProvider);
    final favorites = _ref.read(favoritesNotifierProvider);
    
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayEatenIds = history
        .where((e) => e.isEaten && DateFormat('yyyy-MM-dd').format(e.date) == todayStr)
        .map((e) => e.foodId)
        .toList();
    
    final favIds = favorites.favorites.map((f) => f.id).toList();

    final repo = _ref.read(foodRepositoryProvider);
    final suggested = repo.getRandomFood(
      filter, 
      [], 
      profile: profile,
      favIds: favIds,
      todayEatenIds: todayEatenIds,
    );

    state = state.copyWith(isLoading: false, lastSuggestedFood: suggested);
    return suggested;
  }
}
