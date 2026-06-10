import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../../core/theme/colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // 1.5 seconds minimum for branding visibility
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final isDone = prefs.getBool('onboarding_done') ?? false;

    if (isDone) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).shimmer(delay: 1.seconds),
            const SizedBox(height: 32),
            const Text(
              'NeYesek',
              style: TextStyle(
                fontSize: 36, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                letterSpacing: -1.5,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              'Senin İçin Seçiyoruz',
              style: TextStyle(
                fontSize: 16, 
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
