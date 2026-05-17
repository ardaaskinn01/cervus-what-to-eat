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
import 'package:custom_map_markers/custom_map_markers.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  GoogleMapController? _mapController;

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

  Future<void> _getUserLocation() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      ref.read(nearbyNotifierProvider.notifier).setUserPosition(latLng);
      await ref.read(nearbyNotifierProvider.notifier).loadNearby(
        latLng,
        ref.read(nearbyNotifierProvider).activeFilter,
        ref.read(nearbyNotifierProvider).searchQuery,
      );
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
    }
  }

  void _listenToChanges() {
    ref.listen(nearbyNotifierProvider.select((s) => s.places), (prev, next) {
      if (mounted) setState(() {});
    });
  }

  void _smartSelect() {
    final state = ref.read(nearbyNotifierProvider);
    final filtered = state.filteredPlaces;
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uygun mekan bulunamadı. Filtreleri genişletin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ ${picked.name} seçildi (⭐ ${picked.rating.toStringAsFixed(1)})'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFilterSheet() {
    final current = ref.read(nearbyNotifierProvider).nearbyFilter;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NearbyFilterSheet(
        initial: current,
        onApply: (newFilter) {
          ref.read(nearbyNotifierProvider.notifier).updateNearbyFilter(newFilter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _listenToChanges();
    final state = ref.watch(nearbyNotifierProvider);
    final theme = Theme.of(context);
    final filterCount = state.nearbyFilter.activeFilterCount;

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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          // Back button
                          _MapButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),

                          // Search bar (compact)
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                              ),
                              child: TextField(
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'Mekan veya yemek ara...',
                                  hintStyle: TextStyle(fontSize: 13),
                                  prefixIcon: Icon(Icons.search, size: 20),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) {
                                  ref.read(nearbyNotifierProvider.notifier).setSearchQuery(value);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Filter button with badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _MapButton(
                                icon: Icons.tune_rounded,
                                onTap: _showFilterSheet,
                                color: filterCount > 0 ? AppColors.primary : Colors.white,
                                iconColor: filterCount > 0 ? Colors.white : Colors.black,
                              ),
                              if (filterCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$filterCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),

                          // Smart select button
                          _MapButton(
                            icon: Icons.auto_awesome_rounded,
                            onTap: _smartSelect,
                            color: AppColors.primary,
                            iconColor: Colors.white,
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

              // ── Zoom Controls ──────────────────────────────────────────
              Positioned(
                right: 16,
                bottom: MediaQuery.of(context).size.height * 0.25,
                child: Column(
                  children: [
                    _MapButton(
                      icon: Icons.add,
                      onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                    const SizedBox(height: 8),
                    _MapButton(
                      icon: Icons.remove,
                      onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                  ],
                ),
              ),

              // ── Bottom sheet ─────────────────────────────────────────
              DraggableScrollableSheet(
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
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = state.activeFilter == category;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () {
                ref.read(nearbyNotifierProvider.notifier).setFilter(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ).animate(target: state.isLoading ? 1 : 0).shimmer();
        },
      ),
    );
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
      final rating = place.rating > 0 ? place.rating.toStringAsFixed(1) : '?';
      final bool showLabel = _currentZoom >= 15.5;

      return MarkerData(
        marker: Marker(
          markerId: MarkerId(place.placeId),
          position: place.latLng,
          onTap: () {
            ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
            _mapController?.animateCamera(CameraUpdate.newLatLng(place.latLng));
          },
        ),
        child: showLabel
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: place.isOpen ? AppColors.primary : Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: place.isOpen ? Colors.orange : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Icon(Icons.restaurant, color: Colors.white, size: 18),
              ),
      );
    }).toList();
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

class _NearbyFilterSheet extends StatefulWidget {
  final NearbyFilter initial;
  final void Function(NearbyFilter) onApply;

  const _NearbyFilterSheet({required this.initial, required this.onApply});

  @override
  State<_NearbyFilterSheet> createState() => _NearbyFilterSheetState();
}

class _NearbyFilterSheetState extends State<_NearbyFilterSheet> {
  late double _radius;
  late bool _onlyOpen;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _radius = widget.initial.radiusKm;
    _onlyOpen = widget.initial.onlyOpen;
    _minRating = widget.initial.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Filtreler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Open now toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _onlyOpen ? Colors.green.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.storefront_rounded, color: _onlyOpen ? Colors.green : Colors.grey),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sadece açık olanlar', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _onlyOpen ? 'Aktif' : 'Pasif',
                    style: TextStyle(
                      fontSize: 12,
                      color: _onlyOpen ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Switch(
                value: _onlyOpen,
                onChanged: (v) => setState(() => _onlyOpen = v),
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating filter
          const Text('Minimum Puan', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _RatingChip(label: 'Tümü', selected: _minRating == null, onTap: () => setState(() => _minRating = null)),
              const SizedBox(width: 8),
              _RatingChip(label: '⭐ 4.0+', selected: _minRating == 4.0, onTap: () => setState(() => _minRating = 4.0)),
              const SizedBox(width: 8),
              _RatingChip(label: '⭐ 4.5+', selected: _minRating == 4.5, onTap: () => setState(() => _minRating = 4.5)),
            ],
          ),
          const SizedBox(height: 20),

          // Radius slider
          Row(
            children: [
              const Text('Mesafe', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_radius.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _radius,
            min: 0.1,
            max: 5.0,
            divisions: 49,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _radius = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0.1 km', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text('5.0 km', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                widget.onApply(NearbyFilter(
                  radiusKm: _radius,
                  onlyOpen: _onlyOpen,
                  minRating: _minRating,
                ));
                Navigator.pop(context);
              },
              child: const Text('Uygula', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RatingChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
