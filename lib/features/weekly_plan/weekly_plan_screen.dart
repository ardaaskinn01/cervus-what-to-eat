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

    StringBuffer text = StringBuffer('NeYesek ile Haftalık Yemek Planım\n\n');
    for (int d = 1; d <= 7; d++) {
      if (state.plan.containsKey(d)) {
        text.writeln('${_days[d-1]}:');
        for (var meal in ['Kahvaltı', 'Öğle', 'Akşam']) {
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haftalık Planım'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
            tooltip: 'Tümünü Temizle',
            onPressed: () {
              ref.read(weeklyPlanNotifierProvider.notifier).clearAll();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Haftalık plan tamamen temizlendi.')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _sharePlan,
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
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
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                    duration: const Duration(milliseconds: 300),
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.primaryGradient : null,
                      color: isSelected ? null : theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                      border: isSelected ? null : Border.all(color: Colors.black.withOpacity(0.03)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[i], 
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900, 
                            color: isSelected ? Colors.white : AppColors.textSecondary
                          )
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Plan Details View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: ['Kahvaltı', 'Öğle', 'Akşam'].map((meal) {
                  final foodId = state.plan[_selectedDay]?[meal];
                  if (foodId == null) return _buildEmptySlot(meal);
                  
                  final food = foodDataset.firstWhere((f) => f.id == foodId, orElse: () => foodDataset.first);
                  return _buildFoodSlot(meal, food);
                }).toList(),
              ).animate(key: ValueKey(_selectedDay)).fade(duration: 400.ms).slideY(begin: 0.05),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptySlot(String meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black.withOpacity(0.04), style: BorderStyle.solid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content Row
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.restaurant_rounded, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Henüz planlanmadı',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleAction(
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    onTap: () => ref.read(weeklyPlanNotifierProvider.notifier).suggestForSlot(_selectedDay, meal),
                  ),
                  const SizedBox(width: 10),
                  _buildCircleAction(
                    icon: Icons.add_rounded,
                    color: AppColors.primary,
                    isFilled: true,
                    onTap: () => _showFoodSelectionSheet(meal),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  void _showFoodSelectionSheet(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FoodSelectionSheet(
        mealType: mealType,
        onSelected: (foodId) {
          ref.read(weeklyPlanNotifierProvider.notifier).updateSlot(_selectedDay, mealType, foodId);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFoodSlot(String meal, food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: AppColors.secondary,
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(weeklyPlanNotifierProvider.notifier).clearSlot(_selectedDay, meal),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content Row
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(child: Text(food.imageEmoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name, 
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      food.cuisine,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleAction(
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.textSecondary,
                    onTap: () => ref.read(weeklyPlanNotifierProvider.notifier).suggestForSlot(_selectedDay, meal),
                  ),
                  const SizedBox(width: 8),
                  _buildCircleAction(
                    icon: Icons.edit_note_rounded,
                    color: AppColors.primary,
                    onTap: () => _showFoodSelectionSheet(meal),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(begin: const Offset(0.98, 0.98), duration: 200.ms);
  }

  Widget _buildCircleAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFilled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: isFilled ? color : color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isFilled ? Colors.white : color, size: 20),
      ),
    );
  }
}

class _FoodSelectionSheet extends StatefulWidget {
  final String mealType;
  final Function(String) onSelected;

  const _FoodSelectionSheet({required this.mealType, required this.onSelected});

  @override
  State<_FoodSelectionSheet> createState() => _FoodSelectionSheetState();
}

class _FoodSelectionSheetState extends State<_FoodSelectionSheet> {
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter foods by mealType, category and search query
    final filteredFoods = foodDataset.where((f) {
      final matchesMeal = f.mealTypes.contains(widget.mealType);
      final matchesSearch = f.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Tümü' || f.cuisine == _selectedCategory;
      return matchesMeal && matchesSearch && matchesCategory;
    }).toList();

    // Get unique categories for the current meal type
    final categories = ['Tümü', ...foodDataset
        .where((f) => f.mealTypes.contains(widget.mealType))
        .map((f) => f.cuisine)
        .toSet()];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.mealType} Seçimi',
                        style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
                      ),
                      Text(
                        'Dilediğin yemeği listene ekle',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Yemek ara...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Categories chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Food List
          Expanded(
            child: filteredFoods.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('Yemek bulunamadı', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = filteredFoods[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(child: Text(food.imageEmoji, style: const TextStyle(fontSize: 24))),
                          ),
                          title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(food.cuisine, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                          onTap: () => widget.onSelected(food.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
