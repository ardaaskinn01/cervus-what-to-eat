import 'package:flutter/material.dart';
import '../../data/models/food_model.dart';
import '../../core/theme/colors.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP SECTION: Patterned Gradient & Emoji
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
              ),
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    food.imageEmoji,
                    style: const TextStyle(fontSize: 90),
                  ),
                ),
              ),
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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 26, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    food.cuisine,
                    style: const TextStyle(
                      color: AppColors.secondary, 
                      fontSize: 12, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. INFO GRID
                Row(
                  children: [
                    _buildInfoItem(Icons.timer_outlined, '${food.timeMinutes} dk'),
                    _buildInfoItem(Icons.payments_outlined, food.budget),
                    _buildInfoItem(Icons.restaurant_outlined, food.place.first),
                    _buildInfoItem(Icons.local_fire_department_outlined, food.difficulty),
                  ],
                ),
                const SizedBox(height: 32),

                // 4. DIET TAGS
                if (food.dietTags.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: food.dietTags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.primary, 
                          fontSize: 12, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    )).toList(),
                  ),
                const SizedBox(height: 28),

                // 5. INGREDIENTS
                if (food.ingredients.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_basket_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'MALZEMELER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSecondary.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
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

  Widget _buildInfoItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
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
