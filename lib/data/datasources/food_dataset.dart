import '../models/food_model.dart';
import 'food_dataset_extended.dart';
import 'food_dataset_extended_2.dart';
import 'food_dataset_extended_3.dart';

final List<FoodModel> foodDataset = [
  // Kahvaltı (10)
  FoodModel(
    id: 'f1', name: 'Menemen', mealTypes: ['Kahvaltı', 'Öğle'], place: ['Evde'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Proteinli', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Yumurta', 'Domates', 'Biber'], description: 'Kısa sürede hazırlanabilen pratik ve doyurucu bir seçenek.',
    imageEmoji: '🍳', moodTags: ['Enerjik', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.9,
  ),
  FoodModel(
    id: 'f2', name: 'Tost', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Evde', 'Ofiste', 'Öğrenci Evi'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Pratik', 'Doyurucu'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Ekmek', 'Kaşar', 'Sucuk'], description: 'Hızlıca hazırlanan, peyniri erimiş klasik lezzet.',
    imageEmoji: '🥪', moodTags: ['Hızlı', 'Rahatlatıcı'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f3', name: 'Omlet', mealTypes: ['Kahvaltı'], place: ['Evde'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Proteinli', 'Fit'], cuisine: 'Ev yemeği', difficulty: 'Kolay',
    ingredients: ['Yumurta', 'Tereyağı', 'Peynir'], description: 'Güne zinde başlamak için bol proteinli bir seçenek.',
    imageEmoji: '🥚', moodTags: ['Enerjik', 'Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f4', name: 'Yulaf Lapası', mealTypes: ['Kahvaltı', 'Tatlı'], place: ['Evde', 'Öğrenci Evi'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Fit', 'Lifli'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Yulaf', 'Süt', 'Meyve', 'Bal'], description: 'Sindirim dostu, enerji verici, lezzetli ve hafif.',
    imageEmoji: '🥣', moodTags: ['Hafif', 'Sağlıklı'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.82,
  ),
  FoodModel(
    id: 'f5', name: 'Granola Bowl', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Evde', 'Dışarıda'], timeMinutes: 5, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Granola', 'Yoğurt', 'Orman Meyveleri'], description: 'Taze meyvelerle hazırlanan çıtır lezzet.',
    imageEmoji: '🍧', moodTags: ['Enerjik', 'Ferah'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.8,
  ),
  FoodModel(
    id: 'f6', name: 'Simit & Peynir', mealTypes: ['Kahvaltı'], place: ['Dışarıda', 'Ofiste', 'Evde'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Doyurucu', 'Pratik'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Simit', 'Beyaz Peynir', 'Çay'], description: 'Geleneksel Türk kahvaltısının vazgeçilmez sokak lezzeti.',
    imageEmoji: '🥯', moodTags: ['Geleneksel', 'Nostaljik'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.95,
  ),
  FoodModel(
    id: 'f7', name: 'Kuymak', mealTypes: ['Kahvaltı'], place: ['Evde', 'Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Doyurucu', 'Kaçamak'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Mısır Unu', 'Kolot Peyniri', 'Tereyağı'], description: 'Karadeniz mutfağının peynir uzatan sıcak lezzeti.',
    imageEmoji: '🥘', moodTags: ['Konforlu', 'Sıcacık'], weatherTags: ['Soğuk', 'Yağmurlu'], calorieRange: 'Yüksek', popularityScore: 0.75,
  ),
  FoodModel(
    id: 'f8', name: 'Pankek', mealTypes: ['Kahvaltı', 'Tatlı'], place: ['Evde'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Kaçamak', 'Tatlı'], cuisine: 'Amerikan', difficulty: 'Orta',
    ingredients: ['Un', 'Yumurta', 'Süt', 'Akçaağaç Şurubu'], description: 'Tatlı krizlerini kahvaltıda dindiren yumuşacık lezzet.',
    imageEmoji: '🥞', moodTags: ['Kutlama', 'Keyifli'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f9', name: 'Sahanda Sucuklu Yumurta', mealTypes: ['Kahvaltı'], place: ['Evde'], timeMinutes: 10, budget: 'Orta',
    dietTags: ['Proteinli', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Sucuk', 'Yumurta', 'Tereyağı'], description: 'Pazar kahvaltılarının kokusuyla mest eden yıldızı.',
    imageEmoji: '🍳', moodTags: ['Mutlu', 'Enerjik'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f10', name: 'Boyoz', mealTypes: ['Kahvaltı'], place: ['Dışarıda', 'Evde'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Pratik', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Boyoz', 'Haşlanmış Yumurta'], description: 'İzmir klasiği, çay ve yumurta ile mükemmel uyum.',
    imageEmoji: '🥐', moodTags: ['Hızlı', 'Nostaljik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.78,
  ),

  // Ev Yemeği (12)
  FoodModel(
    id: 'f11', name: 'Kuru Fasulye', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 45, budget: 'Orta',
    dietTags: ['Doyurucu', 'Proteinli', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Kuru Fasulye', 'Soğan', 'Salça'], description: 'Pilavla birlikte Türk mutfağının sarsılmaz klasiği.',
    imageEmoji: '🍲', moodTags: ['Konforlu', 'Doyurucu'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.9,
  ),
  FoodModel(
    id: 'f12', name: 'Mercimek Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 30, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Hafif', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Kırmızı Mercimek', 'Soğan', 'Havuç'], description: 'Her derda deva, limonla taçlanan sıcak başlangıç.',
    imageEmoji: '🥣', moodTags: ['Rahatlatıcı', 'Hafif'], weatherTags: ['Soğuk', 'Yağmurlu'], calorieRange: 'Düşük', popularityScore: 0.95,
  ),
  FoodModel(
    id: 'f13', name: 'Tavuk Sote', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Proteinli', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Tavuk Göğsü', 'Biber', 'Domates'], description: 'Besleyici, protein dolu ve makarna/pilavla uyumlu.',
    imageEmoji: '🥘', moodTags: ['Enerjik', 'Pratik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f14', name: 'Karnıyarık', mealTypes: ['Akşam'], place: ['Evde'], timeMinutes: 60, budget: 'Orta',
    dietTags: ['Doyurucu', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Patlıcan', 'Kıyma', 'Salça'], description: 'Kıymalı iç harcıyla fırınlanmış patlıcan efsanesi.',
    imageEmoji: '🍆', moodTags: ['Özel', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f15', name: 'Mantı', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 50, budget: 'Orta',
    dietTags: ['Doyurucu', 'Kaçamak'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Un', 'Kıyma', 'Yoğurt', 'Sarımsak'], description: 'Üzerine tereyağlı sos dökülmüş, sarımsaklı yoğurtlu hamur işi şöleni.',
    imageEmoji: '🥟', moodTags: ['Kutlama', 'Keyifli'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.92,
  ),
  FoodModel(
    id: 'f16', name: 'Musakka', mealTypes: ['Akşam'], place: ['Evde'], timeMinutes: 45, budget: 'Orta',
    dietTags: ['Doyurucu'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Patlıcan', 'Kıyma', 'Domates'], description: 'Dilimlenmiş patlıcanların kıymayla buluştuğu nefis fırın yemeği.',
    imageEmoji: '🥘', moodTags: ['Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.75,
  ),
  FoodModel(
    id: 'f17', name: 'Zeytinyağlı Taze Fasulye', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 40, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Hafif', 'Vejetaryen', 'Vegan'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Taze Fasulye', 'Zeytinyağı', 'Domates'], description: 'Soğuk da yenebilen çok sağlıklı Ege klasiği.',
    imageEmoji: '🫘', moodTags: ['Hafif', 'Sağlıklı'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.8,
  ),
  FoodModel(
    id: 'f18', name: 'Pilav Üstü Tavuk', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 30, budget: 'Ucuz',
    dietTags: ['Doyurucu', 'Proteinli'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Pirinç', 'Tavuk', 'Nohut'], description: 'Sokak lezzetlerinin ve hızlı doyuran öğünlerin padişahı.',
    imageEmoji: '🍛', moodTags: ['Hızlı', 'Doyurucu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f19', name: 'Bamya Yemeği', mealTypes: ['Akşam'], place: ['Evde'], timeMinutes: 40, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Hafif', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Bamya', 'Domates', 'Soğan', 'Limon'], description: 'Seveninin çok sevdiği, ekşili sebze yemeği.',
    imageEmoji: '🍲', moodTags: ['Sağlıklı', 'Geleneksel'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.6,
  ),
  FoodModel(
    id: 'f20', name: 'Ispanak Yemeği', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 30, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Ispanak', 'Pirinç', 'Soğan', 'Yoğurt'], description: 'Bol demir içeren, üzerine sarımsaklı yoğurtla şahane olan yemek.',
    imageEmoji: '🥬', moodTags: ['Sağlıklı', 'Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.7,
  ),
  FoodModel(
    id: 'f21', name: 'İzmir Köfte', mealTypes: ['Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 50, budget: 'Orta',
    dietTags: ['Doyurucu', 'Proteinli'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Kıyma', 'Patates', 'Salça'], description: 'Patates ve köftelerin salçalı sosla fırınlandığı eşsiz lezzet.',
    imageEmoji: '🥔', moodTags: ['Konforlu', 'Tatmin edici'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f22', name: 'Biber Dolması', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 50, budget: 'Orta',
    dietTags: ['Doyurucu', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Dolmalık Biber', 'Pirinç', 'Kuşüzümü', 'Çam Fıstığı'], description: 'Zeytinyağlı hafif ve leziz efsane tencere yemeği.',
    imageEmoji: '🫑', moodTags: ['Geleneksel', 'Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.82,
  ),

  // Pratik (10)
  FoodModel(
    id: 'f23', name: 'Ton Balıklı Makarna', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Öğrenci Evi'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Pratik', 'Proteinli', 'Doyurucu'], cuisine: 'Öğrenci Evi', difficulty: 'Kolay',
    ingredients: ['Makarna', 'Ton Balığı', 'Mısır'], description: 'Öğrenci ve bekarların kurtarıcı proteini.',
    imageEmoji: '🍝', moodTags: ['Hızlı', 'Pratik'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.8,
  ),
  FoodModel(
    id: 'f24', name: 'Salçalı Sosis', mealTypes: ['Öğle', 'Atıştırmalık'], place: ['Evde', 'Öğrenci Evi'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Pratik', 'Kaçamak'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Sosis', 'Salça', 'Tereyağı'], description: 'Ekmeğe banmalık çocukluk favorisi hızlı atıştırmalık.',
    imageEmoji: '🌭', moodTags: ['Nostaljik', 'Mutlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.75,
  ),
  FoodModel(
    id: 'f25', name: 'Hazır Noodle (Ramen)', mealTypes: ['Öğle', 'Akşam', 'Atıştırmalık'], place: ['Evde', 'Öğrenci Evi'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Pratik', 'Kaçamak'], cuisine: 'Asya', difficulty: 'Kolay',
    ingredients: ['Noodle', 'Baharat'], description: 'Sıcak suyu ekle 3 dakika bekle; mutlak hız.',
    imageEmoji: '🍜', moodTags: ['Hızlı', 'Tembel'], weatherTags: ['Soğuk', 'Her_hava'], calorieRange: 'Orta', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f26', name: 'Tavuklu Wrap', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Ofiste', 'Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Pratik', 'Proteinli'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Lavaş', 'Tavuk', 'Marul', 'Sos'], description: 'Elde yenilebilen, taşınabilir ve oldukça doyurucu.',
    imageEmoji: '🌯', moodTags: ['Enerjik', 'Bağımsız'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.82,
  ),
  FoodModel(
    id: 'f27', name: 'Kısır', mealTypes: ['Öğle', 'Atıştırmalık'], place: ['Evde', 'Ofiste'], timeMinutes: 20, budget: 'Ucuz',
    dietTags: ['Pratik', 'Vejetaryen', 'Doyurucu'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['İnce Bulgur', 'Salça', 'Yeşillik', 'Nar Ekşisi'], description: 'Altın günlerinin vazgeçilmez baştacı, pratik bulgur salatası.',
    imageEmoji: '🥗', moodTags: ['Sosyalleşme', 'Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.89,
  ),
  FoodModel(
    id: 'f28', name: 'Fırında Patates', mealTypes: ['Atıştırmalık', 'Akşam'], place: ['Evde'], timeMinutes: 40, budget: 'Ucuz',
    dietTags: ['Pratik', 'Sağlıklı', 'Vegan'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Patates', 'Baharat', 'Zeytinyağı'], description: 'Kızartmaya göre çok daha hafif ve yapması çok kolay baharatlı patates.',
    imageEmoji: '🥔', moodTags: ['Konforlu', 'Rahatlatıcı'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.84,
  ),
  FoodModel(
    id: 'f29', name: 'Kaşarlı Domates Çorbası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 20, budget: 'Ucuz',
    dietTags: ['Pratik', 'Hafif'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Domates', 'Un', 'Kaşar Peyniri'], description: 'Üzerinde eriyen kaşarıyla sıcak ve pratik domates çorbası.',
    imageEmoji: '🥣', moodTags: ['Sıcacık', 'Hafif'], weatherTags: ['Soğuk', 'Yağmurlu'], calorieRange: 'Düşük', popularityScore: 0.81,
  ),
  FoodModel(
    id: 'f30', name: 'Ton Balıklı Sandviç', mealTypes: ['Öğle', 'Atıştırmalık'], place: ['Ofiste', 'Öğrenci Evi', 'Evde'], timeMinutes: 10, budget: 'Orta',
    dietTags: ['Pratik', 'Proteinli'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Ekmek', 'Ton Balığı', 'Marul', 'Mısır'], description: 'Kavrulmaya veya pişirilmeye ihtiyacı olmayan sağlıklı sandviç.',
    imageEmoji: '🥪', moodTags: ['Hızlı', 'Odaklı'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.79,
  ),
  FoodModel(
    id: 'f31', name: 'Menemen (Soğansız)', mealTypes: ['Kahvaltı', 'Öğle', 'Akşam'], place: ['Evde', 'Öğrenci Evi'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Pratik', 'Proteinli', 'Vejetaryen'], cuisine: 'Türk', difficulty: 'Kolay',
    ingredients: ['Domates', 'Biber', 'Yumurta'], description: 'Günün her saati kurtaran efsane.',
    imageEmoji: '🍳', moodTags: ['Konferlu', 'Hızlı'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.93,
  ),
  FoodModel(
    id: 'f32', name: 'Salçalı Makarna', mealTypes: ['Akşam', 'Öğle'], place: ['Evde', 'Öğrenci Evi'], timeMinutes: 15, budget: 'Ucuz',
    dietTags: ['Pratik', 'Doyurucu', 'Vejetaryen'], cuisine: 'Öğrenci Evi', difficulty: 'Kolay',
    ingredients: ['Makarna', 'Salça', 'Sıvı Yağ'], description: 'Boş dolapların en pratik ve doyurucu dostu.',
    imageEmoji: '🍝', moodTags: ['Nostaljik', 'Tembel'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),

  // Dışarıda (10)
  FoodModel(
    id: 'f33', name: 'Burger', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Kaçamak', 'Doyurucu', 'Proteinli'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Hamburger Ekmeği', 'Köfte', 'Cheddar', 'Marul'], description: 'Patates ve kola eşliğinde fast food kralı.',
    imageEmoji: '🍔', moodTags: ['Kutlama', 'Neşeli'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.95,
  ),
  FoodModel(
    id: 'f34', name: 'Pizza', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda', 'Evde'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Kaçamak', 'Doyurucu'], cuisine: 'İtalyan', difficulty: 'Zor',
    ingredients: ['Hamur', 'Domates Sosu', 'Mozzarella', 'Sucuk'], description: 'Paylaşması en keyifli İtalyan efsanesi.',
    imageEmoji: '🍕', moodTags: ['Sosyalleşme', 'Kutlama'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.96,
  ),
  FoodModel(
    id: 'f35', name: 'Sushi', mealTypes: ['Akşam'], place: ['Dışarıda'], timeMinutes: 30, budget: 'Pahalı',
    dietTags: ['Sağlıklı', 'Hafif', 'Proteinli'], cuisine: 'Asya', difficulty: 'Zor',
    ingredients: ['Pirinç', 'Yosun', 'Somon', 'Soya Sosu'], description: 'Özel hissettiren oldukça estetik ve hafif Asya yemeği.',
    imageEmoji: '🍣', moodTags: ['Lüks', 'Özel', 'Odaklı'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f36', name: 'İskender', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 20, budget: 'Pahalı',
    dietTags: ['Doyurucu', 'Proteinli', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Döner', 'Pide', 'Yoğurt', 'Tereyağı'], description: 'Bol tereyağlı, pideli ve yoğurtlu Bursa şaheseri.',
    imageEmoji: '🥙', moodTags: ['Kutlama', 'Açlık'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.94,
  ),
  FoodModel(
    id: 'f37', name: 'Taco', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Kaçamak', 'Pratik'], cuisine: 'Meksika', difficulty: 'Ort',
    ingredients: ['Taco Kabuğu', 'Kıyma', 'Avokado', 'Jalapeno'], description: 'Bol soslu ve çıtır çıtır Meksika sokak lezzeti.',
    imageEmoji: '🌮', moodTags: ['Eğlenceli', 'Baharatlı'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.8,
  ),
  FoodModel(
    id: 'f38', name: 'Pide', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Doyurucu', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Hamur', 'Kıyma', 'Kaşar', 'Kuşbaşı'], description: 'Uzun ince hamurda odun ateşinde devasa lezzet.',
    imageEmoji: '🥖', moodTags: ['Doyurucu', 'Sosyalleşme'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.89,
  ),
  FoodModel(
    id: 'f39', name: 'Lahmacun', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda', 'Evde'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Pratik', 'Doyurucu', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Hamur', 'Kıyma', 'Maydanoz', 'Limon'], description: 'İncecik hamurlu, bol köpüklü ayranın en iyi dostu.',
    imageEmoji: '🌯', moodTags: ['Hızlı', 'Neşeli'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.98,
  ),
  FoodModel(
    id: 'f40', name: 'Adana Kebap', mealTypes: ['Akşam'], place: ['Dışarıda'], timeMinutes: 25, budget: 'Orta',
    dietTags: ['Doyurucu', 'Proteinli', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Kıyma', 'Kuyruk Yağı', 'Soğan', 'Lavaş'], description: 'Zırhla çekilmiş acılı muhteşem kebap.',
    imageEmoji: '🍢', moodTags: ['Kutlama', 'Doyurucu'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.93,
  ),
  FoodModel(
    id: 'f41', name: 'Tavuk Döner', mealTypes: ['Öğle', 'Akşam', 'Atıştırmalık'], place: ['Dışarıda'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Pratik', 'Doyurucu'], cuisine: 'Fast Food', difficulty: 'Kolay',
    ingredients: ['Lavaş', 'Tavuk Döner', 'Patates', 'Ketçap/Mayonez'], description: 'Bütçe dostu efsane zurna dürüm.',
    imageEmoji: '🥙', moodTags: ['Açlık', 'Hızlı'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.91,
  ),
  FoodModel(
    id: 'f42', name: 'Kumpir', mealTypes: ['Öğle', 'Akşam'], place: ['Dışarıda'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Doyurucu', 'Kaçamak'], cuisine: 'Sokak Lezzeti', difficulty: 'Kolay',
    ingredients: ['Büyük Patates', 'Kaşar', 'Tereyağı', 'Rus Salatası'], description: 'İçi bol malzeme dolu devasa fırın patates.',
    imageEmoji: '🥔', moodTags: ['Neşeli', 'Sosyalleşme'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.84,
  ),

  // Fit (10)
  FoodModel(
    id: 'f43', name: 'Izgara Tavuk Salata', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Ofiste', 'Dışarıda'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit', 'Proteinli', 'Düşük Karbonhidrat'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Tavuk Göğsü', 'Göbek Marul', 'Domates', 'Zeytinyağı'], description: 'Diyetlerin en sadık protein ve yeşillik dostu.',
    imageEmoji: '🥗', moodTags: ['Hafif', 'Sağlıklı', 'Zinde'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f44', name: 'Yoğurt Bowl', mealTypes: ['Kahvaltı', 'Atıştırmalık', 'Tatlı'], place: ['Evde', 'Ofiste'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Fit', 'Vejetaryen'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Süzme Yoğurt', 'Muz', 'Ceviz', 'Tarçın'], description: 'Hem tatlı isteğini keser hem ferahlık verir.',
    imageEmoji: '🍧', moodTags: ['Ferah', 'Enerjik'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.81,
  ),
  FoodModel(
    id: 'f45', name: 'Avokado Tost', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Evde', 'Dışarıda'], timeMinutes: 10, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit', 'Vegan', 'Vejetaryen'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Avokado', 'Ekşi Mayalı Ekmek', 'Limon', 'Karabiber'], description: 'Bol sağlıklı yağ içeren modern klasik.',
    imageEmoji: '🥑', moodTags: ['Modern', 'Zinde'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.85,
  ),
  FoodModel(
    id: 'f46', name: 'Izgara Somon', mealTypes: ['Akşam'], place: ['Evde', 'Dışarıda'], timeMinutes: 25, budget: 'Pahalı',
    dietTags: ['Sağlıklı', 'Fit', 'Proteinli', 'Düşük Karbonhidrat'], cuisine: 'Deniz Ürünleri', difficulty: 'Orta',
    ingredients: ['Somon', 'Zeytinyağı', 'Kuşkonmaz', 'Limon'], description: 'Omega-3 deposu, şık ve son derece besleyici.',
    imageEmoji: '🐟', moodTags: ['Özel', 'Zinde'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.87,
  ),
  FoodModel(
    id: 'f47', name: 'Kinoa Salatası', mealTypes: ['Öğle', 'Akşam'], place: ['Evde', 'Ofiste'], timeMinutes: 20, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit', 'Vegan', 'Glutensiz'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Kinoa', 'Roka', 'Ceviz', 'Nar'], description: 'Gluten içermeyen besleyici ve doyurucu salata.',
    imageEmoji: '🥗', moodTags: ['Hafif', 'Sağlıklı'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.76,
  ),
  FoodModel(
    id: 'f48', name: 'Haşlanmış Yumurta', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Evde'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Fit', 'Proteinli', 'Vejetaryen'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Yumurta'], description: 'Temel protein kaynağı, en saf enerji.',
    imageEmoji: '🥚', moodTags: ['Odaklı', 'Pratik'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.89,
  ),
  FoodModel(
    id: 'f49', name: 'Sebze Yemeği (Zeytinyağlı)', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 30, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Fit', 'Vegan'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Kabak', 'Havuç', 'Biber', 'Zeytinyağı'], description: 'Sindirim dostu hafif ve sızma zeytinyağlı sebzeler.',
    imageEmoji: '🥕', moodTags: ['Hafif', 'Rahatlatıcı'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.8,
  ),
  FoodModel(
    id: 'f50', name: 'Fıstık Ezmeli Yulaf Bar', mealTypes: ['Atıştırmalık', 'Kahvaltı'], place: ['Evde', 'Ofiste'], timeMinutes: 15, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit', 'Vejetaryen', 'Tatlı'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Şekersiz Fıstık Ezmesi', 'Yulaf', 'Bal'], description: 'Şeker krizini bastıran masum ve enerjik bar.',
    imageEmoji: '🍫', moodTags: ['Enerjik', 'Hızlı'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.82,
  ),
  FoodModel(
    id: 'f51', name: 'Fırın Tavuk Göğsü', mealTypes: ['Öğle', 'Akşam'], place: ['Evde'], timeMinutes: 40, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit', 'Proteinli', 'Düşük Karbonhidrat'], cuisine: 'Fit yemek', difficulty: 'Orta',
    ingredients: ['Tavuk Göğsü', 'Baharat', 'Brokoli'], description: 'Sporcuların temel yapı taşı fırında lezzetli tavuk.',
    imageEmoji: '🍗', moodTags: ['Zinde', 'Motivasyonlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.86,
  ),
  FoodModel(
    id: 'f52', name: 'Yeşil Smoothie', mealTypes: ['Kahvaltı', 'Atıştırmalık'], place: ['Evde'], timeMinutes: 5, budget: 'Orta',
    dietTags: ['Sağlıklı', 'Fit', 'Vegan'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Ispanak', 'Yeşil Elma', 'Limon', 'Zencefil'], description: 'Detoks etkili, bardak dolusu sağlık.',
    imageEmoji: '🥤', moodTags: ['Ferah', 'Zinde', 'Hızlı'], weatherTags: ['Sıcak', 'Her_hava'], calorieRange: 'Düşük', popularityScore: 0.73,
  ),

  // Tatlı (8)
  FoodModel(
    id: 'f53', name: 'Sütlaç', mealTypes: ['Tatlı'], place: ['Evde', 'Dışarıda'], timeMinutes: 45, budget: 'Ucuz',
    dietTags: ['Vejetaryen', 'Geleneksel', 'Hafif'], cuisine: 'Türk', difficulty: 'Orta',
    ingredients: ['Süt', 'Pirinç', 'Şeker', 'Fındık Kırığı'], description: 'Üzeri fırınlanıp kızarmış hafif Türk sütlü tatlısı.',
    imageEmoji: '🍮', moodTags: ['Nostaljik', 'Konforlu'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.9,
  ),
  FoodModel(
    id: 'f54', name: 'Brownie', mealTypes: ['Tatlı', 'Atıştırmalık'], place: ['Evde', 'Dışarıda', 'Ofiste'], timeMinutes: 40, budget: 'Orta',
    dietTags: ['Kaçamak', 'Vejetaryen'], cuisine: 'Amerikan', difficulty: 'Orta',
    ingredients: ['Çikolata', 'Tereyağı', 'Un', 'Şeker'], description: 'İçi ıslak, bol çikolatalı kahve yanı neşesi.',
    imageEmoji: '🍫', moodTags: ['Kutlama', 'Ödül', 'Mutlu'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.95,
  ),
  FoodModel(
    id: 'f55', name: 'Dondurma', mealTypes: ['Tatlı', 'Atıştırmalık'], place: ['Dışarıda', 'Evde'], timeMinutes: 5, budget: 'Ucuz',
    dietTags: ['Vejetaryen', 'Ferahlatıcı'], cuisine: 'Tatlı', difficulty: 'Kolay',
    ingredients: ['Süt', 'Şeker', 'Salep', 'Meyve'], description: 'Sıcak yaz günlerinde ferahlatan külah.',
    imageEmoji: '🍦', moodTags: ['Ferah', 'Neşeli'], weatherTags: ['Sıcak'], calorieRange: 'Orta', popularityScore: 0.88,
  ),
  FoodModel(
    id: 'f56', name: 'Magnolia', mealTypes: ['Tatlı'], place: ['Evde', 'Dışarıda'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Vejetaryen', 'Modern'], cuisine: 'Ev yemeği', difficulty: 'Kolay',
    ingredients: ['Süt', 'Krema', 'Bisküvi', 'Muz/Çilek'], description: 'Kavanozda sunulan meyveli muhallebi harikası.',
    imageEmoji: '🍧', moodTags: ['Tatlı kriz', 'Hafif'], weatherTags: ['Her_hava'], calorieRange: 'Orta', popularityScore: 0.86,
  ),
  FoodModel(
    id: 'f57', name: 'Tiramisu', mealTypes: ['Tatlı'], place: ['Dışarıda', 'Evde'], timeMinutes: 30, budget: 'Orta',
    dietTags: ['Vejetaryen'], cuisine: 'İtalyan', difficulty: 'Zor',
    ingredients: ['Kahve', 'Kedidili', 'Mascarpone', 'Kakao'], description: 'Beni yukarı çek anlamına gelen kahve aromalı dev lezzet.',
    imageEmoji: '🍰', moodTags: ['Ödül', 'Sofistike'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.92,
  ),
  FoodModel(
    id: 'f58', name: 'Baklava', mealTypes: ['Tatlı'], place: ['Dışarıda'], timeMinutes: 60, budget: 'Pahalı',
    dietTags: ['Kaçamak', 'Geleneksel'], cuisine: 'Türk', difficulty: 'Zor',
    ingredients: ['Yufka', 'Fıstık', 'Şerbet', 'Tereyağı'], description: 'İncecik katları ve şerbetiyle geleneksel şölen.',
    imageEmoji: '🍯', moodTags: ['Bayram', 'Kutlama'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.94,
  ),
  FoodModel(
    id: 'f59', name: 'San Sebastian Cheesecake', mealTypes: ['Tatlı'], place: ['Dışarıda'], timeMinutes: 50, budget: 'Pahalı',
    dietTags: ['Modern', 'Kaçamak', 'Vejetaryen'], cuisine: 'İspanyol', difficulty: 'Zor',
    ingredients: ['Krem Peynir', 'Krema', 'Şeker', 'Yumurta'], description: 'Dışı yanık içi akışkan peynirli şaheser.',
    imageEmoji: '🧀', moodTags: ['Trend', 'Ödül'], weatherTags: ['Her_hava'], calorieRange: 'Yüksek', popularityScore: 0.89,
  ),
  FoodModel(
    id: 'f60', name: 'Meyve Tabağı', mealTypes: ['Tatlı', 'Atıştırmalık'], place: ['Evde'], timeMinutes: 10, budget: 'Ucuz',
    dietTags: ['Sağlıklı', 'Fit', 'Vegan'], cuisine: 'Fit yemek', difficulty: 'Kolay',
    ingredients: ['Muz', 'Elma', 'Portakal', 'Kivi'], description: 'Doğal şekerli ve vitaminli en sağlıklı hafif atıştırmalık.',
    imageEmoji: '🍎', moodTags: ['Hafif', 'Sağlıklı'], weatherTags: ['Her_hava'], calorieRange: 'Düşük', popularityScore: 0.78,
  ),
  ...foodDatasetExtended,
  ...foodDatasetExtended2,
  ...foodDatasetExtended3,
];

