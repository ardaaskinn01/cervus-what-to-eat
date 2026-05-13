import 'package:flutter/material.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // RevenueCat integration placeholder
  void _buyPremium() {
    AdService.instance.setPremium(true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium Aktif! Tüm reklamlar kaldırıldı.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
            const SizedBox(height: 24),
            const Text(
              'Reklamsız & Tam Özellik',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFeatureLine(Icons.block, 'Tüm banner ve tam ekran reklamları kaldırın.'),
            const SizedBox(height: 16),
            _buildFeatureLine(Icons.date_range, 'Haftalık yemek planı asistanı.'),
            const SizedBox(height: 16),
            _buildFeatureLine(Icons.star, 'Sınırsız özel koleksiyon limiti.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _buyPremium,
                child: const Text('Aylık ₺49.99', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Belki Daha Sonra', style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureLine(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 28),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}
