import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'history_notifier.dart';
import 'widgets/history_analytics_widget.dart';
import '../../core/theme/colors.dart';
import '../../data/models/history_model.dart';
import '../../data/datasources/food_dataset.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyNotifierProvider);
    final theme = Theme.of(context);

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final todayEntries = history.where((e) => DateFormat('yyyy-MM-dd').format(e.date) == todayStr).toList();
    
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final weekEntries = history.where((e) => e.date.isAfter(sevenDaysAgo)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeme Günlüğü'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Bugün'),
            Tab(text: 'Bu Hafta'),
            Tab(text: 'Tümü'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimeline(todayEntries, theme, 'Bugün henüz kayıt yok.'),
          _buildWeeklyView(weekEntries, theme),
          _buildTimeline(history, theme, 'Geçmişin tertemiz!'),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<HistoryEntry> entries, ThemeData theme, String emptyMsg) {
    if (entries.isEmpty) return _buildEmptyState(emptyMsg);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildEntryTile(entries[index], theme),
    );
  }

  Widget _buildWeeklyView(List<HistoryEntry> entries, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const HistoryAnalyticsWidget().animate().fade(),
        const SizedBox(height: 40),
        const Text('Haftalık Özet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Veri bulunamadı.')))
        else
          ...entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEntryTile(e, theme),
              )),
      ],
    );
  }

  Widget _buildEntryTile(HistoryEntry entry, ThemeData theme) {
    final food = foodDataset.firstWhere((f) => f.id == entry.foodId, orElse: () => foodDataset.first);
    final timeStr = DateFormat('HH:mm').format(entry.date);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(food.imageEmoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(timeStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          _buildBadge(entry.isEaten),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isEaten) {
    final color = isEaten ? Colors.green : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isEaten ? 'Yendi' : 'Önerildi',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: AppColors.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
