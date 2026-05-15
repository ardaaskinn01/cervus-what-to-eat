import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../nearby_state.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/food_model.dart';
import '../../suggestion/suggestion_notifier.dart';
import '../../favorites/favorites_notifier.dart';

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
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // 2. Fotoğraf Bölümü
        if (photoUrl != null)
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant, size: 48, color: AppColors.primary),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                place.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: place.isOpen ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                place.isOpen ? "Açık" : "Kapalı",
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(place.address, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        
        // Rating & Mesafe
        Row(
          children: [
            _buildRatingStars(place.rating),
            const SizedBox(width: 8),
            Text(
              place.rating.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (distanceKm > 0)
              Text(
                '${distanceKm.toStringAsFixed(1)} km uzaklıkta',
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Aksiyonlar
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(
                  "https://www.google.com/maps/dir/?api=1&destination=${place.latLng.latitude},${place.latLng.longitude}&destination_place_id=${place.placeId}"
                ),
                icon: const Icon(Icons.directions),
                label: const Text("Yol Tarifi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  final isFav = ref.watch(favoritesNotifierProvider).favoritePlaces.any((p) => p.placeId == place.placeId);
                  return ElevatedButton.icon(
                    onPressed: () {
                      ref.read(favoritesNotifierProvider.notifier).toggleFavoritePlace(place);
                    },
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    label: Text(isFav ? "Favorilerde" : "Favoriye Ekle"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFav ? Colors.redAccent : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _launchURL(
            "https://www.google.com/maps/search/?api=1&query=${place.latLng.latitude},${place.latLng.longitude}&query_place_id=${place.placeId}"
          ),
          icon: const Icon(Icons.launch, size: 16),
          label: const Text("Google Haritalar'da Görüntüle"),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
