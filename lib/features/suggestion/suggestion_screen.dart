import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'suggestion_notifier.dart';
import '../../shared/widgets/food_card.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../../core/theme/colors.dart';
import '../home/home_notifier.dart';
import '../favorites/favorites_notifier.dart';

class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(suggestionNotifierProvider).currentFood == null) {
        ref.read(suggestionNotifierProvider.notifier).suggestNext();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suggestionNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Günün Önerisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const FilterBottomSheet(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -50,
            child: _buildGlow(250, AppColors.primary.withOpacity(0.12)),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child: _buildGlow(300, AppColors.secondary.withOpacity(0.08)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // 1. CARD AREA
                  state.isLoading && state.currentFood == null
                      ? const SizedBox(
                          height: 400,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : state.currentFood == null
                          ? const SizedBox(
                              height: 400,
                              child: Center(child: Text('Uygun yemek bulunamadı 😕')),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.05),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: Padding(
                                key: ValueKey(state.currentFood?.id),
                                padding: const EdgeInsets.only(bottom: 40),
                                child: FoodCard(
                                  food: state.currentFood!,
                                  currentMood: homeState.selectedMood,
                                  onLongPress: () {},
                                ),
                              ),
                            ),

                  // 2. ACTION BUTTONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRoundButton(
                          icon: Icons.close_rounded,
                          color: Colors.redAccent,
                          onTap: () => ref.read(suggestionNotifierProvider.notifier).suggestNext(),
                        ),
                        
                        _buildPrimaryAction(
                          onTap: _handleYedim,
                        ),

                        _buildRoundButton(
                          icon: Icons.favorite_rounded,
                          color: Colors.blueAccent,
                          onTap: () {
                            ref.read(suggestionNotifierProvider.notifier).markAsFavorite();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Favorilere eklendi! ✨')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom nav / ad
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              emissionFrequency: 0.1,
              numberOfParticles: 20,
              colors: const [Colors.orange, Colors.red, Colors.blue, Colors.green],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          )
        ],
      ),
    );
  }

  Widget _buildPrimaryAction({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        width: 140,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yedim',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  void _handleYedim() async {
    _confettiController.play();
    final newBadges = await ref.read(suggestionNotifierProvider.notifier).markAsEaten();
    
    if (!mounted) return;

    if (newBadges.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tebrikler! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Harika bir seçim yaptın. Yeni rozet kazandın:'),
              const SizedBox(height: 16),
              Text(newBadges.join(', '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Harika!')),
          ],
        ),
      );
    }

    if (!mounted) return;
    ref.read(suggestionNotifierProvider.notifier).suggestNext();
  }

  Widget _buildRoundButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
