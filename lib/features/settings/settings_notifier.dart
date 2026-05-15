import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/settings_repository.dart';
import '../../core/services/notification_service.dart';

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

  Future<void> toggleNotifications(bool enabled, String? time) async {
    if (enabled) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        // Permission denied, don't enable
        return;
      }
      
      // Schedule initial notification as a welcome
      await NotificationService.instance.scheduleDailySuggestion(state.name, time ?? '12:00');
    }
    
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

  void _save(UserProfileModel newModel) {
    state = newModel;
    _repo.saveProfile(newModel);
  }
}
