import 'dart:math';
import '../../data/models/food_model.dart';
import '../../data/models/filter_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/datasources/food_dataset.dart';

class SmartSuggestionEngine {
  FoodModel? getWeightedRandomFood({
    required FilterModel filter,
    required List<String> excludeIds,
    List<String> favIds = const [],
    List<String> todayEatenIds = const [],
    UserProfileModel? profile,
  }) {
    List<_FoodItemScore> scores = [];
    final random = Random();

    for (var food in foodDataset) {
      // 1. Hard Filter: Eşleşmeyenleri baştan ele
      bool match = true;
      if (filter.mealType != null && !food.mealTypes.contains(filter.mealType)) match = false;
      if (filter.place != null && !food.place.contains(filter.place)) match = false;
      if (filter.maxTime != null && food.timeMinutes > filter.maxTime!) match = false;
      if (filter.budget != null && food.budget.toLowerCase() != filter.budget!.toLowerCase()) match = false;
      if (filter.dietTag != null && !food.dietTags.contains(filter.dietTag)) match = false;
      if (filter.cuisine != null && food.cuisine.toLowerCase() != filter.cuisine!.toLowerCase()) match = false;

      // Profile Strict Restrictions
      if (profile != null) {
        // Allergies
        if (profile.allergies.isNotEmpty) {
           for (var a in profile.allergies) {
             if (food.ingredients.any((i) => i.toLowerCase().contains(a.toLowerCase()))) {
               match = false;
               break;
             }
           }
        }
        // Diet Type (Simple match, real app needs better mapping)
        if (profile.dietType != 'Normal' && !food.dietTags.contains(profile.dietType)) {
          match = false;
        }
      }

      if (!match) continue; // Filtreye uymuyorsa puanlama bile yapma

      double score = 10.0; // Temel başlangıç puanı

      // Filtre eşleşmesi: Her uyan filtre eklentisi (opsiyonel extra) için +10 puan
      if (filter.mealType != null) score += 10;
      if (filter.place != null) score += 10;
      if (filter.maxTime != null) score += 10;
      if (filter.budget != null) score += 10;
      if (filter.dietTag != null) score += 10;
      if (filter.cuisine != null) score += 10;

      // Mood uyumu
      if (filter.moodTag != null && food.moodTags.contains(filter.moodTag)) {
        score += 8;
      }

      // Hava uyumu
      if (filter.weatherTag != null && (food.weatherTags.contains(filter.weatherTag) || food.weatherTags.contains('Her_hava'))) {
        score += 5;
      }

      // Favoriler
      if (favIds.contains(food.id)) {
        score += 15;
      }

      // Bugün yenildi mi
      if (todayEatenIds.contains(food.id)) {
        score -= 100;
      }

      // Son 5 öneride göründü mü
      if (excludeIds.contains(food.id)) {
        score -= 50;
      }

      // PopularityScore etkisi (x1.2 çarpan, veya skora oranlı eklenti)
      // Popularity 0.0 ile 1.0 arası bir değer. Popülerliği yüksek olan 1.2 kat şanslı.
      score *= (1.0 + (food.popularityScore * 0.2));

      // Sürpriz faktörü %20 rastgelelik ekle (Puanın +- %20'si kadar randomize)
      double randomFactor = 0.8 + (random.nextDouble() * 0.4); // 0.8 ile 1.2 arası
      score *= randomFactor;

      // Profile Calorie Impact
      if (profile != null) {
         // This is a naive logic mapping string (Düşük/Orta/Yüksek) to numbers
         // Realistically, high dailyCalorieGoal prefers high/orta calorie range.
         if (profile.dailyCalorieGoal < 1800 && food.calorieRange == 'Yüksek') score *= 0.5;
         if (profile.dailyCalorieGoal > 2800 && food.calorieRange == 'Düşük') score *= 0.5;
      }

      if (score > 0) {
        scores.add(_FoodItemScore(food, score));
      }
    }

    if (scores.isEmpty) return null;

    // Ağırlıklı (Weighted) Random Seçim
    double totalScore = scores.fold(0, (sum, item) => sum + item.score);
    double randomPoint = random.nextDouble() * totalScore;
    double currentSum = 0;

    for (var item in scores) {
      currentSum += item.score;
      if (currentSum >= randomPoint) {
        return item.food;
      }
    }

    return scores.first.food; // Fallback
  }
}

class _FoodItemScore {
  final FoodModel food;
  final double score;

  _FoodItemScore(this.food, this.score);
}
