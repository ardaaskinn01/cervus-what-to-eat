import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/shared_prefs_provider.dart';
import '../../core/theme/colors.dart';
import '../../features/settings/settings_notifier.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  bool _isNameValid = false;

  final List<Color> _bgColors = [
    AppColors.primary.withOpacity(0.05),
    AppColors.secondary.withOpacity(0.05),
    Colors.purple.withOpacity(0.05),
    AppColors.primary.withOpacity(0.1),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  void _validateName() {
    final name = _nameController.text.trim();
    final isValid = name.length >= 2;
    if (isValid != _isNameValid) {
      setState(() => _isNameValid = isValid);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _finish() async {
    final name = _nameController.text.trim();
    // Default to 'Misafir' if empty (though UI should prevent it now)
    ref.read(settingsNotifierProvider.notifier).updateName(name.isEmpty ? 'Misafir' : name);
    
    ref.read(sharedPreferencesProvider).setBool('onboarding_done', true);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          gradient: LinearGradient(
            colors: [
              _bgColors[_currentPage],
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildPage(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Yemek kararını bize bırak',
                  desc: 'Kararsızlığa son! Akıllı algoritmamız senin için en uygun yemekleri bulur.',
                ),
                _buildPage(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Ruh haline göre öneri',
                  desc: 'Bugün enerjik mi yoksa rahatlamak mı istiyorsun? Moodunu seç, yemeği biz seçelim.',
                ),
                _buildPage(
                  icon: Icons.favorite_rounded,
                  title: 'Favori listelerini oluştur',
                  desc: '"Spordan sonra", "Hafta sonu kaçamağı" gibi kendi özel listelerini hazırla.',
                ),
                _buildNamePage(),
              ],
            ),
            
            // Fixed Bottom Navigation
            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isSelected = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage < 3)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                            ),
                            onPressed: () {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('İleri', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        )
                      else
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _isNameValid 
                                ? AppColors.primaryGradient 
                                : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500]),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: _isNameValid ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ] : [],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              onPressed: _isNameValid ? _finish : null,
                              child: const Text('Başla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: AppColors.primary),
          ).animate().scale(duration: 600.ms, curve: Curves.bounceOut).fadeIn(),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
          ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().slideY(begin: 0.2).fadeIn(delay: 400.ms),
          const SizedBox(height: 100), // Space for indicators
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_pin_rounded, size: 56, color: AppColors.primary),
          ).animate().scale(duration: 600.ms, curve: Curves.bounceOut).fadeIn(),
          const SizedBox(height: 48),
          const Text(
            'Tanışalım!',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const Text(
            'Seni nasıl çağıralım?',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: TextField(
              controller: _nameController,
              autofocus: false,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'İsminiz',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
          const SizedBox(height: 120), // Space for indicators
        ],
      ),
    );
  }
}
