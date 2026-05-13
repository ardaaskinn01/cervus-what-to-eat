import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/weekly_plan_model.dart';
import '../../data/models/filter_model.dart';
import '../../data/repositories/weekly_plan_repository.dart';
import '../../data/repositories/food_repository.dart';
import '../settings/settings_notifier.dart';

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

  void autoFillPlan() {
    final foodRepo = _ref.read(foodRepositoryProvider);
    final profile = _ref.read(settingsNotifierProvider);
    
    var newPlanMap = <int, Map<String, String>>{};
    List<String> excludeIds = [];

    for (int day = 1; day <= 7; day++) {
      newPlanMap[day] = {};
      
      // Sabah
      var breakfast = foodRepo.getRandomFood(FilterModel(mealType: 'Kahvaltı'), excludeIds, profile: profile);
      if (breakfast != null) {
        newPlanMap[day]!['Sabah'] = breakfast.id;
        excludeIds.add(breakfast.id);
      }

      // Öğle
      var lunch = foodRepo.getRandomFood(FilterModel(mealType: 'Öğle'), excludeIds, profile: profile);
      if (lunch != null) {
        newPlanMap[day]!['Öğle'] = lunch.id;
        excludeIds.add(lunch.id);
      }

      // Akşam
      var dinner = foodRepo.getRandomFood(FilterModel(mealType: 'Akşam'), excludeIds, profile: profile);
      if (dinner != null) {
        newPlanMap[day]!['Akşam'] = dinner.id;
        excludeIds.add(dinner.id);
      }
      
      // Keep exclude list manageable so we don't run out of foods
      if (excludeIds.length > 10) {
        excludeIds.removeRange(0, 5);
      }
    }

    final newModel = WeeklyPlanModel(plan: newPlanMap);
    state = newModel;
    _repo.savePlan(newModel);
  }
}
