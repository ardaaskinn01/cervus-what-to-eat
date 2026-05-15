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
      // İlk yükleme yapıldıysa ve mesafe çok değiştiyse veya 30sn olduysa logic eklenebilir
      // Şimdilik sadece konumu güncel tutuyoruz.
    });
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
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
    state = state.copyWith(selectedPlace: place);
  }

  void setUserPosition(LatLng position) {
    state = state.copyWith(userPosition: position);
  }

  Future<void> loadNearby(LatLng pos, String filter, String searchQuery) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      String keyword = filter == 'Tümü' ? 'restaurant' : filter;
      if (searchQuery.trim().isNotEmpty) {
        keyword = '${searchQuery.trim()} $keyword';
      }
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'location': '${pos.latitude},${pos.longitude}',
          'radius': '1500',
          'type': 'restaurant',
          'keyword': keyword,
          'key': AppStrings.googleMapsApiKey,
        },
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
          error: 'Places API Hatası: ${response.data['status']}'
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Bir hata oluştu: $e');
    }
  }
}
