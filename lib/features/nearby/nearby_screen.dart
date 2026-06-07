import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'nearby_notifier.dart';
import 'nearby_state.dart';
import 'widgets/nearby_place_bottom_sheet.dart';
import '../../core/theme/colors.dart';
import '../../core/services/location_service.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/widgets/scale_button.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import 'package:custom_map_markers/custom_map_markers.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  final List<String> _categories = [
    "Tümü", "Kebap", "Döner", "Pide", "Pizza", "Burger", "Ev Yemeği", "Sushi", "Kahvaltı", "Tatlı", "Balık"
  ];

  double _currentZoom = 14.0;

  // Minimum zoom to prevent loading too many markers when very far out
  static const double _minZoom = 10.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final granted = await LocationService.instance.requestPermission();
    ref.read(nearbyNotifierProvider.notifier).setPermission(granted);

    if (granted) {
      ref.read(nearbyNotifierProvider.notifier).startPositionStream();

      final hour = DateTime.now().hour;
      String initialFilter = "Tümü";
      if (hour >= 6 && hour < 12) initialFilter = "Kahvaltı";
      else if (hour >= 12 && hour < 15) initialFilter = "Döner";
      else if (hour >= 15 && hour < 18) initialFilter = "Ev Yemeği";
      else if (hour >= 18 && hour < 21) initialFilter = "Kebap";
      else if (hour >= 21) initialFilter = "Tatlı";

      ref.read(nearbyNotifierProvider.notifier).setFilter(initialFilter);
      await _getUserLocation();
    }
  }

  // removed _animateToFitResults as it was unreferenced


  LatLngBounds _getBounds(List<NearbyPlace> places) {
    double minLat = places.first.latLng.latitude;
    double maxLat = places.first.latLng.latitude;
    double minLng = places.first.latLng.longitude;
    double maxLng = places.first.latLng.longitude;

    for (var p in places) {
      if (p.latLng.latitude < minLat) minLat = p.latLng.latitude;
      if (p.latLng.latitude > maxLat) maxLat = p.latLng.latitude;
      if (p.latLng.longitude < minLng) minLng = p.latLng.longitude;
      if (p.latLng.longitude > maxLng) maxLng = p.latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _getUserLocation() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      ref.read(nearbyNotifierProvider.notifier).setUserPosition(latLng);
      
      // Load nearby and then animate
      // Load nearby and then animate
      await ref.read(nearbyNotifierProvider.notifier).loadNearbyAtPosition(latLng);


      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 14.5),
      );
    }
  }

  void _listenToChanges() {
    ref.listen(nearbyNotifierProvider.select((s) => s.places), (prev, next) {
      if (mounted) setState(() {});
    });

    // Listen for place selection to animate sheet
    ref.listen(nearbyNotifierProvider.select((s) => s.selectedPlace), (prev, next) {
      if (next != null && prev?.placeId != next.placeId) {
        _sheetController.animateTo(
          0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else if (next == null && prev != null) {
        _sheetController.animateTo(
          0.22,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _smartSelect() {
    final state = ref.read(nearbyNotifierProvider);
    final filtered = state.filteredPlaces;
    if (filtered.isEmpty) {
      _showCompactSnackBar('Uygun mekan bulunamadı. Filtreleri genişletin.');
      return;
    }

    // Pick highest-rated open place
    final sorted = List<NearbyPlace>.from(filtered)
      ..sort((a, b) {
        final aScore = a.rating + (a.isOpen ? 0.5 : 0);
        final bScore = b.rating + (b.isOpen ? 0.5 : 0);
        return bScore.compareTo(aScore);
      });

    final top = sorted.take(5).toList();
    top.shuffle();
    final picked = top.first;

    ref.read(nearbyNotifierProvider.notifier).selectPlace(picked);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(picked.latLng, 16));

    _showCompactSnackBar('✨ ${picked.name} seçildi (⭐ ${picked.rating.toStringAsFixed(1)})');
  }

  void _showCompactSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 120), // Lifted a bit more for easier reach
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }


  // removed _showFilterSheet as it was unreferenced


  @override
  Widget build(BuildContext context) {
    _listenToChanges();
    final state = ref.watch(nearbyNotifierProvider);
    final theme = Theme.of(context);


    if (!state.isPermissionGranted) {
      return _buildPermissionDeniedView();
    }

    return Scaffold(
      body: CustomGoogleMapMarkerBuilder(
        customMarkers: _buildCustomMarkers(state),
        builder: (context, markers) {
          return Stack(
            children: [
              // ── Full-screen Map ──────────────────────────────────────
              Positioned.fill(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(39.9334, 32.8597),
                    zoom: 14,
                  ),
                  onMapCreated: (ctrl) => _mapController = ctrl,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  minMaxZoomPreference: MinMaxZoomPreference(_minZoom, 20),
                  markers: markers ?? {},
                  onTap: (_) {
                    // Deselect when clicking empty map area
                    ref.read(nearbyNotifierProvider.notifier).selectPlace(null);
                  },
                  onCameraMove: (pos) {
                    setState(() => _currentZoom = pos.zoom);
                  },
                  onCameraIdle: () {
                    // When user stops panning, load restaurants at new center
                    _mapController?.getVisibleRegion().then((bounds) {
                      final center = LatLng(
                        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
                      );
                      ref.read(nearbyNotifierProvider.notifier).loadNearbyAtPosition(center);
                    });
                  },
                ),
              ),

              // ── Top Controls ─────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Back button
                          ScaleButton(
                            onTap: () => Navigator.pop(context),
                            child: GlassContainer(
                              width: 48,
                              height: 48,
                              borderRadius: 24,
                              blur: 10,
                              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Glassmorphism Search Bar
                          Expanded(
                            child: GlassContainer(
                              height: 48,
                              borderRadius: 24,
                              blur: 15,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                              child: TextField(
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Mekan veya yemek ara...',
                                  hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) {
                                  ref.read(nearbyNotifierProvider.notifier).setSearchQuery(value);
                                },
                              ),
                            ),
                          ),
                          // Smart select button
                          ScaleButton(
                            onTap: _smartSelect,
                            child: GlassContainer(
                              width: 48,
                              height: 48,
                              borderRadius: 24,
                              blur: 10,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // NEW: FIXED FILTER BUTTON
                          ScaleButton(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                useRootNavigator: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const FilterBottomSheet(isMapMode: true),
                              );
                            },
                            child: GlassContainer(
                              width: 48,
                              height: 48,
                              borderRadius: 24,
                              blur: 10,
                              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Category filter chips
                    _buildCategoryFilters(state),
                  ],
                ),
              ),

              // ── Loading indicator ─────────────────────────────────────
              if (state.isLoading)
                const Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  ),
                ),

              // ── Zoom & Location Controls ──────────────────────────────
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.28,
                child: Column(
                  children: [
                    ScaleButton(
                      onTap: _getUserLocation,
                      child: GlassContainer(
                        width: 48,
                        height: 48,
                        borderRadius: 24,
                        blur: 10,
                        child: Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ScaleButton(
                      onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                      child: GlassContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 22,
                        blur: 10,
                        child: const Icon(Icons.add_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ScaleButton(
                      onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                      child: GlassContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 22,
                        blur: 10,
                        child: const Icon(Icons.remove_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),


              // ── Bottom sheet ─────────────────────────────────────────
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.22,
                minChildSize: 0.08,
                maxChildSize: 0.9,
                builder: (context, scrollController) {

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2))
                      ],
                    ),
                    child: state.selectedPlace == null
                        ? _buildPlaceList(state, scrollController)
                        : NearbyPlaceBottomSheet(
                            scrollController: scrollController,
                            place: state.selectedPlace!,
                            userPosition: state.userPosition,
                          ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilters(NearbyState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = state.activeFilter == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (category == 'Tümü') {
                  ref.read(nearbyNotifierProvider.notifier).setFilter('Tümü');
                } else if (isSelected) {
                  // Tapping the already-selected chip → deselect, go back to Tümü
                  ref.read(nearbyNotifierProvider.notifier).setFilter('Tümü');
                } else {
                  ref.read(nearbyNotifierProvider.notifier).setFilter(category);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
              elevation: isSelected ? 6 : 1,
              pressElevation: 2,
              shadowColor: isSelected ? AppColors.primary.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.black.withValues(alpha: 0.06),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          );
        },
      ),
    ).animate().fade(duration: 400.ms).slideX(begin: 0.1);
  }

  Widget _buildPlaceList(NearbyState state, ScrollController controller) {
    final places = state.filteredPlaces;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                places.isEmpty && !state.isLoading
                    ? 'Yakında yer bulunamadı'
                    : '${places.length} mekan bulundu',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              if (state.selectedPlace != null)
                TextButton(
                  onPressed: () => ref.read(nearbyNotifierProvider.notifier).selectPlace(null),
                  child: const Text('Geri'),
                ),
            ],
          ),
        ),
        // Place list
        ...places.map((place) => _PlaceTile(
              place: place,
              onTap: () {
                ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(place.latLng, 16));
              },
            )),
      ],
    );
  }

  List<MarkerData> _buildCustomMarkers(NearbyState state) {
    return state.filteredPlaces.map((place) {
      final bool isSelected = state.selectedPlace?.placeId == place.placeId;
      final bool showLabel = _currentZoom >= 15.0;
      final Color markerColor = isSelected ? AppColors.primary : (place.isOpen ? Colors.orange : Colors.grey);

      return MarkerData(
        marker: Marker(
          markerId: MarkerId(place.placeId),
          position: place.latLng,
          onTap: () {
            ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
            _mapController?.animateCamera(CameraUpdate.newLatLng(place.latLng));
          },
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLabel || isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    border: Border.all(color: markerColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Text(
                    place.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: markerColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              const SizedBox(height: 4),
              ScaleButton(
                onTap: () {
                  ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
                  _mapController?.animateCamera(CameraUpdate.newLatLng(place.latLng));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: markerColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(
                    _getCategoryIcon(place.name, state.activeFilter),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  IconData _getCategoryIcon(String name, String filter) {
    final lowerName = name.toLowerCase();
    final lowerFilter = filter.toLowerCase();

    if (lowerName.contains('kahve') || lowerFilter.contains('kahve')) return Icons.coffee_rounded;
    if (lowerName.contains('pizza') || lowerFilter.contains('pizza')) return Icons.local_pizza_rounded;
    if (lowerName.contains('burger') || lowerFilter.contains('burger')) return Icons.lunch_dining_rounded;
    if (lowerName.contains('kebap') || lowerFilter.contains('kebap')) return Icons.kebab_dining_rounded;
    if (lowerName.contains('balık') || lowerFilter.contains('balık')) return Icons.set_meal_rounded;
    if (lowerName.contains('tatlı') || lowerFilter.contains('tatlı')) return Icons.cake_rounded;
    if (lowerName.contains('pasta')) return Icons.bakery_dining_rounded;
    if (lowerName.contains('deniz')) return Icons.waves_rounded;
    if (lowerName.contains('et')) return Icons.restaurant_menu_rounded;
    
    return Icons.restaurant_rounded; // Default
  }

  Widget _buildPermissionDeniedView() {
    return Scaffold(
      appBar: AppBar(title: const Text("Konum İzni Gerekli")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded, size: 80, color: AppColors.textSecondary),
              const SizedBox(height: 24),
              const Text(
                "Konum İzni Reddedildi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Yakındaki restoranları gösterebilmemiz için konum erişimine ihtiyacımız var.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Geolocator.openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("Ayarlara Git"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small helper widgets ──────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _MapButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final NearbyPlace place;
  final VoidCallback onTap;

  const _PlaceTile({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: place.isOpen
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.restaurant,
          color: place.isOpen ? AppColors.primary : Colors.grey,
        ),
      ),
      title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(place.address, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 2),
              Text(
                place.rating > 0 ? place.rating.toStringAsFixed(1) : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: place.isOpen ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              place.isOpen ? 'Açık' : 'Kapalı',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────


