import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'nearby_state.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/location_service.dart';

final nearbyNotifierProvider = StateNotifierProvider<NearbyNotifier, NearbyState>((ref) {
  return NearbyNotifier();
});

class NearbyNotifier extends StateNotifier<NearbyState> {
  final Dio _dio = Dio();
  StreamSubscription? _positionSubscription;

  NearbyNotifier() : super(NearbyState());

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  void startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.instance.positionStream.listen((pos) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      setUserPosition(latLng);
    });
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter, clearSelectedPlace: true);
    if (state.userPosition != null) {
      loadNearby(state.userPosition!, filter, state.searchQuery);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    if (state.userPosition != null) {
      loadNearby(state.userPosition!, state.activeFilter, query);
    }
  }

  void setPermission(bool granted) {
    state = state.copyWith(isPermissionGranted: granted);
  }

  void selectPlace(NearbyPlace? place) {
    state = state.copyWith(selectedPlace: place, clearSelectedPlace: place == null);
  }

  void setUserPosition(LatLng position) {
    state = state.copyWith(userPosition: position);
  }

  void updateNearbyFilter(NearbyFilter filter) {
    state = state.copyWith(nearbyFilter: filter);
    // Reload with new radius
    if (state.userPosition != null) {
      loadNearby(state.userPosition!, state.activeFilter, state.searchQuery);
    }
  }

  /// Called when user pans the map — loads new results for that camera position
  Future<void> loadNearbyAtPosition(LatLng pos) async {
    await loadNearby(pos, state.activeFilter, state.searchQuery);
  }

  Future<void> loadNearby(LatLng pos, String filter, String searchQuery) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Map<String, dynamic> queryParams = {
        'location': '${pos.latitude},${pos.longitude}',
        'key': AppStrings.googleMapsApiKey,
        'type': 'restaurant', // Base type to ensure it's a food place
      };

      if (filter == 'Tümü' && searchQuery.trim().isEmpty) {
        // En geniş arama: Keyword'ü TAMAMEN siliyoruz.
        // Sadece 'type=restaurant' vererek Google'ın o bölgedeki tüm yemek yerlerini/büfeleri
        // hiçbir isim kısıtlaması olmadan listelemesini sağlıyoruz.
        queryParams.remove('keyword'); 
      } else {
        // Spesifik kategori veya arama sorgusu
        queryParams['keyword'] = searchQuery.trim().isNotEmpty 
            ? '${searchQuery.trim()} $filter' 
            : filter;
      }

      // 500m altı için distance, üstü için radius.
      if (state.nearbyFilter.radiusKm <= 0.5) {
        queryParams['rankby'] = 'distance';
      } else {
        queryParams['radius'] = '${(state.nearbyFilter.radiusKm * 1000).toInt()}';
      }

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: queryParams,
      );

      if (response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        final places = results.map((e) => NearbyPlace.fromJson(e)).toList();
        state = state.copyWith(places: places, isLoading: false);
      } else if (response.data['status'] == 'ZERO_RESULTS') {
        state = state.copyWith(places: [], isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Places API Hatası: ${response.data['status']}',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Bir hata oluştu: $e');
    }
  }
}
