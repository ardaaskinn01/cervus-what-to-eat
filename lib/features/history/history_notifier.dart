import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/history_model.dart';
import '../../data/models/food_model.dart';
import '../../data/repositories/history_repository.dart';
import 'gamification_notifier.dart';

final historyNotifierProvider = StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  return HistoryNotifier(ref);
});

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  final Ref _ref;
  late final HistoryRepository _repo;

  HistoryNotifier(this._ref) : super([]) {
    _repo = _ref.read(historyRepositoryProvider);
    state = _repo.getAll();
  }

  // Returns list of newly unlocked badges
  List<String> addEntry(FoodModel food, bool isEaten) {
    final entry = HistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: food.id,
      foodName: food.name,
      date: DateTime.now(),
      isEaten: isEaten,
      isRecommended: true,
    );
    
    _repo.addEntry(entry);
    state = _repo.getAll();

    // Trigger Gamification via Ref to avoid stale references
    if (isEaten) {
      bool isHealthy = food.dietTags.contains('Sağlıklı') || food.cuisine == 'Fit Yemek';
      return _ref.read(gamificationNotifierProvider.notifier).checkAndAddXP(10, isHealthy: isHealthy);
    }
    
    return [];
  }
}
