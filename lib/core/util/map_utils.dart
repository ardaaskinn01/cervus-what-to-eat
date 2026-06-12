import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/nearby/nearby_state.dart';

class MapUtils {
  static Future<void> launchMap({
    required BuildContext context,
    required NearbyPlace place,
    bool isDirections = false,
  }) async {
    if (Platform.isIOS) {
      _showMapSelectionDialog(
        context: context,
        appleUrl: isDirections 
            ? "https://maps.apple.com/?daddr=${place.latLng.latitude},${place.latLng.longitude}"
            : "https://maps.apple.com/?q=${place.latLng.latitude},${place.latLng.longitude}",
        googleUrl: isDirections
            ? "https://www.google.com/maps/dir/?api=1&destination=${place.latLng.latitude},${place.latLng.longitude}&destination_place_id=${place.placeId}"
            : "https://www.google.com/maps/search/?api=1&query=${place.latLng.latitude},${place.latLng.longitude}&query_place_id=${place.placeId}",
        title: isDirections ? "Yol Tarifi Al" : "Haritada Görüntüle",
      );
    } else {
      final googleUrl = isDirections
          ? "https://www.google.com/maps/dir/?api=1&destination=${place.latLng.latitude},${place.latLng.longitude}&destination_place_id=${place.placeId}"
          : "https://www.google.com/maps/search/?api=1&query=${place.latLng.latitude},${place.latLng.longitude}&query_place_id=${place.placeId}";
      
      _launchURL(googleUrl);
    }
  }

  static Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static void _showMapSelectionDialog({
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
                color: Colors.grey.withOpacity(0.3),
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
