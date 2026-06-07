import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'favorites_notifier.dart';
import '../../core/theme/colors.dart';
import '../../data/models/food_model.dart';
import '../../features/nearby/nearby_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets/food_card.dart';

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
          if (!state.showPlaces)
            IconButton(
              icon: Icon(isGridMode ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded),
              onPressed: () => setState(() => isGridMode = !isGridMode),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // FOOD VS PLACES TOGGLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildMainTab('Yemekler', !state.showPlaces, () {
                    ref.read(favoritesNotifierProvider.notifier).togglePlacesTab(false);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMainTab('Mekanlar', state.showPlaces, () {
                    ref.read(favoritesNotifierProvider.notifier).togglePlacesTab(true);
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (!state.showPlaces) ...[
            // HORIZONTAL TABS (CUSTOM LISTS)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildListTab(
                    label: 'Tümü',
                    id: null,
                    isSelected: state.selectedListId == null,
                    onTap: () => ref.read(favoritesNotifierProvider.notifier).selectList(null),
                  ),
                  ...state.customLists.map((cl) => _buildListTab(
                    label: cl.name,
                    id: cl.id,
                    isSelected: state.selectedListId == cl.id,
                    onTap: () => ref.read(favoritesNotifierProvider.notifier).selectList(cl.id),
                  )),

                  _buildAddButton(),
                ],
              ),
            ),
            const Divider(height: 32, thickness: 1, color: Colors.transparent),

            // FOOD CONTENT AREA
            Expanded(
              child: displayFoods.isEmpty
                  ? _buildEmptyState(theme, false)
                  : isGridMode
                      ? _buildGridView(displayFoods)
                      : _buildListView(displayFoods),
            ),
          ] else ...[
            // PLACES CONTENT AREA
            Expanded(
              child: state.favoritePlaces.isEmpty
                  ? _buildEmptyState(theme, true)
                  : _buildPlacesListView(state.favoritePlaces),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMainTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(isSelected ? 1.0 : 0.2)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListTab({required String label, required String? id, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onLongPress: id == null ? null : () => _showDeleteListConfirmation(id, label),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          avatar: id != null ? const Icon(Icons.folder_open_rounded, size: 14) : null,
        ),
      ),
    );
  }

  void _showDeleteListConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${name} Listesini Sil?'),
        content: const Text('Bu liste silinecek. İçindeki yemekler favorilerinden silinmez.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              ref.read(favoritesNotifierProvider.notifier).deleteCustomList(id);
              Navigator.pop(ctx);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
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
    final state = ref.watch(favoritesNotifierProvider);
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showFoodDetails(food),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(food.imageEmoji, style: const TextStyle(fontSize: 36))),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    food.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(food.cuisine, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDeleteItemConfirmation(food, state.selectedListId),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, size: 18, color: Colors.red.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ),
      ],
    ).animate().fade().scale(delay: 50.ms);
  }


  Widget _buildListView(List<FoodModel> foods) {
    final state = ref.watch(favoritesNotifierProvider);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: foods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildListItem(foods[index], state.selectedListId),
    );
  }

  Widget _buildListItem(FoodModel food, String? selectedListId) {
    return Dismissible(
      key: ValueKey('${food.id}_${selectedListId ?? "all"}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: Icon(
          selectedListId == null ? Icons.delete_outline_rounded : Icons.folder_delete_outlined, 
          color: Colors.white
        ),
      ),
      onDismissed: (_) {
        if (selectedListId == null) {
          ref.read(favoritesNotifierProvider.notifier).removeFavorite(food.id);
        } else {
          ref.read(favoritesNotifierProvider.notifier).removeFoodFromList(food.id, selectedListId);
        }
      },

      child: GestureDetector(
        onTap: () => _showFoodDetails(food),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, 
                  size: 20, 
                  color: Colors.red.withValues(alpha: 0.5)
                ),
                onPressed: () => _showDeleteItemConfirmation(food, selectedListId),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade().slideX(begin: 0.1);
  }

  void _showDeleteItemConfirmation(FoodModel food, String? listId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(listId == null ? 'Favorilerden Kaldır?' : 'Listeden Kaldır?'),
        content: Text('${food.name} ${listId == null ? "tüm favorilerinden" : "bu listeden"} kaldırılacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              if (listId == null) {
                ref.read(favoritesNotifierProvider.notifier).removeFavorite(food.id);
              } else {
                ref.read(favoritesNotifierProvider.notifier).removeFoodFromList(food.id, listId);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Kaldır', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(ThemeData theme, bool isPlaces) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isPlaces ? Icons.storefront_outlined : Icons.favorite_outline_rounded, size: 80, color: AppColors.textSecondary.withOpacity(0.2)),
          const SizedBox(height: 20),
          Text(isPlaces ? 'Favori mekanın yok' : 'Henüz favorin yok', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(isPlaces ? 'Haritadan beğendiğin restoranları\nburaya ekleyebilirsin.' : 'Beğendiğin yemekleri kalp ikonuna\nbasarak buraya ekleyebilirsin.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // --- PLACES ---

  Widget _buildPlacesListView(List<NearbyPlace> places) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final place = places[index];
        return Dismissible(
          key: ValueKey(place.placeId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) {
            ref.read(favoritesNotifierProvider.notifier).toggleFavoritePlace(place);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(place.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place.address,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${place.latLng.latitude},${place.latLng.longitude}&query_place_id=${place.placeId}");
                      launchUrl(uri);
                    },
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Haritada Aç'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
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

  void _showFoodDetails(FoodModel food) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: FoodCard(
            food: food,
            isCompact: true,
          ),
        ),
      ),
    );
  }
}
