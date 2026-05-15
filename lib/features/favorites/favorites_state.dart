import '../../data/models/food_model.dart';
import '../../data/models/favorite_list_model.dart';
import '../nearby/nearby_state.dart';

class FavoritesState {
  final List<FoodModel> favorites;
  final List<NearbyPlace> favoritePlaces;
  final List<FavoriteListModel> customLists;
  final String? selectedListId; // Null means "Tüm Favoriler"
  final bool showPlaces; // Toggle between foods and places

  FavoritesState({
    required this.favorites,
    this.favoritePlaces = const [],
    required this.customLists,
    this.selectedListId,
    this.showPlaces = false,
  });

  FavoritesState copyWith({
    List<FoodModel>? favorites,
    List<NearbyPlace>? favoritePlaces,
    List<FavoriteListModel>? customLists,
    Object? selectedListId = _sentinel,
    bool? showPlaces,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      customLists: customLists ?? this.customLists,
      selectedListId: selectedListId == _sentinel ? this.selectedListId : (selectedListId as String?),
      showPlaces: showPlaces ?? this.showPlaces,
    );
  }

  static const _sentinel = Object();
}
