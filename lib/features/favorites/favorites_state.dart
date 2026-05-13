import '../../data/models/food_model.dart';
import '../../data/models/favorite_list_model.dart';

class FavoritesState {
  final List<FoodModel> favorites;
  final List<FavoriteListModel> customLists;
  final String? selectedListId; // Null means "Tüm Favoriler"

  FavoritesState({
    required this.favorites,
    required this.customLists,
    this.selectedListId,
  });

  FavoritesState copyWith({
    List<FoodModel>? favorites,
    List<FavoriteListModel>? customLists,
    Object? selectedListId = _sentinel,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      customLists: customLists ?? this.customLists,
      selectedListId: selectedListId == _sentinel ? this.selectedListId : (selectedListId as String?),
    );
  }

  static const _sentinel = Object();
}
