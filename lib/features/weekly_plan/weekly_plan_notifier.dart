import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weekly_plan_model.dart';
import '../../data/models/filter_model.dart';
import '../../data/repositories/weekly_plan_repository.dart';
import '../../data/repositories/food_repository.dart';
import '../settings/settings_notifier.dart';
import '../favorites/favorites_notifier.dart';
import 'package:intl/intl.dart';

final weeklyPlanNotifierProvider = StateNotifierProvider<WeeklyPlanNotifier, WeeklyPlanModel>((ref) {
  return WeeklyPlanNotifier(ref);
});

class WeeklyPlanNotifier extends StateNotifier<WeeklyPlanModel> {
  final Ref _ref;
  late final WeeklyPlanRepository _repo;

  WeeklyPlanNotifier(this._ref) : super(_ref.read(weeklyPlanRepositoryProvider).getPlan()) {
    _repo = _ref.read(weeklyPlanRepositoryProvider);
  }

  void updateSlot(int day, String mealType, String foodId) {
    var newPlanMap = Map<int, Map<String, String>>.from(state.plan);
    if (!newPlanMap.containsKey(day)) {
      newPlanMap[day] = {};
    }
    newPlanMap[day]![mealType] = foodId;

    final newModel = WeeklyPlanModel(plan: newPlanMap);
    state = newModel;
    _repo.savePlan(newModel);
  }

  void clearSlot(int day, String mealType) {
    var newPlanMap = Map<int, Map<String, String>>.from(state.plan);
    if (newPlanMap.containsKey(day)) {
      newPlanMap[day]?.remove(mealType);
    }
    final newModel = WeeklyPlanModel(plan: newPlanMap);
    state = newModel;
    _repo.savePlan(newModel);
  }

  void clearAll() {
    final newModel = WeeklyPlanModel(plan: {});
    state = newModel;
    _repo.savePlan(newModel);
  }

  void suggestForSlot(int day, String mealType) {
    final foodRepo = _ref.read(foodRepositoryProvider);
    final profile = _ref.read(settingsNotifierProvider);
    
    // Gather context for better suggestion quality
    final favorites = _ref.read(favoritesNotifierProvider).favorites.map((f) => f.id).toList();
    // Avoid duplicate foods in the same weekly plan
    final existingIds = <String>[];
    state.plan.values.forEach((meals) => existingIds.addAll(meals.values));

    final filter = FilterModel(mealType: mealType);
    final suggested = foodRepo.getRandomFood(
      filter, 
      existingIds, 
      profile: profile,
      favIds: favorites,
    );

    if (suggested != null) {
      updateSlot(day, mealType, suggested.id);
    }
  }

  void autoFillPlan() {
    final foodRepo = _ref.read(foodRepositoryProvider);
    final profile = _ref.read(settingsNotifierProvider);
    final favorites = _ref.read(favoritesNotifierProvider).favorites.map((f) => f.id).toList();
    
    var newPlanMap = <int, Map<String, String>>{};
    List<String> excludeIds = [];

    for (int day = 1; day <= 7; day++) {
      newPlanMap[day] = {};
      
      for (var meal in ['Kahvaltı', 'Öğle', 'Akşam']) {
        var suggested = foodRepo.getRandomFood(
          FilterModel(mealType: meal), 
          excludeIds, 
          profile: profile,
          favIds: favorites,
        );
        if (suggested != null) {
          newPlanMap[day]![meal] = suggested.id;
          excludeIds.add(suggested.id);
        }
      }
      
      if (excludeIds.length > 20) excludeIds.removeRange(0, 10);
    }

    final newModel = WeeklyPlanModel(plan: newPlanMap);
    state = newModel;
    _repo.savePlan(newModel);
  }
}
