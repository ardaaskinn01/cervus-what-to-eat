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
    ref.read(settingsNotifierProvider.notifier).updateName(name.isEmpty ? 'Misafir' : name);
    ref.read(sharedPreferencesProvider).setBool('onboarding_done', true);
    context.go('/home');
  }

  // Onboarding page data
  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.restaurant_menu_rounded,
      gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      title: 'Yemek kararını\nbize bırak',
      desc: 'Kararsızlığa son. Akıllı algoritmamız bugün ne yiyeceğini senin için belirliyor.',
    ),
    _OnboardingPage(
      icon: Icons.psychology_rounded,
      gradient: [Color(0xFF6C63FF), Color(0xFF3ECBFF)],
      title: 'Ruh haline\ngöre öneri',
      desc: 'Enerjik, rahat ya da nostaljik. Moodunu seç, biz en uygun lezzeti seçelim.',
    ),
    _OnboardingPage(
      icon: Icons.collections_bookmark_rounded,
      gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)],
      title: 'Favori\nlistelerin',
      desc: '"Spor sonrası", "Hafta sonu kaçamağı" gibi kişisel koleksiyonlar oluştur.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Decorative background
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.25,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(isDark ? 0.18 : 0.1),
                    AppColors.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.2,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(isDark ? 0.15 : 0.08),
                    AppColors.secondary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Pages
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length + 1, // +1 for name page
            itemBuilder: (context, index) {
              if (index < _pages.length) {
                return _buildPage(_pages[index], isDark);
              } else {
                return _buildNamePage(isDark);
              }
            },
          ),

          // Fixed Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                28, 24, 28,
                MediaQuery.of(context).padding.bottom + 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.scaffoldBackgroundColor.withOpacity(0),
                    theme.scaffoldBackgroundColor.withOpacity(0.95),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length + 1, (index) {
                      final isSelected = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 8),
                        height: 4,
                        width: isSelected ? 28 : 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Action button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentPage < _pages.length
                        ? _buildNextButton()
                        : _buildStartButton(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container with gradient
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: data.gradient.first.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(data.icon, size: 40, color: Colors.white),
          )
              .animate()
              .scale(duration: 500.ms, curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 40),
          // Step label
          Text(
            'ADIM ${_pages.indexOf(data) + 1} / ${_pages.length}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary.withOpacity(0.7),
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ).animate().slideY(begin: 0.15).fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          Text(
            data.desc,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.85),
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ).animate().slideY(begin: 0.15).fadeIn(delay: 350.ms),
          const SizedBox(height: 180), // space for bottom bar
        ],
      ),
    );
  }

  Widget _buildNamePage(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
          const SizedBox(height: 40),
          Text(
            'NEREDEYSE TAMAM',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary.withOpacity(0.7),
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          const Text(
            'Seni nasıl\nçağıralım?',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ).animate().slideY(begin: 0.15).fadeIn(delay: 200.ms),
          const SizedBox(height: 20),
          Text(
            'Kişiselleştirilmiş deneyim için adını paylaş.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.85),
              height: 1.65,
            ),
          ).animate().slideY(begin: 0.15).fadeIn(delay: 300.ms),
          const SizedBox(height: 36),
          // Name input
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: _isNameValid
                    ? AppColors.primary.withOpacity(0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _nameController,
              autofocus: false,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Adınız',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: _isNameValid
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ).animate().slideY(begin: 0.15).fadeIn(delay: 400.ms),
          const SizedBox(height: 180),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary.withOpacity(0.4), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: () {
          _controller.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Devam Et',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: _isNameValid
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
              ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _isNameValid
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _isNameValid ? _finish : null,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Keşfetmeye Başla',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String desc;

  const _OnboardingPage({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.desc,
  });
}
