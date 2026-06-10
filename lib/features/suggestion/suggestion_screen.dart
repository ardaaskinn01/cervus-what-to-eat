import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/filter_provider.dart';
import 'suggestion_notifier.dart';
import '../../shared/widgets/food_card.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../../core/theme/colors.dart';
import '../home/home_notifier.dart';
import '../../core/providers/shared_prefs_provider.dart';

class SuggestionScreen extends ConsumerStatefulWidget {
  const SuggestionScreen({super.key});

  @override
  ConsumerState<SuggestionScreen> createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends ConsumerState<SuggestionScreen> with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _showOnboarding = false;
  double _dragOffset = 0;
  static const double _swipeThreshold = 100;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
      if (ref.read(suggestionNotifierProvider).currentFood == null) {
        ref.read(suggestionNotifierProvider.notifier).suggestNext();
      }
    });
  }

  Future<void> _checkOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final hasSeen = prefs.getBool('has_seen_swipe_onboarding') ?? false;
    if (!hasSeen) {
      if (mounted) {
        setState(() => _showOnboarding = true);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() => _showOnboarding = false);
          prefs.setBool('has_seen_swipe_onboarding', true);
        }
      }
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > _swipeThreshold) {
      if (_dragOffset > 0) {
        _handleSwipeRight();
      } else {
        _handleSwipeLeft();
      }
    } else {
      _resetPosition();
    }
  }

  void _handleSwipeRight() {
    final screenWidth = MediaQuery.of(context).size.width;
    _animateSwipe(Offset(screenWidth * 1.5, 0), math.pi / 4).then((_) {
      ref.read(suggestionNotifierProvider.notifier).markAsFavorite();
      _showFeedbackSnackBar('Favorilere eklendi!', Colors.blueAccent);
      ref.read(suggestionNotifierProvider.notifier).suggestNext();
      _resetAfterAction();
    });
  }

  void _handleSwipeLeft() {
    final screenWidth = MediaQuery.of(context).size.width;
    _animateSwipe(Offset(-screenWidth * 1.5, 0), -math.pi / 4).then((_) {
      ref.read(suggestionNotifierProvider.notifier).suggestNext();
      _resetAfterAction();
    });
  }

  Future<void> _animateSwipe(Offset targetOffset, double targetRotation) {
    _swipeAnimation = Tween<Offset>(
      begin: Offset(_dragOffset, 0),
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeIn));

    _rotationAnimation = Tween<double>(
      begin: (_dragOffset / 500),
      end: targetRotation,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeIn));

    return _swipeController.forward();
  }

  void _resetPosition() {
    _swipeAnimation = Tween<Offset>(
      begin: Offset(_dragOffset, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.elasticOut));

    _rotationAnimation = Tween<double>(
      begin: (_dragOffset / 500),
      end: 0,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.elasticOut));

    _swipeController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = 0;
          _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_swipeController);
          _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_swipeController);
          _swipeController.reset();
        });
      }
    });
  }

  void _resetAfterAction() {
    if (!mounted) return;
    setState(() {
      _dragOffset = 0;
      _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_swipeController);
      _rotationAnimation = Tween<double>(begin: 0, end: 0).animate(_swipeController);
      _swipeController.reset();
    });
  }

  void _showFeedbackSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(bottom: 100, left: 24, right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suggestionNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    ref.listen(filterProvider, (_, __) {
      ref.read(suggestionNotifierProvider.notifier).suggestNext();
    });

    ref.listen(homeNotifierProvider, (prev, next) {
      if (prev?.selectedMealType != next.selectedMealType || 
          prev?.selectedMood != next.selectedMood) {
        ref.read(suggestionNotifierProvider.notifier).suggestNext();
      }
    });

    // Reset swipe state when food changes
    ref.listen(suggestionNotifierProvider.select((s) => s.currentFood?.id), (prev, next) {
      if (next != null && prev != next) {
        _resetAfterAction();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 1. SWIPE AREA
                SizedBox(
                  height: 500,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (state.isLoading && state.currentFood == null)
                        const CircularProgressIndicator()
                      else if (state.currentFood == null)
                        const Center(child: Text('Uygun yemek bulunamadı'))
                      else
                        GestureDetector(
                          onHorizontalDragUpdate: _onHorizontalDragUpdate,
                          onHorizontalDragEnd: _onHorizontalDragEnd,
                          child: AnimatedBuilder(
                            animation: _swipeController,
                            builder: (context, child) {
                              Offset offset = _dragOffset != 0 && !_swipeController.isAnimating 
                                  ? Offset(_dragOffset, 0) 
                                  : _swipeAnimation.value;
                              
                              double rotation = _dragOffset != 0 && !_swipeController.isAnimating
                                  ? (_dragOffset / 500)
                                  : _rotationAnimation.value;

                              return Transform.translate(
                                offset: offset,
                                child: Transform.rotate(
                                  angle: rotation,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey(state.currentFood?.id),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Stack(
                                children: [
                                  FoodCard(
                                    food: state.currentFood!,
                                    currentMood: homeState.selectedMood,
                                    isCompact: true,
                                    onLongPress: () {},
                                  ),
                                  
                                  // Swipe Indicators
                                  if (_dragOffset.abs() > 20)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: (_dragOffset.abs() / _swipeThreshold).clamp(0, 0.8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(32),
                                              color: _dragOffset > 0 
                                                  ? Colors.blueAccent.withOpacity(0.3)
                                                  : AppColors.primary.withOpacity(0.3),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _dragOffset > 0 ? Icons.favorite_rounded : Icons.casino_rounded,
                                                size: 100,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 2. ACTION BUTTONS (Manual fallback)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRoundButton(
                        icon: Icons.casino_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                        label: 'Pasla',
                        onTap: () => _handleSwipeLeft(),
                      ),
                      _buildRoundButton(
                        icon: Icons.favorite_rounded,
                        color: Colors.blueAccent,
                        isDark: isDark,
                        label: 'Süper!',
                        onTap: () => _handleSwipeRight(),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),

          // Onboarding Overlay
          if (_showOnboarding)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swipe_rounded, color: Colors.white, size: 80)
                          .animate(onPlay: (c) => c.repeat())
                          .moveX(begin: -40, end: 40, duration: 1.seconds, curve: Curves.easeInOut),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildOnboardingHint(Icons.arrow_back_rounded, 'Yenisini Öner', AppColors.primary),
                            _buildOnboardingHint(Icons.arrow_forward_rounded, 'Favorilere Ekle', Colors.blueAccent),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 500.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingHint(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
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

  Widget _buildRoundButton({
    required IconData icon, 
    required Color color, 
    required void Function() onTap, 
    required bool isDark,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(isDark ? 0.25 : 0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.bold, 
            color: color.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

