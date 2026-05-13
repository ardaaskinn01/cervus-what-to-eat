import 'package:flutter/material.dart';
import '../../data/datasources/food_dataset.dart';
import '../../data/models/food_model.dart';
import '../../core/theme/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FridgeModeSheet extends StatefulWidget {
  const FridgeModeSheet({super.key});

  @override
  State<FridgeModeSheet> createState() => _FridgeModeSheetState();
}

class _FridgeModeSheetState extends State<FridgeModeSheet> {
  final List<String> _commonIngredients = [
    'Yumurta', 'Domates', 'Peynir', 'Tavuk', 'Makarna', 'Pirinç', 'Ekmek', 'Yoğurt',
    'Soğan', 'Sarımsak', 'Patates', 'Kıyma', 'Süt', 'Tereyağı', 'Un'
  ];

  final Set<String> _selectedIngredients = {};
  List<Map<String, dynamic>> _matchedFoods = [];

  void _calculateMatches() {
    _matchedFoods.clear();
    if (_selectedIngredients.isEmpty) {
      setState(() {});
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
    setState(() {});
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Ne Var Evde? 🧊', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const Text('Evinizdeki malzemeleri seçin:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _calculateMatches,
                        child: const Text('Bunlarla ne yapabilirim?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_matchedFoods.isNotEmpty) ...[
                      const Text('Uygun Yemekler:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      ..._matchedFoods.map((m) {
                        final FoodModel food = m['food'];
                        final ratio = (m['ratio'] as double) * 100;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: Text(food.imageEmoji, style: const TextStyle(fontSize: 32)),
                            title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${m['matchCount']}/${m['total']} malzeme sende var!'),
                            trailing: Text('%${ratio.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, color: ratio > 70 ? Colors.green : Colors.orange)),
                          ),
                        ).animate().scale().fade();
                      }).toList()
                    ] else if (_selectedIngredients.isNotEmpty) ...[
                      const Center(child: Text('Hesaplamak için butona basın veya malzeme seçin.')),
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
