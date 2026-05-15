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
import '../settings/settings_notifier.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  GoogleMapController? _mapController;
  final List<String> _categories = [
    "Tümü", "Türk", "Pizza", "Burger", "Sushi", "Kebap", "Kahvaltı", "Tatlı", "Kahve"
  ];

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
      if (hour >= 6 && hour < 11) initialFilter = "Kahvaltı";
      else if (hour >= 11 && hour < 16) initialFilter = "Burger";
      else if (hour >= 16 && hour < 22) initialFilter = "Kebap";
      
      ref.read(nearbyNotifierProvider.notifier).setFilter(initialFilter);
      await _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      ref.read(nearbyNotifierProvider.notifier).setUserPosition(latLng);
      ref.read(nearbyNotifierProvider.notifier).loadNearby(latLng, ref.read(nearbyNotifierProvider).activeFilter, ref.read(nearbyNotifierProvider).searchQuery);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
    }
  }

  void _smartSelect() {
    final profile = ref.read(settingsNotifierProvider);
    String smartCategory = "Tümü";
    
    if (profile.dietType == 'Vejetaryen') smartCategory = "Salata";
    else if (profile.dietType == 'Vegan') smartCategory = "Vegan";
    else if (profile.allergies.contains('Gluten')) smartCategory = "Glutensiz";
    else {
      smartCategory = (_categories.toList()..shuffle()).first;
    }

    ref.read(nearbyNotifierProvider.notifier).setFilter(smartCategory);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profiline göre seçtik: $smartCategory ✨'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyNotifierProvider);
    final theme = Theme.of(context);

    if (!state.isPermissionGranted) {
      return _buildPermissionDeniedView();
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.25,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(39.9334, 32.8597),
                zoom: 12,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _buildMarkers(state),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10)
                            ],
                          ),
                          child: const Text(
                            "Dışarıdayım",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                          onPressed: _smartSelect,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(30),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ne arıyorsunuz? (örn. Döner, Kadıköy)',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onSubmitted: (value) {
                        ref.read(nearbyNotifierProvider.notifier).setSearchQuery(value);
                        if (state.userPosition != null) {
                          _mapController?.animateCamera(CameraUpdate.newLatLng(state.userPosition!));
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildCategoryFilters(state),
              ],
            ),
          ),

          if (state.isLoading)
            const Center(child: CircularProgressIndicator()),

          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                  ],
                ),
                child: state.selectedPlace == null 
                  ? _buildEmptySheet(state, scrollController)
                  : NearbyPlaceBottomSheet(
                      scrollController: scrollController,
                      place: state.selectedPlace!,
                      userPosition: state.userPosition,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(NearbyState state) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = state.activeFilter == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref.read(nearbyNotifierProvider.notifier).setFilter(category);
                if (state.userPosition != null) {
                  _mapController?.animateCamera(CameraUpdate.newLatLng(state.userPosition!));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isSelected) BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)
                  ],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ).animate(target: state.isLoading ? 1 : 0).shimmer();
        },
      ),
    );
  }

  Widget _buildEmptySheet(NearbyState state, ScrollController controller) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            const Icon(Icons.restaurant_menu, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              "Bir restoran seçin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (state.places.isEmpty && !state.isLoading)
              const Text(
                "Bu kategoride yakında yer bulunamadı. 😕",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              Text(
                "${state.places.length} yer bulundu",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
          ],
        ),
      ],
    );
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

  Set<Marker> _buildMarkers(NearbyState state) {
    return state.places.map((place) {
      return Marker(
        markerId: MarkerId(place.placeId),
        position: place.latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
          _mapController?.animateCamera(CameraUpdate.newLatLng(place.latLng));
        },
      );
    }).toSet();
  }
}
