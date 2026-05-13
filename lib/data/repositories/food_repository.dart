import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_model.dart';
import '../models/filter_model.dart';
import '../models/user_profile_model.dart';
import '../../core/engine/smart_suggestion_engine.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository();
});

class FoodRepository {
  final SmartSuggestionEngine _engine = SmartSuggestionEngine();

  FoodModel? getRandomFood(
    FilterModel filter, 
    List<String> excludeIds, {
    UserProfileModel? profile,
    List<String> favIds = const [],
    List<String> todayEatenIds = const [],
  }) {
    // Passing all parameters to the innovative SmartSuggestionEngine
    return _engine.getWeightedRandomFood(
      filter: filter, 
      excludeIds: excludeIds, 
      profile: profile,
      favIds: favIds,
      todayEatenIds: todayEatenIds,
    );
  }
}
