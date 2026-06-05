import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/datasources/food_dataset.dart';
import '../../data/models/food_model.dart';
import '../../core/theme/colors.dart';
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
    'Nohut', 'Fasulye', 'Kırmızı Mercimek', 'Yeşil Mercimek', 'Bulgur', 
    'Kinoa', 'Yulaf', 'Barbunya',
    'Sucuk', 'Sosis', 'Salam', 'Kavurma', 'Köfte', 'Balık', 'Ton Balığı',
    'Karides', 'Kalamar', 'Midye', 'Hamsi', 'Somon',
    'Kaşar Peyniri', 'Beyaz Peynir', 'Tulum Peyniri', 'Lor Peyniri', 
    'Mozzarella', 'Cheddar', 'Örgü Peyniri', 'Ezine Peyniri',
    'Salatalık', 'Biber', 'Havuç', 'Kabak', 'Patlıcan', 'Ispanak', 'Brokoli',
    'Lahana', 'Karnabahar', 'Pırasa', 'Kereviz', 'Marul', 'Roka', 'Maydanoz', 
    'Nane', 'Mantar', 'Taze Fasulye', 'Mısır', 'Bezelye',
    'Elma', 'Armut', 'Muz', 'Çilek', 'Portakal', 'Mandalina', 'Limon', 
    'Avokado', 'Mango', 'Hindistan Cevizi', 'Ananas', 'Kivi', 'Nar',
    'Salça', 'Ketçap', 'Mayonez', 'Hardal', 'Soya Sosu', 'Nar Ekşisi',
    'Zeytinyağı', 'Sirke', 'Konserve Domates', 'Konserve Ton Balığı', 
    'Konserve Mısır', 'Turşu',
    'Tuz', 'Karabiber', 'Pul Biber', 'Kekik', 'Nane (Kuru)', 'Kimyon',
    'Zerdeçal', 'Tarçın', 'Sumak', 'Karbonat', 'Kabartma Tozu', 'Vanilya'
  ];

  final Set<String> _selectedIngredients = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _matchedFoods = [];

  List<String> get _filteredIngredients {
    if (_searchQuery.isEmpty) return _commonIngredients;
    return _commonIngredients
        .where((i) => i.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _calculateMatches() {
    _matchedFoods.clear();
    if (_selectedIngredients.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    for (var food in foodDataset) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withOpacity(0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, -10),
              )
            ]
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.kitchen_rounded, color: AppColors.primary, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buzdolabı', style: theme.textTheme.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w900)),
                        Text('Elimdekilerle ne yapabilirim?', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(backgroundColor: AppColors.textSecondary.withOpacity(0.05)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Malzeme ara... (Örn: Havuç)',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_selectedIngredients.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('SEÇİLİ MALZEMELER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.2)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedIngredients.clear();
                              _matchedFoods.clear();
                            }),
                            child: const Text('Hepsini Sil', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: _selectedIngredients.map((i) => Container(
                          padding: const EdgeInsets.only(left: 14, right: 6, top: 4, bottom: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(i, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.primary),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() {
                                  _selectedIngredients.remove(i);
                                  if (_selectedIngredients.isEmpty) _matchedFoods.clear();
                                }),
                              ),
                            ],
                          ),
                        )).toList(),
                      ).animate().fade().slideY(begin: 0.1),
                      const SizedBox(height: 32),
                    ],
                    const Text('MALZEME ÖNERİLERİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _filteredIngredients.map((i) {
                        final isSelected = _selectedIngredients.contains(i);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) _selectedIngredients.remove(i);
                              else {
                                _selectedIngredients.add(i);
                                _searchQuery = '';
                                _searchController.clear();
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? AppColors.primary.withOpacity(0.1) 
                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
                            ),
                            child: Text(i, style: TextStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            )),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    if (_selectedIngredients.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: _calculateMatches,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded),
                                SizedBox(width: 12),
                                Text('Yemekleri Listele', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
                    const SizedBox(height: 40),
                    if (_matchedFoods.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.restaurant_menu_rounded, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('UYGUN YEMEKLER', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._matchedFoods.map((m) {
                        final FoodModel food = m['food'];
                        final isFav = ref.watch(favoritesNotifierProvider.notifier).isFavorite(food.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.textSecondary.withOpacity(0.05)),
                          ),
                          child: InkWell(
                            onTap: () {
                              ref.read(suggestionNotifierProvider.notifier).setCurrentFood(food);
                              Navigator.pop(context);
                              context.push('/suggestion');
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    height: 60, width: 60,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
                                    child: Text(food.imageEmoji, style: const TextStyle(fontSize: 32)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text('${m['matchCount']}/${m['total']} Malzeme Uygun', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: isFav ? Colors.redAccent : AppColors.textSecondary.withOpacity(0.3)),
                                    onPressed: () => ref.read(favoritesNotifierProvider.notifier).toggleFavorite(food.id),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fade().slideX(begin: 0.05);
                      }).toList()
                    ],
                    const SizedBox(height: 120),
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
