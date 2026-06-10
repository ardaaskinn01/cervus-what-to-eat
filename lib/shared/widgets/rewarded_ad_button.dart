import 'package:flutter/material.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/colors.dart';

class RewardedAdButton extends StatelessWidget {
  const RewardedAdButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdService.instance.isPremium) return const SizedBox.shrink();

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: const Icon(Icons.ondemand_video),
      label: const Text('10 Özel Öneri', style: TextStyle(fontWeight: FontWeight.bold)),
      onPressed: () {
        AdService.instance.showRewardedAd(
          onEarnedReward: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('10 Özel Öneri Kilidi Açıldı!')));
            // In a real app we would dispatch an action here
          },
          onFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reklam yüklenemedi. Lütfen bekleyin.')));
          }
        );
      },
    );
  }
}
