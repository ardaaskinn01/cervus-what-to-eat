import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../nearby_state.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../favorites/favorites_notifier.dart';
import '../../../shared/widgets/scale_button.dart';
import '../../../shared/widgets/glass_container.dart';

class NearbyPlaceBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;
  final NearbyPlace place;
  final LatLng? userPosition;

  const NearbyPlaceBottomSheet({
    super.key,
    required this.scrollController,
    required this.place,
    this.userPosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double distanceKm = 0;
    if (userPosition != null) {
      final meters = Geolocator.distanceBetween(
        userPosition!.latitude,
        userPosition!.longitude,
        place.latLng.latitude,
        place.latLng.longitude,
      );
      distanceKm = meters / 1000;
    }

    final photoUrl = place.photoRef != null
        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${place.photoRef}&key=${AppStrings.googleMapsApiKey}'
        : null;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Photo Section with Premium Styling
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: photoUrl != null
              ? Image.network(
                  photoUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
                )
              : _buildPlaceholderPhoto(),
        ),

        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.address,
                          style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusChip(place.isOpen),
          ],
        ),

        const SizedBox(height: 20),
        
        // Info Row: Rating, Price, Distance
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.03),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(Icons.star_rounded, place.rating.toString(), 'Puan', Colors.amber),
              _buildVerticalDivider(),
              _buildInfoItem(
                Icons.payments_rounded, 
                _getPriceString(place.priceLevel), 
                'Bütçe', 
                Colors.green
              ),
              _buildVerticalDivider(),
              _buildInfoItem(
                Icons.near_me_rounded, 
                distanceKm > 0 ? '${distanceKm.toStringAsFixed(1)} km' : '?', 
                'Mesafe', 
                Colors.blue
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Primary Actions
        Row(
          children: [
            Expanded(
              child: ScaleButton(
                onTap: () => _handleDirections(context),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.directions_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Yol Tarifi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ScaleButton(
                onTap: () {
                  ref.read(favoritesNotifierProvider.notifier).toggleFavoritePlace(place);
                },
                child: Consumer(
                  builder: (context, ref, _) {
                    final isFav = ref.watch(favoritesNotifierProvider).favoritePlaces.any((p) => p.placeId == place.placeId);
                    return Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isFav ? Colors.redAccent.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isFav ? Colors.redAccent.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded, 
                            color: isFav ? Colors.redAccent : AppColors.primary
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFav ? "Favoride" : "Favoriye Ekle",
                            style: TextStyle(
                              color: isFav ? Colors.redAccent : AppColors.primary, 
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        ScaleButton(
          onTap: () => _handleOpenInMaps(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  Platform.isIOS ? "Haritalar'da Görüntüle" : "Google Haritalar'da Görüntüle", 
                  style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.restaurant_rounded, size: 64, color: AppColors.primary),
    );
  }

  Widget _buildStatusChip(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isOpen ? Colors.green : Colors.red),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? "Şu An Açık" : "Kapalı",
            style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.1),
    );
  }

  String _getPriceString(int? level) {
    if (level == null) return '₺₺';
    return List.generate(level, (_) => '₺').join();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleDirections(BuildContext context) {
    if (Platform.isIOS) {
      _showMapSelectionDialog(
        context: context,
        appleUrl: "themes://maps.apple.com/?daddr=${place.latLng.latitude},${place.latLng.longitude}",
        googleUrl: "https://www.google.com/maps/dir/?api=1&destination=${place.latLng.latitude},${place.latLng.longitude}&destination_place_id=${place.placeId}",
        title: "Yol Tarifi Al",
      );
    } else {
      _launchURL("https://www.google.com/maps/dir/?api=1&destination=${place.latLng.latitude},${place.latLng.longitude}&destination_place_id=${place.placeId}");
    }
  }

  void _handleOpenInMaps(BuildContext context) {
    if (Platform.isIOS) {
      _showMapSelectionDialog(
        context: context,
        appleUrl: "maps://maps.apple.com/?q=${place.latLng.latitude},${place.latLng.longitude}",
        googleUrl: "https://www.google.com/maps/search/?api=1&query=${place.latLng.latitude},${place.latLng.longitude}&query_place_id=${place.placeId}",
        title: "Haritada Görüntüle",
      );
    } else {
      _launchURL("https://www.google.com/maps/search/?api=1&query=${place.latLng.latitude},${place.latLng.longitude}&query_place_id=${place.placeId}");
    }
  }

  void _showMapSelectionDialog({
    required BuildContext context,
    required String appleUrl,
    required String googleUrl,
    required String title,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.apple, size: 28),
              title: const Text("Apple Haritalar", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _launchURL(appleUrl);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.map_rounded, size: 28, color: Colors.blue),
              title: const Text("Google Haritalar", style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _launchURL(googleUrl);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
