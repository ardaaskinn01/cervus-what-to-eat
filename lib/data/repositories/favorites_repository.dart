import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../models/favorite_list_model.dart';
import '../models/food_model.dart';
import '../datasources/food_dataset.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.read(sharedPreferencesProvider));
});

class FavoritesRepository {
  final SharedPreferences _prefs;
  static const _favoritesKey = 'favorites_list';
  static const _customListsKey = 'custom_favorites_lists';

  FavoritesRepository(this._prefs);

  List<String> getAllFavoriteIds() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  void addFavorite(String foodId) {
    var list = getAllFavoriteIds();
    if (!list.contains(foodId)) {
      list.add(foodId);
      _prefs.setStringList(_favoritesKey, list);
    }
  }

  void removeFavorite(String foodId) {
    var list = getAllFavoriteIds();
    list.remove(foodId);
    _prefs.setStringList(_favoritesKey, list);

    // Also remove from custom collections
    var customLists = getCustomLists();
    bool changed = false;
    for (var cl in customLists) {
      if (cl.foodIds.contains(foodId)) {
        cl.foodIds.remove(foodId);
        changed = true;
      }
    }
    if (changed) saveCustomLists(customLists);
  }

  bool isFavorite(String foodId) {
    return getAllFavoriteIds().contains(foodId);
  }

  List<FoodModel> getAllFavorites() {
    var ids = getAllFavoriteIds();
    return foodDataset.where((f) => ids.contains(f.id)).toList();
  }

  List<FavoriteListModel> getCustomLists() {
    var str = _prefs.getString(_customListsKey);
    if (str == null) return _getDefaultLists();
    var decoded = jsonDecode(str) as List;
    return decoded.map((e) => FavoriteListModel.fromJson(e)).toList();
  }

  void saveCustomLists(List<FavoriteListModel> lists) {
    _prefs.setString(_customListsKey, jsonEncode(lists.map((e) => e.toJson()).toList()));
  }

  List<FavoriteListModel> _getDefaultLists() {
    return [
      FavoriteListModel(id: 'l1', name: 'Spor Sonrası', emoji: '💪', colorInt: 0xFF4CAF50, foodIds: []),
      FavoriteListModel(id: 'l2', name: 'Ucuz Yemekler', emoji: '💸', colorInt: 0xFFFFC107, foodIds: []),
      FavoriteListModel(id: 'l3', name: 'Hafta Sonu', emoji: '🎉', colorInt: 0xFFE91E63, foodIds: []),
    ];
  }
}
