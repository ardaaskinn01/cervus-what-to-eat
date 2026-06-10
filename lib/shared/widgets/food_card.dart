import 'package:flutter/material.dart';
import '../../data/models/food_model.dart';
import '../../core/theme/colors.dart';
import 'glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FoodCard extends StatefulWidget {
  final FoodModel food;
  final String? currentMood;
  final bool isCompact;
  final VoidCallback? onLongPress;

  const FoodCard({
    super.key,
    required this.food,
    this.currentMood,
    this.onLongPress,
    this.isCompact = false,
  });

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _isIngredientsExpanded = false;

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
                height: widget.isCompact ? 160 : 240,
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
                widget.food.imageEmoji,
                style: TextStyle(fontSize: widget.isCompact ? 80 : 110),
              )
.animate(onPlay: (c) => c.repeat(reverse: true))
               .moveY(begin: -5, end: 5, duration: 2000.ms, curve: Curves.easeInOut),
            ],
          ),

          // 2. MIDDLE SECTION: Content
          Padding(
            padding: EdgeInsets.all(widget.isCompact ? 20 : 24),
            child: Column(
              children: [
                Text(
                  widget.food.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: widget.isCompact ? 24 : 28, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.food.cuisine.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.secondary, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: widget.isCompact ? 16 : 40),

                // 3. INFO CHIPS
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildCompactChip(Icons.timer_outlined, '${widget.food.timeMinutes} dk', Colors.blue),
                    _buildCompactChip(Icons.payments_outlined, widget.food.budget, Colors.green),
                    _buildCompactChip(Icons.restaurant_outlined, widget.food.place.first, Colors.orange),
                    _buildCompactChip(Icons.local_fire_department_outlined, widget.food.difficulty, Colors.red),
                  ],
                ),
                SizedBox(height: widget.isCompact ? 16 : 40),

                // 4. DIET TAGS - Hidden in compact mode
                if (!widget.isCompact && widget.food.dietTags.isNotEmpty)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: widget.food.dietTags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
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
                if (!widget.isCompact) const SizedBox(height: 32),

                // 5. INGREDIENTS
                if (widget.food.ingredients.isNotEmpty) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _isIngredientsExpanded = !_isIngredientsExpanded),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_basket_outlined, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'MALZEMELER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isIngredientsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(height: 16, width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 28),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: widget.food.ingredients.map((ing) => Text(
                          ing + (ing == widget.food.ingredients.last ? '' : ' • '),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                          ),
                        )).toList(),
                      ),
                    ),
                    crossFadeState: _isIngredientsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                ],

                // 6. DESCRIPTION - Hidden in compact mode
                if (!widget.isCompact)
                  Text(
                    widget.food.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                if (!widget.isCompact) const SizedBox(height: 32),

                // 7. PROGRESS INDICATORS
                Builder(
                  builder: (context) {
                    final caloriePct = _calculateCaloriePercentage(widget.food);
                    final satiationPct = _calculateSatiationPercentage(widget.food);
                    return Row(
                      children: [
                        Expanded(child: _buildProgressCard('KALORİ', _calorieColor(widget.food.calorieRange, isDark), caloriePct, isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildProgressCard('DOYURUCULUK', _satiationColor(satiationPct, isDark), satiationPct, isDark)),
                      ],
                    );
                  }
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
        color: color.withValues(alpha: isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.1)),
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
              backgroundColor: color.withValues(alpha: isDark ? 0.2 : 0.1),
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

  double _calculateCaloriePercentage(FoodModel food) {
    double base = 0.5;
    
    switch (food.calorieRange.toLowerCase()) {
      case 'düşük': base = 0.25; break;
      case 'orta': base = 0.55; break;
      case 'yüksek': base = 0.85; break;
    }
    
    final tags = food.dietTags.map((t) => t.toLowerCase()).toList();
    if (tags.contains('hafif')) base -= 0.10;
    if (tags.contains('sağlıklı')) base -= 0.05;
    if (tags.contains('kaçamak')) base += 0.15;
    if (tags.contains('proteinli')) base += 0.05;
    
    final ingredients = food.ingredients.map((i) => i.toLowerCase()).toList();
    final highCalIngredients = ['kızartma', 'krema', 'tereyağı', 'şeker', 'çikolata', 'hamur', 'kaşar', 'mayonez', 'sos'];
    final lowCalIngredients = ['yeşillik', 'domates', 'salatalık', 'limon', 'yoğurt', 'sebze'];
    
    int highCount = ingredients.where((i) => highCalIngredients.any((hc) => i.contains(hc))).length;
    int lowCount = ingredients.where((i) => lowCalIngredients.any((lc) => i.contains(lc))).length;
    
    base += (highCount * 0.06);
    base -= (lowCount * 0.03);
    
    return base.clamp(0.15, 0.95);
  }

  double _calculateSatiationPercentage(FoodModel food) {
    double base = 0.60;
    
    final tags = food.dietTags.map((t) => t.toLowerCase()).toList();
    if (tags.contains('doyurucu')) base = 0.85;
    else if (tags.contains('hafif')) base = 0.40;
    
    if (tags.contains('proteinli')) base += 0.10;
    
    final ingredients = food.ingredients.map((i) => i.toLowerCase()).toList();
    final heavyIngredients = ['et', 'tavuk', 'kıyma', 'pirinç', 'makarna', 'patates', 'ekmek', 'nohut', 'fasulye', 'mercimek', 'lavaş', 'burger'];
    final lightIngredients = ['yeşillik', 'salata', 'kavun', 'karpuz', 'meyve'];
    
    int heavyCount = ingredients.where((i) => heavyIngredients.any((hc) => i.contains(hc))).length;
    int lightCount = ingredients.where((i) => lightIngredients.any((lc) => i.contains(lc))).length;
    
    base += (heavyCount * 0.08);
    base -= (lightCount * 0.05);
    
    if (food.timeMinutes >= 45) base += 0.08;
    else if (food.timeMinutes <= 15) base -= 0.05;

    return base.clamp(0.20, 0.98);
  }

  Color _satiationColor(double percent, bool isDark) {
    if (percent < 0.5) return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
    if (percent < 0.75) return isDark ? Colors.purple.shade300 : Colors.purple.shade500;
    return isDark ? Colors.deepPurple.shade300 : Colors.deepPurple.shade600;
  }
}
