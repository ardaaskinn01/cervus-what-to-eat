import 'dart:async';
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
import '../../core/constants/map_styles.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/widgets/scale_button.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  GoogleMapController? _mapController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _hasInitialized = false;

  // "Burayı Tara" butonu için yerel durum
  bool _showScanButton = false;
  LatLng? _pendingScanCenter;

  final List<String> _categories = [
    "Tümü", "Kebap", "Döner", "Pide", "Pizza", "Burger",
    "Ev Yemeği", "Sushi", "Kahvaltı", "Tatlı", "Balık",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Başlatma
  // ─────────────────────────────────────────────

  Future<void> _initialize() async {
    final granted = await LocationService.instance.requestPermission();
    ref.read(nearbyNotifierProvider.notifier).setPermission(granted);
    if (!granted) return;

    ref.read(nearbyNotifierProvider.notifier).startPositionStream();

    // setFilter çağırmak cache'i temizler ve yüklemeyi başlatır
    ref.read(nearbyNotifierProvider.notifier).setFilter("Tümü");
    await _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final position = await LocationService.instance.getCurrentPosition();
    if (position == null || !mounted) return;

    final latLng = LatLng(position.latitude, position.longitude);
    ref.read(nearbyNotifierProvider.notifier).setUserPosition(latLng);
    await ref.read(nearbyNotifierProvider.notifier).loadNearbyAtPosition(latLng);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14.5));

    // Harita ilk yüklendikten sonra kullanıcı hareketiyle scan butonu gösterilebilir
    if (mounted) setState(() => _hasInitialized = true);
  }


  // ─────────────────────────────────────────────
  //  Akıllı Seçim (AI Pick)
  // ─────────────────────────────────────────────

  void _smartSelect() {
    final st = ref.read(nearbyNotifierProvider);
    final filtered = st.filteredPlaces;
    if (filtered.isEmpty) {
      _showSnackBar('Uygun mekan bulunamadı. Filtreleri genişletin.');
      return;
    }

    final sorted = List<NearbyPlace>.from(filtered)
      ..sort((a, b) {
        final aScore = a.rating + (a.isOpen ? 0.5 : 0.0);
        final bScore = b.rating + (b.isOpen ? 0.5 : 0.0);
        return bScore.compareTo(aScore);
      });

    final top = sorted.take(5).toList()..shuffle();
    final picked = top.first;

    ref.read(nearbyNotifierProvider.notifier).selectPlace(picked);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(picked.latLng, 16));
    _showSnackBar('${picked.name} seçildi (${picked.rating.toStringAsFixed(1)} ⭐)');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Markers — BitmapDescriptor (Hızlı & Hafif)
  // ─────────────────────────────────────────────

  Set<Marker> _buildMarkers(NearbyState state) {
    return state.filteredPlaces.map((place) {
      final isSelected = state.selectedPlace?.placeId == place.placeId;

      BitmapDescriptor icon;
      if (isSelected) {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      } else if (place.isOpen) {
        icon = BitmapDescriptor.defaultMarkerWithHue(30); // turuncu-sarı (iştah açıcı)
      } else {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      }

      return Marker(
        markerId: MarkerId(place.placeId),
        position: place.latLng,
        icon: icon,
        anchor: const Offset(0.5, 1.0),
        zIndexInt: isSelected ? 2 : 1,
        onTap: () {
          ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
          _mapController?.animateCamera(CameraUpdate.newLatLng(place.latLng));
          _sheetController.animateTo(
            0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      );
    }).toSet();
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyNotifierProvider);
    final theme = Theme.of(context);

    // Yer seçiminde sheet yüksekliğini otomatik yönet
    ref.listen(nearbyNotifierProvider.select((s) => s.selectedPlace), (prev, next) {
      if (next != null && prev?.placeId != next.placeId) {
        _sheetController.animateTo(0.5, duration: 300.ms, curve: Curves.easeOut);
      } else if (next == null && prev != null) {
        _sheetController.animateTo(0.22, duration: 300.ms, curve: Curves.easeOut);
      }
    });

    if (!state.isPermissionGranted) return _buildPermissionDeniedView();

    final isDark = theme.brightness == Brightness.dark;
    final markers = _buildMarkers(state);

    return Scaffold(
      body: Stack(
        children: [
          // ── Harita ──
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(39.9334, 32.8597),
                zoom: 14,
              ),
              onMapCreated: (ctrl) => _mapController = ctrl,
              style: isDark ? MapStyles.dark : null,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(10, 20),
              markers: markers,
              onTap: (_) => ref.read(nearbyNotifierProvider.notifier).selectPlace(null),
              onCameraIdle: () async {
                // İlk yükleme tamamlanmadan scan butonu gösterme
                if (!_hasInitialized) return;
                final bounds = await _mapController?.getVisibleRegion();
                if (bounds != null && mounted) {
                  final center = LatLng(
                    (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
                    (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
                  );
                  setState(() {
                    _pendingScanCenter = center;
                    _showScanButton = true;
                  });
                }
              },
            ),
          ),

          // ── Arama + Kategori Çubukları (üst) ──
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                _buildCategoryFilters(state),
              ],
            ),
          ),

          // ── Yükleniyor göstergesi ──
          if (state.isLoading)
            Positioned(
              top: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Mekanlar aranıyor...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ).animate().fade(),
            ),

          // ── "Burayı Tara" butonu ──
          if (_showScanButton && !state.isLoading)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.31,
              left: 0,
              right: 0,
              child: Center(
                child: ScaleButton(
                  onTap: () {
                    setState(() => _showScanButton = false);
                    if (_pendingScanCenter != null) {
                      ref.read(nearbyNotifierProvider.notifier)
                          .loadNearbyAtPosition(_pendingScanCenter!, forceReload: true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Bu Alanı Tara',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade(duration: 200.ms).slideY(begin: 0.3),
            ),

          // ── Sağ yüzen butonlar ──
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.28,
            child: Column(
              children: [
                ScaleButton(
                  onTap: _getUserLocation,
                  child: GlassContainer(
                    width: 48, height: 48, borderRadius: 24, blur: 10,
                    child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 22),
                  ),
                ),
                const SizedBox(height: 12),
                ScaleButton(
                  onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                  child: GlassContainer(
                    width: 44, height: 44, borderRadius: 22, blur: 10,
                    child: const Icon(Icons.add_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 8),
                ScaleButton(
                  onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                  child: GlassContainer(
                    width: 44, height: 44, borderRadius: 22, blur: 10,
                    child: const Icon(Icons.remove_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // ── Alt Çekmece (Bottom Sheet) ──
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.22,
            minChildSize: 0.08,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
                  ],
                ),
                child: state.selectedPlace == null
                    ? _buildPlaceList(state, scrollController, theme)
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

  // ─────────────────────────────────────────────
  //  Widget Parçaları
  // ─────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Geri
          ScaleButton(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              width: 46, height: 46, borderRadius: 23, blur: 10,
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
          const SizedBox(width: 10),

          // Arama kutusu
          Expanded(
            child: GlassContainer(
              height: 46,
              borderRadius: 23,
              blur: 15,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Mekan veya yemek ara...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(nearbyNotifierProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {}); // Suffix icon için
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                    ref.read(nearbyNotifierProvider.notifier).setSearchQuery(value);
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 10),

          // AI Pick
          ScaleButton(
            onTap: _smartSelect,
            child: GlassContainer(
              width: 46, height: 46, borderRadius: 23, blur: 10,
              color: AppColors.primary.withValues(alpha: 0.85),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),

          // Filtreler
          ScaleButton(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const FilterBottomSheet(isMapMode: true),
            ),
            child: GlassContainer(
              width: 46, height: 46, borderRadius: 23, blur: 10,
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(NearbyState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
              onSelected: (_) {
                if (category == 'Tümü' || isSelected) {
                  ref.read(nearbyNotifierProvider.notifier).setFilter('Tümü');
                } else {
                  ref.read(nearbyNotifierProvider.notifier).setFilter(category);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.09) : Colors.white,
              elevation: isSelected ? 5 : 1,
              pressElevation: 2,
              shadowColor: isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.black.withValues(alpha: 0.06),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    ).animate().fade(duration: 400.ms);
  }

  Widget _buildPlaceList(NearbyState state, ScrollController controller, ThemeData theme) {
    final places = state.filteredPlaces;

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Başlık
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Text(
                state.isLoading
                    ? 'Mekanlar aranıyor...'
                    : places.isEmpty
                        ? 'Yakında mekan bulunamadı'
                        : '${places.length} mekan bulundu',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
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

        // Skeleton veya Liste
        if (state.isLoading)
          ..._buildSkeletonList(theme)
        else if (places.isEmpty)
          _buildEmptyState()
        else
          ...places.map((place) => _PremiumPlaceTile(
                place: place,
                userPosition: state.userPosition,
                onTap: () {
                  ref.read(nearbyNotifierProvider.notifier).selectPlace(place);
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(place.latLng, 16),
                  );
                },
              )),

        // "Daha Fazla Yükle" butonu
        if (state.hasMorePages && !state.isLoading && places.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: state.isLoadingMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () => ref.read(nearbyNotifierProvider.notifier).loadMorePlaces(),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('20 Mekan Daha Yükle'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
          ),

        // Error
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(nearbyNotifierProvider.notifier).loadNearbyAtPosition(
                    state.userPosition ?? const LatLng(39.9334, 32.8597),
                    forceReload: true,
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildSkeletonList(ThemeData theme) {
    return List.generate(5, (i) => _SkeletonTile(theme: theme, delay: i * 60));
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.storefront_rounded, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'Bu bölgede mekan bulunamadı',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Haritayı kaydırıp "Bu Alanı Tara" butonunu deneyin\nveya filtreleri genişletin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
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
              const Text("Konum İzni Reddedildi",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

// ─────────────────────────────────────────────
//  Premium Mekan Kartı
// ─────────────────────────────────────────────

class _PremiumPlaceTile extends StatelessWidget {
  final NearbyPlace place;
  final LatLng? userPosition;
  final VoidCallback onTap;

  const _PremiumPlaceTile({
    required this.place,
    required this.userPosition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double? distanceKm;
    if (userPosition != null) {
      final meters = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        place.latLng.latitude,
        place.latLng.longitude,
      );
      distanceKm = meters / 1000;
    }

    final isOpen = place.isOpen;
    final accentColor = isOpen ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: isDark
              ? Border.all(color: Colors.white.withValues(alpha: 0.07))
              : null,
        ),
        child: Row(
          children: [
            // İkon kutusu
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.restaurant_rounded, color: accentColor, size: 26),
            ),
            const SizedBox(width: 14),

            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Mesafe
                      if (distanceKm != null) ...[
                        Icon(Icons.near_me_rounded, size: 12, color: Colors.blue.withValues(alpha: 0.8)),
                        const SizedBox(width: 3),
                        Text(
                          distanceKm < 1
                              ? '${(distanceKm * 1000).toInt()} m'
                              : '${distanceKm.toStringAsFixed(1)} km',
                          style: TextStyle(fontSize: 11, color: Colors.blue.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Fiyat seviyesi
                      if (place.priceLevel != null) ...[
                        Text(
                          List.generate(place.priceLevel!, (_) => '₺').join(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Sağ bölüm: puan + durum
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Puan
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                    const SizedBox(width: 2),
                    Text(
                      place.rating > 0 ? place.rating.toStringAsFixed(1) : '—',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Açık/Kapalı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOpen ? 'Açık' : 'Kapalı',
                    style: TextStyle(
                      color: isOpen ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Skeleton Yüklenme Kartı
// ─────────────────────────────────────────────

class _SkeletonTile extends StatefulWidget {
  final ThemeData theme;
  final int delay;

  const _SkeletonTile({required this.theme, required this.delay});

  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(width: 52, height: 52, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(14))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(7))),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 140, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 8),
                    Container(height: 8, width: 80, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Container(height: 18, width: 36, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(9))),
                  const SizedBox(height: 6),
                  Container(height: 22, width: 44, decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: widget.delay)).fade(duration: 200.ms);
  }
}
