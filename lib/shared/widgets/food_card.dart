import 'package:flutter/material.dart';
import '../../data/models/food_model.dart';
import '../../core/theme/colors.dart';
import 'glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final String? currentMood;
  final VoidCallback? onLongPress;

  const FoodCard({
    super.key,
    required this.food,
    this.currentMood,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: 32,
      blur: 20,
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
          blurRadius: 40,
          offset: const Offset(0, 20),
        )
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP SECTION: Glowing Background & Emoji
          Stack(
            alignment: Alignment.center,
            children: [
              // Dynamic Glow Effect
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                    radius: 0.7,
                  ),
                ),
              ),
              // Emoji with subtle float animation
              Text(
                food.imageEmoji,
                style: const TextStyle(fontSize: 110),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .moveY(begin: -5, end: 5, duration: 2000.ms, curve: Curves.easeInOut),
            ],
          ),

          // 2. MIDDLE SECTION: Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  food.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 28, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    food.cuisine.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.secondary, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 3. INFO CHIPS
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildCompactChip(Icons.timer_outlined, '${food.timeMinutes} dk', Colors.blue),
                    _buildCompactChip(Icons.payments_outlined, food.budget, Colors.green),
                    _buildCompactChip(Icons.restaurant_outlined, food.place.first, Colors.orange),
                    _buildCompactChip(Icons.local_fire_department_outlined, food.difficulty, Colors.red),
                  ],
                ),
                const SizedBox(height: 40),

                // 4. DIET TAGS
                if (food.dietTags.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: food.dietTags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.primary, 
                          fontSize: 13, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 32),

                // 5. INGREDIENTS
                if (food.ingredients.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_basket_outlined, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'MALZEMELER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: food.ingredients.map((ing) => Text(
                        ing + (ing == food.ingredients.last ? '' : ' • '),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary.withOpacity(0.9),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // 6. DESCRIPTION
                Text(
                  food.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // 6. PROGRESS INDICATORS
                Row(
                  children: [
                    Expanded(child: _buildProgressCard('KALORİ', _calorieColor(food.calorieRange, isDark), 0.65, isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildProgressCard('UYGUNLUK', isDark ? Colors.amber.shade300 : Colors.amber.shade700, 0.85, isDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String label, Color color, double percent, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isDark ? 0.25 : 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 1)
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withOpacity(isDark ? 0.2 : 0.1),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Color _calorieColor(String range, bool isDark) {
    switch (range.toLowerCase()) {
      case 'düşük': return isDark ? Colors.green.shade300 : Colors.green.shade600;
      case 'orta': return isDark ? Colors.orange.shade300 : Colors.orange.shade600;
      case 'yüksek': return isDark ? Colors.red.shade300 : Colors.red.shade600;
      default: return Colors.grey;
    }
  }
}
