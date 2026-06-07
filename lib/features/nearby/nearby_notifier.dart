import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'nearby_state.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/location_service.dart';
import '../../core/providers/filter_provider.dart';

final nearbyNotifierProvider = StateNotifierProvider<NearbyNotifier, NearbyState>((ref) {
  return NearbyNotifier(ref);
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
    loadNearbyAtPosition(state.userPosition ?? const LatLng(39.9334, 32.8597));
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadNearbyAtPosition(state.userPosition ?? const LatLng(39.9334, 32.8597));
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
    loadNearbyAtPosition(state.userPosition ?? const LatLng(39.9334, 32.8597));
  }

  Future<void> loadNearbyAtPosition(LatLng pos) async {
    state = state.copyWith(isLoading: true, error: null);

    final filter = state.activeFilter;
    final searchQuery = state.searchQuery;
    final nearbyFilter = state.nearbyFilter;
    
    List<NearbyPlace> allPlaces = [];

    try {
      String? nextPageToken;
      int pagesLoaded = 0;

      do {
        final Map<String, dynamic> queryParams = {
          'location': '${pos.latitude},${pos.longitude}',
          'key': AppStrings.googleMapsApiKey,
          'type': 'restaurant',
        };

        if (nextPageToken != null) {
          queryParams.clear();
          queryParams['key'] = AppStrings.googleMapsApiKey;
          queryParams['pagetoken'] = nextPageToken;
        } else {
          // Combine keywords
          List<String> keywords = [];
          if (filter != 'Tümü' && filter.isNotEmpty) keywords.add(filter);
          if (searchQuery.trim().isNotEmpty) keywords.add(searchQuery.trim());
          
          // Map-Specific Filters (Independent from Home)
          if (nearbyFilter.cuisine != null) keywords.add(nearbyFilter.cuisine!);
          if (nearbyFilter.mealType != null) keywords.add(nearbyFilter.mealType!);
          if (nearbyFilter.budget != null) keywords.add(nearbyFilter.budget!);

          if (keywords.isNotEmpty) {
            queryParams['keyword'] = keywords.join(' ');
          }

          if (nearbyFilter.onlyOpen) {
            queryParams['opennow'] = true;
          }

          if (nearbyFilter.budget != null) {
            switch (nearbyFilter.budget) {
              case 'Ucuz': queryParams['maxprice'] = 1; break;
              case 'Orta': queryParams['minprice'] = 2; break;
              case 'Pahalı': queryParams['minprice'] = 3; break;
            }
          }

          if (nearbyFilter.radiusKm <= 0.5) {
            queryParams['rankby'] = 'distance';
          } else {
            queryParams['radius'] = '${(nearbyFilter.radiusKm * 1000).toInt()}';
          }
        }


        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
          queryParameters: queryParams,
        );

        if (response.data['status'] == 'OK' || response.data['status'] == 'ZERO_RESULTS') {
          if (response.data['status'] == 'OK') {
            final results = response.data['results'] as List;
            final newPlaces = results.map((e) => NearbyPlace.fromJson(e)).toList();
            
            // Add unique places only
            for (var p in newPlaces) {
              if (!allPlaces.any((existing) => existing.placeId == p.placeId)) {
                allPlaces.add(p);
              }
            }
            
            // Update state incrementally so markers appear faster
            state = state.copyWith(places: List.from(allPlaces));
          }
          
          nextPageToken = response.data['next_page_token'];
          pagesLoaded++;
          
          // Only load up to 60 results (3 pages) to avoid excessive API usage
          if (nextPageToken != null && pagesLoaded < 3) {
            // Delay required by Google API for token to become valid
            await Future.delayed(const Duration(milliseconds: 2000));
          } else {
            nextPageToken = null;
          }
        } else {
          // If first page fails, show error. If subsequent pages fail, just stop.
          if (pagesLoaded == 0) {
            throw Exception('API Hatası: ${response.data['status']}');
          } else {
            nextPageToken = null; 
          }
        }
      } while (nextPageToken != null);

      // Final post-fetch filtering for minRating
      if (nearbyFilter.minRating != null) {
        allPlaces = allPlaces.where((p) => p.rating >= nearbyFilter.minRating!).toList();
      }


      state = state.copyWith(places: allPlaces, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Mekanlar yüklenirken bir hata oluştu: $e');
    }
  }
}
