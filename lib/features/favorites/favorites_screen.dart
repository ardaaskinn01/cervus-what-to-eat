import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'favorites_notifier.dart';
import '../../core/theme/colors.dart';
import '../../data/models/food_model.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool isGridMode = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesNotifierProvider);
    final theme = Theme.of(context);

    List<FoodModel> displayFoods = [];
    if (state.selectedListId == null) {
      displayFoods = state.favorites;
    } else {
      final selectedList = state.customLists.firstWhere((l) => l.id == state.selectedListId);
      displayFoods = state.favorites.where((f) => selectedList.foodIds.contains(f.id)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(isGridMode ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => isGridMode = !isGridMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. HORIZONTAL TABS (CHIPS)
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildListTab(
                  label: 'Tümü',
                  isSelected: state.selectedListId == null,
                  onTap: () => ref.read(favoritesNotifierProvider.notifier).selectList(null),
                ),
                ...state.customLists.map((cl) => _buildListTab(
                  label: cl.name,
                  isSelected: state.selectedListId == cl.id,
                  onTap: () => ref.read(favoritesNotifierProvider.notifier).selectList(cl.id),
                )),
                _buildAddButton(),
              ],
            ),
          ),
          const Divider(height: 32, thickness: 1, color: Colors.transparent),

          // 2. CONTENT AREA
          Expanded(
            child: displayFoods.isEmpty
                ? _buildEmptyState(theme)
                : isGridMode
                    ? _buildGridView(displayFoods)
                    : _buildListView(displayFoods),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildAddButton() {
    return IconButton(
      onPressed: _showCreateListDialog,
      icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
    );
  }

  Widget _buildGridView(List<FoodModel> foods) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: foods.length,
      itemBuilder: (context, index) => _buildGridItem(foods[index]),
    );
  }

  Widget _buildGridItem(FoodModel food) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(food.imageEmoji, style: const TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 12),
          Text(
            food.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          Text(food.cuisine, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    ).animate().fade().scale(delay: 50.ms);
  }

  Widget _buildListView(List<FoodModel> foods) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: foods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildListItem(foods[index]),
    );
  }

  Widget _buildListItem(FoodModel food) {
    return Dismissible(
      key: ValueKey(food.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(favoritesNotifierProvider.notifier).removeFavorite(food.id);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Text(food.imageEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('${food.timeMinutes} dk • ${food.budget}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    ).animate().fade().slideX(begin: 0.1);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline_rounded, size: 80, color: AppColors.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text('Henüz favorin yok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Beğendiğin yemekleri kalp ikonuna\nbasarak buraya ekleyebilirsin.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showCreateListDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Liste'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Liste ismi (Örn: Haftasonu)'),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (name.isNotEmpty) {
                ref.read(favoritesNotifierProvider.notifier).createCustomList(name, '📁', 0xFF4CAF50);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Oluştur'),
          )
        ],
      ),
    );
  }
}
