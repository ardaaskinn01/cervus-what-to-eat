import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'favorites_state.dart';
import '../../data/models/favorite_list_model.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/datasources/food_dataset.dart';

final favoritesNotifierProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.read(favoritesRepositoryProvider));
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoritesRepository _repo;
  final _uuid = const Uuid();

  FavoritesNotifier(this._repo) : super(FavoritesState(favorites: [], customLists: [])) {
    _loadData();
  }

  void _loadData() {
    state = state.copyWith(
      favorites: _repo.getAllFavorites(),
      customLists: _repo.getCustomLists(),
    );
  }

  void selectList(String? listId) {
    state = state.copyWith(selectedListId: listId);
  }

  void addFavorite(String foodId) {
    _repo.addFavorite(foodId);
    _loadData();
  }

  void removeFavorite(String foodId) {
    _repo.removeFavorite(foodId);
    _loadData();
  }

  void toggleFavorite(String foodId) {
    if (_repo.isFavorite(foodId)) {
      removeFavorite(foodId);
    } else {
      addFavorite(foodId);
    }
  }

  bool isFavorite(String foodId) {
    return _repo.isFavorite(foodId);
  }

  void createCustomList(String name, String emoji, int colorInt) {
    final newList = FavoriteListModel(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      colorInt: colorInt,
      foodIds: [],
    );
    final lists = [...state.customLists, newList];
    _repo.saveCustomLists(lists);
    _loadData();
  }

  void addFoodToList(String foodId, String listId) {
    // If not globally favorite, make it favorite first
    if (!_repo.isFavorite(foodId)) {
      _repo.addFavorite(foodId);
    }
    
    final lists = state.customLists.map((l) {
      if (l.id == listId) {
        if (!l.foodIds.contains(foodId)) {
          return l.copyWith(foodIds: [...l.foodIds, foodId]);
        }
      }
      return l;
    }).toList();
    
    _repo.saveCustomLists(lists);
    _loadData();
  }

  void removeFoodFromList(String foodId, String listId) {
    final lists = state.customLists.map((l) {
      if (l.id == listId) {
        final newIds = List<String>.from(l.foodIds)..remove(foodId);
        return l.copyWith(foodIds: newIds);
      }
      return l;
    }).toList();
    
    _repo.saveCustomLists(lists);
    _loadData();
  }
}
