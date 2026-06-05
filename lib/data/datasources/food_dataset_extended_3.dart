import '../models/food_model.dart';

final List<FoodModel> foodDatasetExtended3 = [
  // --- Çorbalar ---
  FoodModel(
    id: 'f_ext3_1', name: 'Tarhana Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 20, budget: 'Ucuz',
    dietTags: ['Geleneksel', 'Sağlıklı', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Tarhana', 'Salça', 'Tereyağı', 'Nane', 'Pul Biber'], description: 'Fermente tarhananın mis gibi kokusuyla içinizi ısıtan Anadolu klasiği.',
    imageEmoji: '🥣', moodTags: ['Nostaljik', 'Konforlu', 'Sıcacık'], weatherTags: ['Soğuk', 'Yağmurlu'], calorieRange: 'Düşük', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f_ext3_2', name: 'Kremali Mantar Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Vejetaryen', 'Hafif', 'Modern'], cuisine: 'Dünya', difficulty: 'Orta',
    ingredients: ['Mantar', 'Krema', 'Soğan', 'Sarımsak', 'Taze Kekik'], description: 'Kremsi yapısı ve derin mantar aromasıyla her lokmada keyif veren sofistike çorba.',
    imageEmoji: '🍵', moodTags: ['Konforlu', 'Zarif', 'Sıcacık'], weatherTags: ['Soğuk', 'Yağmurlu'], calorieRange: 'Orta', popularityScore: 0.82,
  ),

  // --- Et Yemekleri ---
  FoodModel(
    id: 'f_ext3_3', name: 'Kaburga Haşlama', mealTypes: ['Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 90, budget: 'Pahalı',
    dietTags: ['Doyurucu', 'Etli', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Dana Kaburga', 'Nohut', 'Soğan', 'Sarımsak', 'Defne Yaprağı'], description: 'Saatlerce pişen kaburganın kemiğinden ayrılan eti; Doğu mutfağının gururu.',
    imageEmoji: '🥩', moodTags: ['Ziyafet', 'Özel', 'Doyurucu'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.84,
  ),
  FoodModel(
    id: 'f_ext3_4', name: 'Şiş Köfte', mealTypes: ['Akşam', 'Öğle'], place: ['Evde', 'Dışarıda'], timeMinutes: 35, budget: 'Orta',
    dietTags: ['Proteinli', 'Doyurucu', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Kıyma', 'Soğan', 'Maydanoz', 'Baharat', 'Lavaş'], description: 'Közde pişmiş, baharatlı kıymalı şişlerin lavaşla buluşması.',
    imageEmoji: '🍢', moodTags: ['Doyurucu', 'Enerjik'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.87,
  ),
  FoodModel(
    id: 'f_ext3_5', name: 'Biftek', mealTypes: ['Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 25, budget: 'Pahalı',
    dietTags: ['Proteinli', 'Düşük Karbonhidrat', 'Fit'], cuisine: 'Amerikan', difficulty: 'Orta',
    ingredients: ['Dana Biftek', 'Tereyağı', 'Sarımsak', 'Biberiye'], description: 'Orta-az pişirilmiş; dışı kızarmış içi pembe ve sulu etin zirvesi.',
    imageEmoji: '🥩', moodTags: ['Lüks', 'Özel', 'Kutlama'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.90,
  ),

  // --- Sebze Yemekleri ---
  FoodModel(
    id: 'f_ext3_6', name: 'Türlü', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 55, budget: 'Ucuz',
    dietTags: ['Vegan', 'Sağlıklı', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Patlıcan', 'Kabak', 'Patates', 'Biber', 'Domates', 'Zeytinyağı'], description: 'Yaz sebzelerinin fırında buluştuğu, rengarenk ve mis kokulu geleneksel güveç.',
    imageEmoji: '🥕', moodTags: ['Geleneksel', 'Hafif', 'Sağlıklı'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.79,
  ),
  FoodModel(
    id: 'f_ext3_7', name: 'Nohut Yemeği', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 40, budget: 'Ucuz',
    dietTags: ['Vejetaryen', 'Proteinli', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Nohut', 'Salça', 'Soğan', 'Havuç'], description: 'Pilav veya ekmekle yanına yetişemeyeceğiniz sade ama tok tutan sofra classici.',
    imageEmoji: '🫘', moodTags: ['Nostaljik', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.80,
  ),

  // --- Makarna / Pirinç ---
  FoodModel(
    id: 'f_ext3_8', name: 'Pesto Soslu Makarna', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Vejetaryen', 'Hafif', 'Modern'], cuisine: 'İtalyan', difficulty: 'Kolay',
    ingredients: ['Makarna', 'Fesleğen Pesto', 'Parmesan', 'Çam Fıstığı', 'Zeytinyağı'], description: "İtalya'nın Cenova şehrinden gelen ve yeşilin en lezzetli hali.",

    imageEmoji: '🍝', moodTags: ['Modern', 'Hafif', 'Keyifli'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext3_9', name: 'Risotto (Mantarlı)', mealTypes: ['Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 40, budget: 'Pahalı',
    dietTags: ['Vejetaryen', 'Doyurucu', 'Sofistike'], cuisine: 'İtalyan', difficulty: 'Zor',
    ingredients: ['Arborio Pirinci', 'Mantar', 'Parmesan', 'Beyaz Şarap', 'Tereyağı'], description: 'Her kaşıkta elde edilen kremsi dokusuyla İtalyan mutfağının mücevheri.',
    imageEmoji: '🍚', moodTags: ['Zarif', 'Özel', 'Konforlu'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.83,
  ),

  // --- Sandviç / Ekmek arası ---
  FoodModel(
    id: 'f_ext3_10', name: 'Izgara Peynirli Sandviç', mealTypes: ['Kahvaltı', 'Öğle', 'Atıştırmalık'], place: ['Evde', 'Ofiste'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Vejetaryen', 'Pratik', 'Doyurucu'], cuisine: 'Amerikan', difficulty: 'Kolay',
    ingredients: ['Ekmek', 'Kaşar/Cheddar', 'Tereyağı'], description: 'Dışı altın sarısı çıtır, içi erimiş peynirli her yaşa hitap eden klasik.',
    imageEmoji: '🥪', moodTags: ['Konforlu', 'Nostaljik', 'Hızlı'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.87,
  ),
  FoodModel(
    id: 'f_ext3_11', name: 'Falafel Wrap', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda', 'Evde'], timeMinutes: 25, budget: 'Orta',
    dietTags: ['Vegan', 'Proteinli', 'Sağlıklı'], cuisine: 'Ortadoğu', difficulty: 'Orta',
    ingredients: ['Lavaş', 'Falafel', 'Humus', 'Tahin', 'Turşu Sebze'], description: 'Çıtır falafel ve kremsi humusun nefis lavaş sarması.',
    imageEmoji: '🌯', moodTags: ['Modern', 'Hafif', 'Enerjik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.81,
  ),

  // --- Deniz Ürünleri ---
  FoodModel(
    id: 'f_ext3_12', name: 'Karides Güveç', mealTypes: ['Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 25, budget: 'Pahalı',
    dietTags: ['Proteinli', 'Sağlıklı', 'Lüks'], cuisine: 'Deniz Ürünleri', difficulty: 'Orta',
    ingredients: ['Karides', 'Domates', 'Biber', 'Kaşar', 'Sarımsak'], description: 'Fırın sıcaklığında olgunlaşan, közde domates ve biberle buluşan karides şöleni.',
    imageEmoji: '🦐', moodTags: ['Özel', 'Lüks', 'Sosyalleşme'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.86,
  ),
  FoodModel(
    id: 'f_ext3_13', name: 'Ahtapot Salatası', mealTypes: ['Akşam', 'Atıştırmalık'], place: ['Dışarıda'], timeMinutes: 50, budget: 'Pahalı',
    dietTags: ['Proteinli', 'Hafif', 'Fit'], cuisine: 'Deniz Ürünleri', difficulty: 'Zor',
    ingredients: ['Ahtapot', 'Zeytinyağı', 'Soğan', 'Kekik', 'Limon'], description: 'Közlenmiş yumuşak ahtapotun zeytinyağlı Ege usulü salatası.',
    imageEmoji: '🐙', moodTags: ['Maceraperest', 'Zarif', 'Özel'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.74,
  ),

  // --- Tatlılar ---
  FoodModel(
    id: 'f_ext3_14', name: 'Kazandibi', mealTypes: ['Tatlı'], place: ['Dışarıda', 'Evde'], timeMinutes: 50, budget: 'Ucuz',
    dietTags: ['Geleneksel', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Süt', 'Şeker', 'Nişasta', 'Tavuk Göğsü'], description: 'Dibine bakılarak kızartılan eşsiz Türk muhallebisi; adı kadar lezzetli.',
    imageEmoji: '🍮', moodTags: ['Nostaljik', 'Tatlı Krizi', 'Geleneksel'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f_ext3_15', name: 'Fıstıklı Künefe', mealTypes: ['Tatlı'], place: ['Dışarıda'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Geleneksel', 'Kaçamak'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Kadayıf', 'Peynir', 'Fıstık', 'Şerbet', 'Tereyağı'], description: 'Kadayıf ile peynirlerin fırınlanıp şerbetle buluştuğu Güneydoğu efsanesi.',
    imageEmoji: '🍯', moodTags: ['Kutlama', 'Bayram', 'Özel'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.96,
  ),
  FoodModel(
    id: 'f_ext3_16', name: 'Profiterol', mealTypes: ['Tatlı', 'Atıştırmalık'], place: ['Dışarıda', 'Evde'], timeMinutes: 45, budget: 'Orta',
    dietTags: ['Vejetaryen', 'Tatlı', 'Modern'], cuisine: 'Fransız', difficulty: 'Zor',
    ingredients: ['Choux Hamuru', 'Krem Şanti', 'Çikolata Sosu'], description: 'Sıcak çikolata sosuna bulanan kremalı küçük Fransız pastası.',
    imageEmoji: '🍫', moodTags: ['Kutlama', 'Ödül', 'Zarif'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.91,
  ),

  // --- Atıştırmalık / Sağlıklı ---
  FoodModel(
    id: 'f_ext3_17', name: 'Protein Bowl', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Ofiste'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Yüksek Protein', 'Fit', 'Sağlıklı'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Tavuk Göğsü', 'Kinoa', 'Nohut', 'Edamame', 'Avokado', 'Tahin'], description: 'Antrenman sonrası kas yapımını destekleyen, bol proteinli güç kasesi.',
    imageEmoji: '🥗', moodTags: ['Zinde', 'Motivasyonlu', 'Enerjik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.84,
  ),
  FoodModel(
    id: 'f_ext3_18', name: 'Chia Pudding', mealTypes: ['Kahvaltı', 'Tatlı', 'Atıştırmalık'], place: ['Evde', 'Ofiste'], timeMinutes: 10, budget: 'Orta',
    dietTags: ['Vegan', 'Sağlıklı', 'Fit', 'Glutensiz'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Chia Tohumu', 'Hindistancevizi Sütü', 'Mango', 'Bal'], description: 'Bir gecede hazırlanan, omega-3 deposu tropikal chia pudingi.',
    imageEmoji: '🥥', moodTags: ['Ferah', 'Sağlıklı', 'Modern'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.79,
  ),

  // --- Kahvaltı Çeşitleri ---
  FoodModel(
    id: 'f_ext3_19', name: 'Tepsi Böreği', mealTypes: ['Kahvaltı', 'Atıştırmalık', 'Öğle'], place: ['Evde', 'Dışarıda'], timeMinutes: 60, budget: 'Orta',
    dietTags: ['Doyurucu', 'Geleneksel', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Yufka', 'Peynir', 'Ispanak', 'Yumurta', 'Süt', 'Sıvı Yağ'], description: 'Katı katı açılmış yufkaların ıslak harcıyla buluştuğu fırın böreği.',
    imageEmoji: '🥟', moodTags: ['Nostaljik', 'Konforlu', 'Doyurucu'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.92,
  ),
  FoodModel(
    id: 'f_ext3_20', name: 'Shakshuka', mealTypes: ['Kahvaltı', 'Öğle'], place: ['Evde', 'Dışarıda'], timeMinutes: 25, budget: 'Ucuz',
    dietTags: ['Vejetaryen', 'Proteinli', 'Sağlıklı'], cuisine: 'Ortadoğu', difficulty: 'Kolay',
    ingredients: ['Yumurta', 'Domates', 'Biber', 'Soğan', 'Kimyon', 'Pul Biber'], description: 'Baharatlı domates sosunda pişen yumurtaların Kuzey Afrika lezzeti; ekmekle muhteşem.',
    imageEmoji: '🍳', moodTags: ['Enerjik', 'Modern', 'Maceraperest'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.88,
  ),
];
