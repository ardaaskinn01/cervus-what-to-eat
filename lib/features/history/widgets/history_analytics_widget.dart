import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../history_notifier.dart';
import '../../../core/theme/colors.dart';
import '../../../data/datasources/food_dataset.dart';

class HistoryAnalyticsWidget extends ConsumerWidget {
  const HistoryAnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyNotifierProvider);
    final theme = Theme.of(context);

    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final eatenLast7Days = history.where((e) => e.isEaten && e.date.isAfter(sevenDaysAgo)).toList();

    Map<String, int> cuisineCounts = {};
    int totalHealthy = 0;
    int totalUnhealthy = 0;

    for (var entry in eatenLast7Days) {
      final food = foodDataset.firstWhere((f) => f.id == entry.foodId, orElse: () => foodDataset.first);
      cuisineCounts[food.cuisine] = (cuisineCounts[food.cuisine] ?? 0) + 1;
      if (food.dietTags.contains('Sağlıklı') || food.calorieRange == 'Düşük') totalHealthy++; else totalUnhealthy++;
    }

    final sortedCuisines = cuisineCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final totalFoods = totalHealthy + totalUnhealthy;
    final healthyRatio = totalFoods == 0 ? 0.0 : (totalHealthy / totalFoods);

    return Column(
      children: [
        // 1. TOP CARDS: Metrics
        Row(
          children: [
            Expanded(child: _buildMetricCard('Sağlıklı Seçim', '${(healthyRatio * 100).toInt()}%', Icons.favorite_rounded, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Öğün Sayısı', '$totalFoods', Icons.restaurant_rounded, AppColors.primary)),
          ],
        ),
        const SizedBox(height: 24),

        // 2. PIE CHART CARD
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mutfak Tercihleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 35,
                        sections: sortedCuisines.take(4).map((e) {
                          final i = sortedCuisines.indexOf(e);
                          final colors = [AppColors.primary, AppColors.secondary, Colors.amber, Colors.purple];
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            color: colors[i % colors.length],
                            radius: 18,
                            showTitle: false,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: sortedCuisines.take(4).map((e) {
                        final i = sortedCuisines.indexOf(e);
                        final colors = [AppColors.primary, AppColors.secondary, Colors.amber, Colors.purple];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[i % colors.length])),
                              const SizedBox(width: 10),
                              Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                              Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
