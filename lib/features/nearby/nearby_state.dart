import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyPlace {
  final String placeId;
  final String name;
  final String address;
  final String? photoRef;
  final double rating;
  final bool isOpen;
  final LatLng latLng;

  NearbyPlace({
    required this.placeId,
    required this.name,
    required this.address,
    this.photoRef,
    required this.rating,
    required this.isOpen,
    required this.latLng,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('geometry') && json['geometry'] != null) {
      final location = json['geometry']['location'];
      return NearbyPlace(
        placeId: json['place_id'],
        name: json['name'],
        address: json['vicinity'] ?? '',
        photoRef: (json['photos'] as List?)?.first['photo_reference'],
        rating: (json['rating'] ?? 0.0).toDouble(),
        isOpen: json['opening_hours']?['open_now'] ?? false,
        latLng: LatLng(location['lat'], location['lng']),
      );
    } else {
      return NearbyPlace(
        placeId: json['placeId'],
        name: json['name'],
        address: json['address'],
        photoRef: json['photoRef'],
        rating: (json['rating'] ?? 0.0).toDouble(),
        isOpen: json['isOpen'] ?? true,
        latLng: LatLng(json['lat'], json['lng']),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'name': name,
      'address': address,
      'photoRef': photoRef,
      'rating': rating,
      'isOpen': isOpen,
      'lat': latLng.latitude,
      'lng': latLng.longitude,
    };
  }
}

class NearbyFilter {
  final double radiusKm;       // 0.1 - 5.0 km
  final bool onlyOpen;         // Sadece açık olanlar
  final double? minRating;     // null, 4.0, 4.5
  final String? priceLevel;    // null, 'Ucuz', 'Orta', 'Pahalı'

  const NearbyFilter({
    this.radiusKm = 2.0,
    this.onlyOpen = false,
    this.minRating,
    this.priceLevel,
  });

  NearbyFilter copyWith({
    double? radiusKm,
    bool? onlyOpen,
    double? minRating,
    bool clearMinRating = false,
    String? priceLevel,
    bool clearPriceLevel = false,
  }) {
    return NearbyFilter(
      radiusKm: radiusKm ?? this.radiusKm,
      onlyOpen: onlyOpen ?? this.onlyOpen,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      priceLevel: clearPriceLevel ? null : (priceLevel ?? this.priceLevel),
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (onlyOpen) count++;
    if (minRating != null) count++;
    if (priceLevel != null) count++;
    if (radiusKm != 2.0) count++; // non-default radius
    return count;
  }
}

class NearbyState {
  final bool isLoading;
  final List<NearbyPlace> places;
  final NearbyPlace? selectedPlace;
  final String activeFilter;
  final String searchQuery;
  final LatLng? userPosition;
  final bool isPermissionGranted;
  final String? error;
  final NearbyFilter nearbyFilter;

  NearbyState({
    this.isLoading = false,
    this.places = const [],
    this.selectedPlace,
    this.activeFilter = 'Tümü',
    this.searchQuery = '',
    this.userPosition,
    this.isPermissionGranted = true,
    this.error,
    this.nearbyFilter = const NearbyFilter(),
  });

  NearbyState copyWith({
    bool? isLoading,
    List<NearbyPlace>? places,
    NearbyPlace? selectedPlace,
    bool clearSelectedPlace = false,
    String? activeFilter,
    String? searchQuery,
    LatLng? userPosition,
    bool? isPermissionGranted,
    String? error,
    NearbyFilter? nearbyFilter,
  }) {
    return NearbyState(
      isLoading: isLoading ?? this.isLoading,
      places: places ?? this.places,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      userPosition: userPosition ?? this.userPosition,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      error: error ?? this.error,
      nearbyFilter: nearbyFilter ?? this.nearbyFilter,
    );
  }

  List<NearbyPlace> get filteredPlaces {
    return places.where((p) {
      if (nearbyFilter.onlyOpen && !p.isOpen) return false;
      if (nearbyFilter.minRating != null && p.rating < nearbyFilter.minRating!) return false;
      return true;
    }).toList();
  }
}
