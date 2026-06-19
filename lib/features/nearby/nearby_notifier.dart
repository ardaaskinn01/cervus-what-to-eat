import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'nearby_state.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/location_service.dart';

final nearbyNotifierProvider = StateNotifierProvider<NearbyNotifier, NearbyState>((ref) {
  return NearbyNotifier(ref);
});

class NearbyNotifier extends StateNotifier<NearbyState> {
  final Dio _dio = Dio();
  StreamSubscription? _positionSubscription;

  /// Aktif Dio isteğini iptal etmek için CancelToken
  CancelToken? _cancelToken;

  /// Son yüklenen merkez konum — cache kontrolü için
  LatLng? _lastLoadedCenter;
  /// Son yükleme anındaki filtre anahtar stringi
  String _lastLoadedFilterKey = '';

  NearbyNotifier(Ref _) : super(NearbyState());

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _cancelToken?.cancel('Notifier disposed');
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Yardımcılar
  // ─────────────────────────────────────────────

  /// Aktif filtreleri temsil eden benzersiz anahtar
  String _getFilterKey() {
    final f = state.nearbyFilter;
    return '${state.activeFilter}|${state.searchQuery.trim()}|'
        '${f.cuisine}|${f.mealType}|${f.budget}|${f.onlyOpen}|${f.radiusKm}';
  }

  /// 350 metre içindeyse ve filtreler aynıysa cache geçerlidir
  bool _isCacheHit(LatLng pos) {
    if (_lastLoadedCenter == null) return false;
    if (_lastLoadedFilterKey != _getFilterKey()) return false;
    final distance = Geolocator.distanceBetween(
      _lastLoadedCenter!.latitude,
      _lastLoadedCenter!.longitude,
      pos.latitude,
      pos.longitude,
    );
    return distance < 350;
  }

  void _invalidateCache() {
    _lastLoadedCenter = null;
    _lastLoadedFilterKey = '';
  }

  // ─────────────────────────────────────────────
  //  Public API
  // ─────────────────────────────────────────────

  void startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = LocationService.instance.positionStream.listen((pos) {
      setUserPosition(LatLng(pos.latitude, pos.longitude));
    });
  }

  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter, clearSelectedPlace: true);
    _invalidateCache();
    loadNearbyAtPosition(state.userPosition ?? const LatLng(39.9334, 32.8597));
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _invalidateCache();
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
    _invalidateCache();
    loadNearbyAtPosition(state.userPosition ?? const LatLng(39.9334, 32.8597));
  }

  // ─────────────────────────────────────────────
  //  Ana Yükleme — Sadece 1 sayfa (20 mekan)
  // ─────────────────────────────────────────────

  Future<void> loadNearbyAtPosition(LatLng pos, {bool forceReload = false}) async {
    // Cache kontrolü: aynı bölge + aynı filtreler ise atla
    if (!forceReload && _isCacheHit(pos)) return;

    // Devam eden isteği iptal et
    _cancelToken?.cancel('New request started');
    _cancelToken = CancelToken();

    state = state.copyWith(
      isLoading: true,
      error: null,
      clearNextPageToken: true,
      hasMorePages: false,
    );

    try {
      final queryParams = _buildQueryParams(pos);

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: queryParams,
        cancelToken: _cancelToken,
      );

      final status = response.data['status'] as String;

      if (status == 'OK' || status == 'ZERO_RESULTS') {
        List<NearbyPlace> places = [];

        if (status == 'OK') {
          final results = response.data['results'] as List;
          places = results.map((e) => NearbyPlace.fromJson(e)).toList();
        }

        // Client-side minRating filtresi
        final minRating = state.nearbyFilter.minRating;
        if (minRating != null) {
          places = places.where((p) => p.rating >= minRating).toList();
        }

        final nextToken = response.data['next_page_token'] as String?;

        // Cache güncelle
        _lastLoadedCenter = pos;
        _lastLoadedFilterKey = _getFilterKey();

        state = state.copyWith(
          places: places,
          isLoading: false,
          nextPageToken: nextToken,
          hasMorePages: nextToken != null,
        );
      } else {
        throw Exception('API Hatası: $status');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return; // iptal edildi, sessizce geç
      state = state.copyWith(isLoading: false, error: 'Mekanlar yüklenirken bir hata oluştu.');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Mekanlar yüklenirken bir hata oluştu.');
    }
  }

  // ─────────────────────────────────────────────
  //  Lazy Pagination — "Daha fazla yükle" butonu
  // ─────────────────────────────────────────────

  Future<void> loadMorePlaces() async {
    if (state.nextPageToken == null || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    final token = state.nextPageToken!;

    try {
      // Google, next_page_token aktif olmadan önce ~2sn bekletiyor
      await Future.delayed(const Duration(milliseconds: 2000));

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        queryParameters: {
          'key': AppStrings.googleMapsApiKey,
          'pagetoken': token,
        },
        cancelToken: _cancelToken,
      );

      if (response.data['status'] == 'OK') {
        final results = response.data['results'] as List;
        final newPlaces = results.map((e) => NearbyPlace.fromJson(e)).toList();

        // Tekrarlananları filtrele
        final combined = List<NearbyPlace>.from(state.places);
        for (final p in newPlaces) {
          if (!combined.any((e) => e.placeId == p.placeId)) {
            combined.add(p);
          }
        }

        final nextToken = response.data['next_page_token'] as String?;
        state = state.copyWith(
          places: combined,
          isLoadingMore: false,
          nextPageToken: nextToken,
          hasMorePages: nextToken != null,
        );
      } else {
        state = state.copyWith(isLoadingMore: false, hasMorePages: false, clearNextPageToken: true);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      state = state.copyWith(isLoadingMore: false);
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // ─────────────────────────────────────────────
  //  Query Params Builder
  // ─────────────────────────────────────────────

  Map<String, dynamic> _buildQueryParams(LatLng pos) {
    final filter = state.activeFilter;
    final searchQuery = state.searchQuery;
    final nearbyFilter = state.nearbyFilter;

    final params = <String, dynamic>{
      'location': '${pos.latitude},${pos.longitude}',
      'key': AppStrings.googleMapsApiKey,
      'type': 'restaurant',
    };

    // Keyword birleştir
    final keywords = <String>[];
    if (filter != 'Tümü' && filter.isNotEmpty) keywords.add(filter);
    if (searchQuery.trim().isNotEmpty) keywords.add(searchQuery.trim());
    if (nearbyFilter.cuisine != null) keywords.add(nearbyFilter.cuisine!);
    if (nearbyFilter.mealType != null) keywords.add(nearbyFilter.mealType!);

    if (keywords.isNotEmpty) params['keyword'] = keywords.join(' ');
    if (nearbyFilter.onlyOpen) params['opennow'] = true;

    switch (nearbyFilter.budget) {
      case 'Ucuz': params['maxprice'] = 1; break;
      case 'Orta': params['minprice'] = 2; break;
      case 'Pahalı': params['minprice'] = 3; break;
    }

    if (nearbyFilter.radiusKm <= 0.5) {
      params['rankby'] = 'distance';
    } else {
      params['radius'] = '${(nearbyFilter.radiusKm * 1000).toInt()}';
    }

    return params;
  }
}
