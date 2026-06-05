import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'nearby_state.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/location_service.dart';
import '../../core/providers/filter_provider.dart';

final nearbyNotifierProvider = StateNotifierProvider<NearbyNotifier, NearbyState>((ref) {
  final notifier = NearbyNotifier(ref);
  
  // Listen to global filter changes
  ref.listen(filterProvider, (previous, next) {
    notifier.loadNearbyWithGlobalFilters();
  });
  
  return notifier;
});

class NearbyNotifier extends StateNotifier<NearbyState> {
  final Ref _ref;
  final Dio _dio = Dio();
  StreamSubscription? _positionSubscription;

  NearbyNotifier(this._ref) : super(NearbyState());

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
    loadNearbyWithGlobalFilters();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadNearbyWithGlobalFilters();
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
    loadNearbyWithGlobalFilters();
  }

  /// Convenience method to reload using current state and global filters
  Future<void> loadNearbyWithGlobalFilters() async {
    if (state.userPosition != null) {
      await loadNearby(state.userPosition!, state.activeFilter, state.searchQuery);
    }
  }

  /// Called when user pans the map — loads new results for that camera position
  Future<void> loadNearbyAtPosition(LatLng pos) async {
    await loadNearby(pos, state.activeFilter, state.searchQuery);
  }

  Future<void> loadNearby(LatLng pos, String filter, String searchQuery) async {
    state = state.copyWith(isLoading: true, error: null);

    final globalFilter = _ref.read(filterProvider);

    try {
      final Map<String, dynamic> queryParams = {
        'location': '${pos.latitude},${pos.longitude}',
        'key': AppStrings.googleMapsApiKey,
        'type': 'restaurant', // Base type to ensure it's a food place
      };

      // Combine all keywords: UI Category + Search Query + Global Filters
      List<String> keywords = [];
      
      if (filter != 'Tümü' && filter.isNotEmpty) keywords.add(filter);
      if (searchQuery.trim().isNotEmpty) keywords.add(searchQuery.trim());
      
      // Add global filters to keywords for better relevance
      if (globalFilter.mealType != null) keywords.add(globalFilter.mealType!);
      if (globalFilter.cuisine != null) keywords.add(globalFilter.cuisine!);
      if (globalFilter.dietTag != null) keywords.add(globalFilter.dietTag!);

      if (keywords.isNotEmpty) {
        queryParams['keyword'] = keywords.join(' ');
      }

      // Add "Open Now" filter to API if selected
      if (globalFilter.onlyOpenNow == true) {
        queryParams['opennow'] = true;
      }

      // Budget Mapping (Google minprice/maxprice 0-4)
      if (globalFilter.budget != null) {
        switch (globalFilter.budget) {
          case 'Ucuz':
            queryParams['minprice'] = 0;
            queryParams['maxprice'] = 1;
            break;
          case 'Orta':
            queryParams['minprice'] = 1;
            queryParams['maxprice'] = 2;
            break;
          case 'Pahalı':
            queryParams['minprice'] = 3;
            queryParams['maxprice'] = 4;
            break;
        }
      }

      // Radius and Ranking
      if (state.nearbyFilter.radiusKm <= 0.5) {
        queryParams['rankby'] = 'distance';
        // When rankby=distance, radius must NOT be provided
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
