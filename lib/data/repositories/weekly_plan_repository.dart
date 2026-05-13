import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../models/weekly_plan_model.dart';

final weeklyPlanRepositoryProvider = Provider<WeeklyPlanRepository>((ref) {
  return WeeklyPlanRepository(ref.read(sharedPreferencesProvider));
});

class WeeklyPlanRepository {
  final SharedPreferences _prefs;
  static const _key = 'weekly_plan_data';

  WeeklyPlanRepository(this._prefs);

  WeeklyPlanModel getPlan() {
    final str = _prefs.getString(_key);
    if (str == null) return WeeklyPlanModel(plan: {});
    return WeeklyPlanModel.fromJson(jsonDecode(str));
  }

  void savePlan(WeeklyPlanModel plan) {
    _prefs.setString(_key, jsonEncode(plan.toJson()));
  }
}
