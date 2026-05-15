import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/filter_provider.dart';
import 'suggestion_notifier.dart';
import '../../shared/widgets/food_card.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../../core/theme/colors.dart';
import '../home/home_notifier.dart';

class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(suggestionNotifierProvider).currentFood == null) {
        ref.read(suggestionNotifierProvider.notifier).suggestNext();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suggestionNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Listen for filter changes and refresh
    ref.listen(filterProvider, (_, __) {
      ref.read(suggestionNotifierProvider.notifier).suggestNext();
    });

    ref.listen(homeNotifierProvider, (prev, next) {
      if (prev?.selectedMealType != next.selectedMealType || 
          prev?.selectedMood != next.selectedMood) {
        ref.read(suggestionNotifierProvider.notifier).suggestNext();
      }
    });

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
            child: _buildGlow(250, AppColors.primary.withOpacity(isDark ? 0.2 : 0.12)),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child: _buildGlow(300, AppColors.secondary.withOpacity(isDark ? 0.15 : 0.08)),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRoundButton(
                          icon: Icons.close_rounded,
                          color: Colors.redAccent,
                          isDark: isDark,
                          onTap: () => ref.read(suggestionNotifierProvider.notifier).suggestNext(),
                        ),

                        _buildRoundButton(
                          icon: Icons.favorite_rounded,
                          color: Colors.blueAccent,
                          isDark: isDark,
                          onTap: () {
                            ref.read(suggestionNotifierProvider.notifier).markAsFavorite();
                            if (!context.mounted) return;
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

  Widget _buildRoundButton({required IconData icon, required Color color, required void Function() onTap, required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(isDark ? 0.25 : 0.2), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
