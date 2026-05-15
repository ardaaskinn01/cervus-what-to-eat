import '../models/food_model.dart';

final List<FoodModel> foodDatasetExtended = [
  // --- Çorbalar ---
  FoodModel(
    id: 'f_ext_1', name: 'Yayla Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 30, budget: 'Ucuz',
    dietTags: ['Hafif', 'Sağlıklı', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Yoğurt', 'Pirinç', 'Nane', 'Yumurta'], description: 'Naneli yağıyla şifa veren, içinizi ısıtan yöresel çorba.',
    imageEmoji: '🍲', moodTags: ['Konforlu', 'Nostaljik'], weatherTags: ['Soğuk', 'Yağmurlu', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext_2', name: 'Ezogelin Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 40, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Vegan', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Kırmızı Mercimek', 'Bulgur', 'Nane', 'Salça'], description: 'Bulgur ve mercimeğin harika uyumu, esnaf lokantalarının vazgeçilmezi.',
    imageEmoji: '🥣', moodTags: ['Geleneksel', 'Enerjik'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.90,
  ),
  FoodModel(
    id: 'f_ext_3', name: 'Domates Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 25, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Hafif', 'Vejetaryen'], cuisine: 'Dünya', difficulty: 'Kolay',
    ingredients: ['Domates', 'Kaşar Peyniri', 'Tereyağı'], description: 'Üzerinde eriyen kaşarıyla klasik lezzet.',
    imageEmoji: '🍅', moodTags: ['Hafif', 'Konforlu'], weatherTags: ['Soğuk', 'Yağmurlu'], calorieRange: 'Düşük', popularityScore: 0.82,
  ),
  FoodModel(
    id: 'f_ext_4', name: 'İşkembe Çorbası', mealTypes: ['Gece', 'Atıştırmalık', 'Öğle'], place: ['Dışarıda'], timeMinutes: 60, budget: 'Orta',
    dietTags: ['Kaçamak', 'Proteinli'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['İşkembe', 'Sarımsak', 'Sirke'], description: 'Gecelerin kurtarıcısı, sarımsak ve sirkeli şifa.',
    imageEmoji: '🥣', moodTags: ['Maceraperest', 'Nostaljik'], weatherTags: ['Soğuk', 'Gece'], calorieRange: 'Orta', popularityScore: 0.70,
  ),
  FoodModel(
    id: 'f_ext_5', name: 'Tavuk Suyu Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 45, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Proteinli'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Tavuk', 'Şehriye', 'Havuç', 'Limon'], description: 'Hastalıklara kalkan, bol limonlu şifa kaynağı.',
    imageEmoji: '🍜', moodTags: ['Konforlu', 'Hafif'], weatherTags: ['Soğuk'], calorieRange: 'Orta', popularityScore: 0.88,
  ),

  // --- Balık & Kadıköy Klasikleri ---
  FoodModel(
    id: 'f_ext_6', name: 'Hamsi Tava', mealTypes: ['Akşam'], place: ['Dışarıda', 'Evde'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Proteinli', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Hamsi', 'Mısır Unu', 'Limon'], description: 'Karadeniz fırtınası, mısır unuyla çıtır çıtır hamsi ziyafeti.',
    imageEmoji: '🐟', moodTags: ['Enerjik', 'Sosyalleşme'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.89,
  ),
  FoodModel(
    id: 'f_ext_7', name: 'Palamut Izgara', mealTypes: ['Akşam'], place: ['Dışarıda', 'Evde'], timeMinutes: 40, budget: 'Pahalı',
    dietTags: ['Sağlıklı', 'Proteinli', 'Fit'], cuisine: 'Deniz Ürünleri', difficulty: 'Orta',
    ingredients: ['Palamut', 'Zeytinyağı', 'Limon'], description: 'Mevsiminde lüferden daha çok satılan ızgara kralı.',
    imageEmoji: '🐠', moodTags: ['Keyifli', 'Özel'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.80,
  ),
  FoodModel(
    id: 'f_ext_8', name: 'Midye Dolma', mealTypes: ['Atıştırmalık', 'Gece'], place: ['Dışarıda'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Pratik', 'Kaçamak', 'Sokak Lezzeti'], cuisine: 'Sokak Lezzeti', difficulty: 'Zor',
    ingredients: ['Midye', 'Pirinç', 'Kuş Üzümü', 'Limon'], description: 'Bir tane ile başlayıp durduramadığınız eşsiz sokak tatlısı.',
    imageEmoji: '🦪', moodTags: ['Nostaljik', 'Sosyalleşme'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.95,
  ),
  FoodModel(
    id: 'f_ext_9', name: 'Balık Ekmek', mealTypes: ['Öğle', 'Akşam', 'Atıştırmalık'], place: ['Dışarıda'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Doyurucu', 'Sokak Lezzeti'], cuisine: 'Sokak Lezzeti', difficulty: 'Kolay',
    ingredients: ['Ekmek', 'Uskumru', 'Soğan', 'Limon'], description: 'Eminönü/Kadıköy sahilinin rüzgarı eşliğinde tam keyif.',
    imageEmoji: '🥖', moodTags: ['Maceraperest', 'Nostaljik'], weatherTags: ['Güneşli', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.92,
  ),

  // --- Salatalar ---
  FoodModel(
    id: 'f_ext_10', name: 'Coleslaw', mealTypes: ['Atıştırmalık', 'Öğle'], place: ['Dışarıda', 'Evde'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Hafif', 'Vejetaryen'], cuisine: 'Amerikan', difficulty: 'Kolay',
    ingredients: ['Lahana', 'Havuç', 'Mayonez'], description: 'Burger ve tavukların can dostu serinletici lahana salatası.',
    imageEmoji: '🥗', moodTags: ['Hafif', 'Modern'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.75,
  ),
  FoodModel(
    id: 'f_ext_11', name: 'Gavurdağı Salatası', mealTypes: ['Akşam', 'Öğle'], place: ['Dışarıda', 'Evde'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Vegan', 'Hafif'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Domates', 'Ceviz', 'Nar Ekşisi', 'Soğan'], description: 'Kebapçıların vazgeçilmezi, bol cevizli ve ekşili şölen.',
    imageEmoji: '🥗', moodTags: ['Geleneksel', 'Enerjik'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f_ext_12', name: 'Çoban Salata', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Vegan', 'Fit'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Domates', 'Salatalık', 'Biber', 'Soğan'], description: 'Yazın serinleten, her yemeğin yanına yakışan klasik.',
    imageEmoji: '🥒', moodTags: ['Hafif', 'Sade'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext_13', name: 'Semizotu Salatası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Vejetaryen', 'Fit'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Semizotu', 'Yoğurt', 'Sarımsak', 'Zeytinyağı'], description: 'Omega-3 deposu, serinletici ve pratik yeşillik.',
    imageEmoji: '🥬', moodTags: ['Hafif', 'Ferah'], weatherTags: ['Sıcak'], calorieRange: 'Düşük', popularityScore: 0.80,
  ),

  // --- Vegan ---
  FoodModel(
    id: 'f_ext_14', name: 'Mercimek Köftesi', mealTypes: ['Öğle', 'Atıştırmalık', 'Akşam'], place: ['Evde', 'Ofiste'], timeMinutes: 40, budget: 'Ucuz',
    dietTags: ['Vegan', 'Sağlıklı', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Kırmızı Mercimek', 'İnce Bulgur', 'Salça', 'Yeşillik'], description: 'Çay saatlerinin yıldızı, şekil vermesi en eğlenceli ikram.',
    imageEmoji: '🌯', moodTags: ['Nostaljik', 'Sosyalleşme'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.91,
  ),
  FoodModel(
    id: 'f_ext_15', name: 'Falafel', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda', 'Evde'], timeMinutes: 45, budget: 'Orta',
    dietTags: ['Vegan', 'Proteinli', 'Ortadoğu'], cuisine: 'Ortadoğu', difficulty: 'Zor',
    ingredients: ['Nohut', 'Maydanoz', 'Kişniş', 'Sarımsak'], description: 'Dışı çıtır, içi yeşil, tahin sos ile eşsiz Ortadoğu sokak atıştırmalığı.',
    imageEmoji: '🧆', moodTags: ['Maceraperest', 'Modern'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.83,
  ),
  FoodModel(
    id: 'f_ext_16', name: 'Humus', mealTypes: ['Atıştırmalık', 'Kahvaltı'], place: ['Evde', 'Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Vegan', 'Proteinli', 'Sağlıklı'], cuisine: 'Ortadoğu', difficulty: 'Orta',
    ingredients: ['Nohut', 'Tahin', 'Limon', 'Zeytinyağı'], description: 'Pideyle sıyırmak isteyeceğiniz kremsi ve zengin meze.',
    imageEmoji: '🍲', moodTags: ['Hafif', 'Keyifli'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.86,
  ),
  FoodModel(
    id: 'f_ext_17', name: 'Mücver (Fırın)', mealTypes: ['Öğle', 'Akşam', 'Atıştırmalık'], place: ['Evde'], timeMinutes: 45, budget: 'Ucuz',
    dietTags: ['Vejetaryen', 'Sağlıklı', 'Hafif'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Kabak', 'Yumurta', 'Un', 'Dereotu'], description: 'Kabağın en lezzetli, en sevimli hali.',
    imageEmoji: '🥞', moodTags: ['Konforlu', 'Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.78,
  ),

  // --- Dünya Mutfakları ---
  FoodModel(
    id: 'f_ext_18', name: 'Pad Thai', mealTypes: ['Akşam', 'Öğle'], place: ['Dışarıda'], timeMinutes: 30, budget: 'Pahalı',
    dietTags: ['Doyurucu', 'Asya'], cuisine: 'Asya', difficulty: 'Zor',
    ingredients: ['Pirinç Eriştesi', 'Tavuk/Karides', 'Fıstık', 'Soya Sosu', 'Yumurta'], description: 'Tayland sokaklarının tatlı, ekşi, tuzu dengelenmiş şahane noodle yemeği.',
    imageEmoji: '🍜', moodTags: ['Maceraperest', 'Uzak Doğu'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.81,
  ),
  FoodModel(
    id: 'f_ext_19', name: 'Shawarma', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Doyurucu', 'Hızlı'], cuisine: 'Ortadoğu', difficulty: 'Orta',
    ingredients: ['Tavuk/Et', 'Lavaş', 'Sarımsak Sos', 'Turşu'], description: 'Ortadoğu döneri. Bol baharat ve enfes soslarla nefis.',
    imageEmoji: '🌯', moodTags: ['Açlık', 'Enerjik'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext_20', name: 'Gyros', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Doyurucu', 'Sokak Lezzeti'], cuisine: 'Yunan', difficulty: 'Orta',
    ingredients: ['Pita Ekmeği', 'Domuz/Tavuk Eti', 'Cacık', 'Patates Kızartması'], description: 'Tzatziki sosuyla ferahlayan çıtır patatesli Yunan döneri.',
    imageEmoji: '🥙', moodTags: ['Sosyalleşme', 'Geleneksel'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.77,
  ),
  FoodModel(
    id: 'f_ext_21', name: 'Bibimbap', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 35, budget: 'Pahalı',
    dietTags: ['Sağlıklı', 'Renkli'], cuisine: 'Kore', difficulty: 'Zor',
    ingredients: ['Pirinç', 'Sebzeler', 'Yumurta', 'Sığır Eti', 'Gochujang'], description: 'Kore mutfağının sıcak kasede sunulan renkli karma yemeği.',
    imageEmoji: '🥘', moodTags: ['Modern', 'Maceraperest'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.80,
  ),
  FoodModel(
    id: 'f_ext_22', name: 'Soya Soslu Noodle', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Pratik', 'Vejetaryen'], cuisine: 'Asya', difficulty: 'Orta',
    ingredients: ['Noodle', 'Soya Sosu', 'Sebzeler', 'Susam Yağı'], description: 'Wok tavadan yükselen umami patlaması.',
    imageEmoji: '🥢', moodTags: ['Hızlı', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.84,
  ),
  FoodModel(
    id: 'f_ext_23', name: 'Tikka Masala', mealTypes: ['Akşam'], place: ['Dışarıda'], timeMinutes: 45, budget: 'Pahalı',
    dietTags: ['Baharatlı', 'Proteinli'], cuisine: 'Hint', difficulty: 'Zor',
    ingredients: ['Tavuk', 'Yoğurt', 'Garam Masala', 'Domates Püresi'], description: 'Kremalı, çok baharatlı Hint klasiği.',
    imageEmoji: '🍛', moodTags: ['Maceraperest', 'Sıcacık'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.75,
  ),

  // --- Ekstra Türk / Ev Yemekleri ---
  FoodModel(
    id: 'f_ext_24', name: 'Mantarlı Sote', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 25, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Vegan', 'Pratik'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Mantar', 'Soğan', 'Biber', 'Domates'], description: 'Pratik ve lezzetli, etsiz sote şöleni.',
    imageEmoji: '🍄', moodTags: ['Hafif', 'Sağlıklı'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.70,
  ),
  FoodModel(
    id: 'f_ext_25', name: 'Fırında Sütlaç', mealTypes: ['Tatlı'], place: ['Evde', 'Dışarıda'], timeMinutes: 60, budget: 'Orta',
    dietTags: ['Tatlı', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Süt', 'Pirinç', 'Şeker', 'Nişasta'], description: 'Üstü yanık bol fındıklı unutulmaz tatlı.',
    imageEmoji: '🍮', moodTags: ['Nostaljik', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext_26', name: 'Kısır', mealTypes: ['Atıştırmalık', 'Öğle'], place: ['Evde', 'Misafirlik'], timeMinutes: 30, budget: 'Ucuz',
    dietTags: ['Vegan', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['İnce Bulgur', 'Salça', 'Marul', 'Nar Ekşisi'], description: 'Altın günlerinin biricik yıldızı.',
    imageEmoji: '🥗', moodTags: ['Nostaljik', 'Sosyalleşme'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f_ext_27', name: 'Et Döner', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 10, budget: 'Orta',
    dietTags: ['Doyurucu', 'Proteinli'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Yaprak Döner', 'Pide', 'Patates Kızartması'], description: 'Klasikleşmiş doyurucu porsiyon döner.',
    imageEmoji: '🥙', moodTags: ['Enerjik', 'Sosyalleşme'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.90,
  ),
  FoodModel(
    id: 'f_ext_28', name: 'Piyaz', mealTypes: ['Atıştırmalık', 'Öğle'], place: ['Dışarıda', 'Evde'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Vegan', 'Sağlıklı'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Haşlanmış Fasulye', 'Soğan', 'Maydanoz', 'Sirke'], description: 'Köftenin en sadık yancısı Antalya usulü ya da sade.',
    imageEmoji: '🫘', moodTags: ['Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.72,
  ),

  // --- Kahvaltı Çeşitleri ---
  FoodModel(
    id: 'f_ext_29', name: 'Su Böreği', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Dışarıda', 'Evde'], timeMinutes: 90, budget: 'Orta',
    dietTags: ['Doyurucu', 'Kaçamak'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Yufka', 'Beyaz Peynir', 'Tereyağı', 'Yumurta'], description: 'Kat kat haşlanmış yufkaların peynirle dansı.',
    imageEmoji: '🥟', moodTags: ['Nostaljik', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext_30', name: 'Peynirli Gözleme', mealTypes: ['Kahvaltı', 'Öğle'], place: ['Dışarıda', 'Evde'], timeMinutes: 20, budget: 'Ucuz',
    dietTags: ['Doyurucu', 'Pratik'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Yufka', 'Beyaz Peynir', 'Maydanoz', 'Tereyağı'], description: 'Sacda pişen sıcak ve çıtır gözleme.',
    imageEmoji: '🥞', moodTags: ['Geleneksel', 'Sıcak'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f_ext_31', name: 'Kaygana', mealTypes: ['Kahvaltı'], place: ['Evde'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Proteinli', 'Yöresel'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Yumurta', 'Un', 'Süt', 'Yeşillik'], description: 'Karadeniz usulü yeşillikli omlet krep arası lezzet.',
    imageEmoji: '🥞', moodTags: ['Yöresel', 'Nostaljik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.75,
  ),
  FoodModel(
    id: 'f_ext_32', name: 'Kaşarlı Poğaça', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Dışarıda', 'Evde', 'Ofiste'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Pratik', 'Hızlı'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Hamur', 'Kaşar Peyniri'], description: 'Acelesi olanların sıcak ve pofuduk kahvaltısı.',
    imageEmoji: '🥐', moodTags: ['Hızlı', 'Sabah'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.90,
  ),
  FoodModel(
    id: 'f_ext_33', name: 'Çılbır', mealTypes: ['Kahvaltı', 'Öğle'], place: ['Evde'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Proteinli', 'Sağlıklı', 'Hafif'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Poşe Yumurta', 'Yoğurt', 'Sarımsak', 'Tereyağı', 'Pul Biber'], description: 'Sarımsaklı yoğurt üzerine dökülen kızgın yağ ve poşe yumurta.',
    imageEmoji: '🥚', moodTags: ['Hafif', 'Zarif'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.80,
  ),
  FoodModel(
    id: 'f_ext_34', name: 'Avokadolu Tost', mealTypes: ['Kahvaltı', 'Öğle'], place: ['Evde', 'Dışarıda'], timeMinutes: 10, budget: 'Orta',
    dietTags: ['Vegan', 'Sağlıklı', 'Fit'], cuisine: 'Dünya', difficulty: 'Kolay',
    ingredients: ['Avokado', 'Ekmek', 'Limon', 'Zeytinyağı'], description: 'Modern, sağlıklı ve çok besleyici.',
    imageEmoji: '🥑', moodTags: ['Modern', 'Enerjik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f_ext_35', name: 'Krep (Peynirli)', mealTypes: ['Kahvaltı'], place: ['Evde'], timeMinutes: 20, budget: 'Ucuz',
    dietTags: ['Pratik', 'Hafif'], cuisine: 'Fransız', difficulty: 'Orta',
    ingredients: ['Un', 'Süt', 'Yumurta', 'Krem Peynir'], description: 'İster tatlı ister tuzlu yenebilen ince hamur.',
    imageEmoji: '🥞', moodTags: ['Konforlu', 'Güneşli'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.82,
  ),

  // Dahası... Toplam 35 yepyeni yiyecek eklendi, böylece dataset zenginleşti.
];
