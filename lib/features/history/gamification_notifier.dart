import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../../data/models/gamification_model.dart';

final gamificationNotifierProvider = StateNotifierProvider<GamificationNotifier, GamificationModel>((ref) {
  return GamificationNotifier(ref.read(sharedPreferencesProvider));
});

class GamificationNotifier extends StateNotifier<GamificationModel> {
  final SharedPreferences _prefs;
  static const _gKey = 'gamification_data';

  GamificationNotifier(this._prefs) : super(_load(_prefs));

  static GamificationModel _load(SharedPreferences prefs) {
    final str = prefs.getString(_gKey);
    if (str == null) return GamificationModel(xp: 0, streakDays: 0, unlockedBadges: []);
    return GamificationModel.fromJson(jsonDecode(str));
  }

  void _save(GamificationModel newModel) {
    state = newModel;
    _prefs.setString(_gKey, jsonEncode(newModel.toJson()));
  }

  // Returns true if a new badge was unlocked (for popup triggers)
  List<String> checkAndAddXP(int points, {bool isHealthy = false}) {
    List<String> newlyUnlocked = [];
    int newXp = state.xp + points;

    // Streak Logic Simple
    final now = DateTime.now();
    int newStreak = state.streakDays;
    
    if (state.lastActionDate == null) {
      newStreak = 1;
    } else {
      final diff = now.difference(state.lastActionDate!).inDays;
      if (diff == 1) {
        newStreak += 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
    }

    List<String> badges = List.from(state.unlockedBadges);

    if (isHealthy && newStreak >= 3 && !badges.contains('Sağlıklı Gurme')) {
      badges.add('Sağlıklı Gurme');
      newlyUnlocked.add('Sağlıklı Gurme');
      newXp += 50;
    }

    if (newXp >= 200 && !badges.contains('Müdavim')) {
      badges.add('Müdavim');
      newlyUnlocked.add('Müdavim');
    }

    _save(state.copyWith(
      xp: newXp,
      streakDays: newStreak,
      lastActionDate: now,
      unlockedBadges: badges,
    ));

    return newlyUnlocked;
  }
}
