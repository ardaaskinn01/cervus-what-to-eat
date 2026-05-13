import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../models/user_profile_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.read(sharedPreferencesProvider));
});

class SettingsRepository {
  final SharedPreferences _prefs;
  static const _settingsKey = 'user_settings';

  SettingsRepository(this._prefs);

  UserProfileModel getProfile() {
    final str = _prefs.getString(_settingsKey);
    if (str == null) {
      return UserProfileModel(
        name: '', 
        isDarkMode: false, 
        notificationsEnabled: false, 
        dietType: 'Normal', 
        allergies: [], 
        dailyCalorieGoal: 2000
      );
    }
    return UserProfileModel.fromJson(jsonDecode(str));
  }

  void saveProfile(UserProfileModel profile) {
    _prefs.setString(_settingsKey, jsonEncode(profile.toJson()));
  }

  void clearHistory() {
    _prefs.remove('history_entries');
  }
}
