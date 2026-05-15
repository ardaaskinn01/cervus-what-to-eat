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

    // Dataset'i karıştır (Eşit skorlarda sıra adaleti için)
    final shuffledDataset = List<FoodModel>.from(foodDataset)..shuffle(random);

    for (var food in shuffledDataset) {
      // 1. Hard Filter: Eşleşmeyenleri baştan ele
      bool match = true;
      if (filter.mealType != null && !food.mealTypes.contains(filter.mealType)) match = false;
      if (filter.place != null && !food.place.contains(filter.place)) match = false;
      if (filter.maxTime != null && food.timeMinutes > filter.maxTime!) match = false;
      if (filter.budget != null && food.budget.toLowerCase() != filter.budget!.toLowerCase()) match = false;
      if (filter.dietTag != null && !food.dietTags.contains(filter.dietTag)) match = false;
      if (filter.cuisine != null && food.cuisine.toLowerCase() != filter.cuisine!.toLowerCase()) match = false;

      // Alerji kontrolü (Katı kural)
      if (profile != null && profile.allergies.isNotEmpty) {
        for (var a in profile.allergies) {
          if (food.ingredients.any((i) => i.toLowerCase().contains(a.toLowerCase()))) {
            match = false;
            break;
          }
        }
      }

      if (!match) continue;

      // 2. Dinamik Puanlama
      double score = 20.0; // Daha yüksek temel puan

      // Filtre Uyumu (Tercih edilenler için ekstra puan)
      if (filter.moodTag != null && food.moodTags.contains(filter.moodTag)) score += 15;
      if (filter.weatherTag != null && (food.weatherTags.contains(filter.weatherTag) || food.weatherTags.contains('Her_hava'))) score += 10;

      // Diyet Uyumu (Profildeki diyet tipine tam uyanlar kazansın)
      if (profile != null && profile.dietType != 'Normal') {
        if (food.dietTags.contains(profile.dietType)) {
          score += 25;
        } else {
          // Eğer diyet tipi uymuyorsa şansını çok azalt (Katı değil ama çok düşük ihtimal)
          score *= 0.1;
        }
      }

      // Favoriler (+%50 şans)
      if (favIds.contains(food.id)) {
        score *= 1.5;
      }

      // 3. Tekrar Önleme (DÜZELTME: İsim bazlı kontrol de eklendi)
      
      // Bugün yenildi mi? (Neredeyse imkansız yap)
      if (todayEatenIds.contains(food.id)) {
        score *= 0.01;
      }
      
      // Son önerilenler arasında mı? (Penaltıyı ağırlaştır)
      final lastSuggestedFood = excludeIds.isNotEmpty 
          ? shuffledDataset.firstWhere((f) => f.id == excludeIds.last, orElse: () => food) 
          : null;

      if (excludeIds.contains(food.id) || (lastSuggestedFood != null && lastSuggestedFood.name == food.name)) {
        // En son önerilen mi? (İsim veya ID bazlı)
        if (excludeIds.isNotEmpty && (excludeIds.last == food.id || lastSuggestedFood?.name == food.name)) {
          score *= 0.0; // Son yemeği (ve aynısını) ÇIKARMA
        } else {
          // Listenin başında mı (daha eski mi)?
          int index = excludeIds.indexOf(food.id);
          double penaltyFactor = 0.05 + (index * 0.1); // Penaltıyı çok daha sert yap
          score *= penaltyFactor;
        }
      }

      // 4. Çeşitlilik ve Sürpriz Faktörü
      
      // PopularityScore etkisi
      score *= (1.0 + (food.popularityScore * 0.3));

      // Kaos Faktörü: %0 ile %50 arası tamamen rastgele ek puan
      // Bu, her zaman en yüksek puanın kazanmamasını sağlar.
      score += random.nextDouble() * 15;

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

    return scores.first.food;
  }
}

class _FoodItemScore {
  final FoodModel food;
  final double score;

  _FoodItemScore(this.food, this.score);
}
