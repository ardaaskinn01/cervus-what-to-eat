import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/food_dataset.dart';
import '../../data/models/food_model.dart';
import '../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../suggestion/suggestion_notifier.dart';
import '../favorites/favorites_notifier.dart';

class FridgeModeSheet extends ConsumerStatefulWidget {
  const FridgeModeSheet({super.key});

  @override
  ConsumerState<FridgeModeSheet> createState() => _FridgeModeSheetState();
}

class _FridgeModeSheetState extends ConsumerState<FridgeModeSheet> {
  final List<String> _commonIngredients = [
    'Yumurta', 'Domates', 'Peynir', 'Tavuk', 'Makarna', 'Pirinç', 'Ekmek', 'Yoğurt',
    'Soğan', 'Sarımsak', 'Patates', 'Kıyma', 'Süt', 'Tereyağı', 'Un',
    
    // Baklagiller ve Tahıllar
    'Nohut', 'Fasulye', 'Kırmızı Mercimek', 'Yeşil Mercimek', 'Bulgur', 
    'Kinoa', 'Yulaf', 'Barbunya',
    
    // Et ve Deniz Ürünleri
    'Sucuk', 'Sosis', 'Salam', 'Kavurma', 'Köfte', 'Balık', 'Ton Balığı',
    'Karides', 'Kalamar', 'Midye', 'Hamsi', 'Somon',
    
    // Peynir Çeşitleri
    'Kaşar Peyniri', 'Beyaz Peynir', 'Tulum Peyniri', 'Lor Peyniri', 
    'Mozzarella', 'Cheddar', 'Örgü Peyniri', 'Ezine Peyniri',
    
    // Sebzeler
    'Salatalık', 'Biber', 'Havuç', 'Kabak', 'Patlıcan', 'Ispanak', 'Brokoli',
    'Lahana', 'Karnabahar', 'Pırasa', 'Kereviz', 'Marul', 'Roka', 'Maydanoz', 
    'Nane', 'Mantar', 'Taze Fasulye', 'Mısır', 'Bezelye',
    
    // Meyveler ve Egzotik
    'Elma', 'Armut', 'Muz', 'Çilek', 'Portakal', 'Mandalina', 'Limon', 
    'Avokado', 'Mango', 'Hindistan Cevizi', 'Ananas', 'Kivi', 'Nar',
    
    // Soslar ve Konserveler
    'Salça', 'Ketçap', 'Mayonez', 'Hardal', 'Soya Sosu', 'Nar Ekşisi',
    'Zeytinyağı', 'Sirke', 'Konserve Domates', 'Konserve Ton Balığı', 
    'Konserve Mısır', 'Turşu',
    
    // Baharatlar
    'Tuz', 'Karabiber', 'Pul Biber', 'Kekik', 'Nane (Kuru)', 'Kimyon',
    'Zerdeçal', 'Tarçın', 'Sumak', 'Karbonat', 'Kabartma Tozu', 'Vanilya'
  ];
  final Set<String> _selectedIngredients = {};
  final TextEditingController _customIngredientController = TextEditingController();
  List<Map<String, dynamic>> _matchedFoods = [];

  void _calculateMatches() {
    _matchedFoods.clear();
    if (_selectedIngredients.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    for (var food in foodDataset) {
      if (food.ingredients.isEmpty) continue;
      
      int matchCount = 0;
      for (var reqIng in food.ingredients) {
        if (_selectedIngredients.any((s) => reqIng.toLowerCase().contains(s.toLowerCase()))) {
          matchCount++;
        }
      }

      if (matchCount > 0) {
        double ratio = matchCount / food.ingredients.length;
        _matchedFoods.add({
          'food': food,
          'matchCount': matchCount,
          'total': food.ingredients.length,
          'ratio': ratio,
        });
      }
    }

    _matchedFoods.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));
    if (mounted) setState(() {});
  }

  void _addCustomIngredient() {
    final text = _customIngredientController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _selectedIngredients.add(text);
        _customIngredientController.clear();
      });
    }
  }

  @override
  void dispose() {
    _customIngredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.kitchen_outlined, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Text('Buzdolabı Modu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const Text('Evinizdeki malzemeleri seçin veya ekleyin:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    
                    // Search / Add Box
                    TextField(
                      controller: _customIngredientController,
                      onSubmitted: (_) => _addCustomIngredient(),
                      decoration: InputDecoration(
                        hintText: 'Başka ne var? (Örn: Havuç)',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                          onPressed: _addCustomIngredient,
                        ),
                        filled: true,
                        fillColor: AppColors.textSecondary.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonIngredients.map((i) {
                        final isSelected = _selectedIngredients.contains(i);
                        return FilterChip(
                          label: Text(i),
                          selected: isSelected,
                          onSelected: (val) {
                            setState(() {
                              if (val) _selectedIngredients.add(i);
                              else _selectedIngredients.remove(i);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    // Custom Ingredients Chips
                    if (_selectedIngredients.any((e) => !_commonIngredients.contains(e))) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedIngredients
                            .where((e) => !_commonIngredients.contains(e))
                            .map((i) => Chip(
                                  label: Text(i),
                                  onDeleted: () => setState(() => _selectedIngredients.remove(i)),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                ))
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _calculateMatches,
                          child: const Text('Bunlarla ne yapabilirim?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_matchedFoods.isNotEmpty) ...[
                      const Text('Uygun Yemekler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      ..._matchedFoods.map((m) {
                        final FoodModel food = m['food'];
                        final ratio = (m['ratio'] as double) * 100;
                        final isFav = ref.watch(favoritesNotifierProvider.notifier).isFavorite(food.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black.withOpacity(0.03)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              height: 48,
                              width: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(food.imageEmoji, style: const TextStyle(fontSize: 28)),
                            ),
                            title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${m['matchCount']}/${m['total']} malzeme sende var!', style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: isFav ? Colors.red : Colors.grey),
                                  onPressed: () => ref.read(favoritesNotifierProvider.notifier).toggleFavorite(food.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.casino_outlined, color: AppColors.primary),
                                  onPressed: () {
                                    ref.read(suggestionNotifierProvider.notifier).setCurrentFood(food);
                                    Navigator.pop(context);
                                    context.push('/suggestion');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ).animate().scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOut).fade();
                      }).toList()
                    ] else if (_selectedIngredients.isNotEmpty) ...[
                      const Center(child: Text('Hesaplamak için butona basın.', style: TextStyle(color: AppColors.textSecondary))),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
