import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../history/history_notifier.dart';

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, UserProfileModel>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<UserProfileModel> {
  final Ref _ref;
  late final SettingsRepository _repo;

  SettingsNotifier(this._ref) : super(
    _ref.read(settingsRepositoryProvider).getProfile()
  ) {
    _repo = _ref.read(settingsRepositoryProvider);
  }

  void updateName(String name) {
    _save(state.copyWith(name: name));
  }

  void toggleTheme(bool isDark) {
    _save(state.copyWith(isDarkMode: isDark));
  }

  void toggleNotifications(bool enabled, String? time) {
    _save(state.copyWith(notificationsEnabled: enabled, notificationTime: time));
  }

  void updateDietType(String dietType) {
    _save(state.copyWith(dietType: dietType));
  }

  void updateAllergies(List<String> allergies) {
    _save(state.copyWith(allergies: allergies));
  }

  void updateCalorieGoal(int goal) {
    _save(state.copyWith(dailyCalorieGoal: goal));
  }

  void clearHistory() {
    _repo.clearHistory();
    // We should invalidate or reset the history provider
    // In Riverpod 2.0 we could do `_ref.invalidate(historyNotifierProvider)`
    _ref.invalidate(historyNotifierProvider);
  }

  void _save(UserProfileModel newModel) {
    state = newModel;
    _repo.saveProfile(newModel);
  }
}
