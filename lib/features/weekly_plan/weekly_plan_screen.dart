import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'weekly_plan_notifier.dart';
import '../../data/datasources/food_dataset.dart';
import '../../core/theme/colors.dart';

class WeeklyPlanScreen extends ConsumerStatefulWidget {
  const WeeklyPlanScreen({super.key});

  @override
  ConsumerState<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends ConsumerState<WeeklyPlanScreen> {
  final List<String> _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];
  int _selectedDay = DateTime.now().weekday;

  void _sharePlan() {
    final state = ref.read(weeklyPlanNotifierProvider);
    if (state.plan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Önce bir plan oluşturun.')));
      return;
    }

    StringBuffer text = StringBuffer('Bugün Ne Yesem? App ile Haftalık Yemek Planım 🍽️\n\n');
    for (int d = 1; d <= 7; d++) {
      if (state.plan.containsKey(d)) {
        text.writeln('📅 ${_days[d-1]}:');
        for (var meal in ['Sabah', 'Öğle', 'Akşam']) {
          final foodId = state.plan[d]![meal];
          if (foodId != null) {
            final food = foodDataset.firstWhere((f) => f.id == foodId, orElse: () => foodDataset.first);
            text.writeln('  $meal: ${food.imageEmoji} ${food.name}');
          }
        }
        text.writeln();
      }
    }
    
    Share.share(text.toString());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weeklyPlanNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Planım 📆'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePlan,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Tüm haftayı otomatik doldur',
            onPressed: () {
              ref.read(weeklyPlanNotifierProvider.notifier).autoFillPlan();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Haftalık plan akıllı algoritmayla dolduruldu!')));
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Days List
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (ctx, i) {
                int day = i + 1;
                bool isSelected = day == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_days[i], style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Plan Details View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: state.plan.containsKey(_selectedDay) 
                ? Column(
                    children: ['Sabah', 'Öğle', 'Akşam'].map((meal) {
                      final foodId = state.plan[_selectedDay]![meal];
                      if (foodId == null) return _buildEmptySlot(meal);
                      
                      final food = foodDataset.firstWhere((f) => f.id == foodId, orElse: () => foodDataset.first);
                      return _buildFoodSlot(meal, food);
                    }).toList(),
                  ).animate(key: ValueKey(_selectedDay)).fade().slideX(begin: 0.1)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 60)),
                        const SizedBox(height: 16),
                        const Text('Bu gün için plan yok.'),
                        TextButton(
                          onPressed: () => ref.read(weeklyPlanNotifierProvider.notifier).autoFillPlan(),
                          child: const Text('Otomatik Doldur'),
                        )
                      ],
                    ),
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptySlot(String meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(meal, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          const Text('Planlanmadı', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFoodSlot(String meal, food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(meal, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
          ),
          const SizedBox(width: 16),
          Text(food.imageEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
