import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/filter_provider.dart';
import '../../shared/widgets/banner_ad_widget.dart';
import '../../features/settings/settings_notifier.dart';
import '../../features/fridge/fridge_mode_sheet.dart';
import 'home_notifier.dart';
import 'home_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);
    final userProfile = ref.watch(settingsNotifierProvider);
    final globalFilter = ref.watch(filterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> moods = [
      {'label': 'Enerjik', 'icon': Icons.bolt_rounded},
      {'label': 'Rahatlatıcı', 'icon': Icons.spa_rounded},
      {'label': 'Konforlu', 'icon': Icons.home_rounded},
      {'label': 'Hafif', 'icon': Icons.eco_rounded},
      {'label': 'Kutlama', 'icon': Icons.celebration_rounded},
    ];

    final List<Map<String, dynamic>> mealTypes = [
      {'label': 'Kahvaltı', 'icon': Icons.breakfast_dining_rounded},
      {'label': 'Öğle', 'icon': Icons.wb_sunny_rounded},
      {'label': 'Akşam', 'icon': Icons.nights_stay_rounded},
      {'label': 'Atıştırmalık', 'icon': Icons.cookie_rounded},
      {'label': 'Tatlı', 'icon': Icons.cake_rounded},
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.read(homeNotifierProvider.notifier).suggestFood(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // 1. TOP BAR: Greeting & Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(userProfile.name),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bugün ne yesem?',
                        style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                      ),
                    ],
                  ),
                  _buildProfileAvatar(userProfile.name),
                ],
              ).animate().fade().slideY(begin: -0.1),

              const SizedBox(height: 8),
              
              // Filter Badge
              if (!globalFilter.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Aktif Filtreler Açık',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(),

              const SizedBox(height: 32),

              // 2. MOOD SELECTOR
              Text(
                'Nasıl hissediyorsun?',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    final mood = moods[index];
                    final isSelected = state.selectedMood == mood['label'];
                    
                    return GestureDetector(
                      onTap: () => ref.read(homeNotifierProvider.notifier).setMood(mood['label']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        width: 75,
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mood['icon'],
                              size: 28,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood['label']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fade(delay: 100.ms),

              const SizedBox(height: 32),

              // 3. MEAL FILTERS
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: mealTypes.length,
                  itemBuilder: (context, index) {
                    final meal = mealTypes[index];
                    final isSelected = state.selectedMealType == meal['label'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              meal['icon'], 
                              size: 16, 
                              color: isSelected ? Colors.white : AppColors.textSecondary
                            ),
                            const SizedBox(width: 6),
                            Text(meal['label']!),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) => ref.read(homeNotifierProvider.notifier).setMealType(meal['label']!),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.transparent,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fade(delay: 200.ms),

              const SizedBox(height: 40),

              // 4. BANA ÖNER BUTONU
              GestureDetector(
                onTap: () async {
                  await ref.read(homeNotifierProvider.notifier).suggestFood();
                  if (context.mounted) context.push('/suggestion');
                },
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Center(
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.casino_rounded, color: Colors.white, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Bana Öner',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ).animate().scale(delay: 300.ms),

              const SizedBox(height: 40),

              // 5. FEATURE CARDS
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Buzdolabı',
                      subtitle: 'Fikir al',
                      icon: Icons.kitchen_outlined,
                      color: AppColors.secondary,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const FridgeModeSheet(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Haftalık',
                      subtitle: 'Plan yap',
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.primary,
                      onTap: () => context.push('/weekly_plan'),
                    ),
                  ),
                ],
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // LAST SUGGESTED RECAP
              if (state.lastSuggestedFood != null) ...[
                Text(
                  'Son Önerilen',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildLastSuggestedCard(theme, state),
              ].animate().fade(delay: 500.ms),
              
              const SizedBox(height: 80), // Padding for Ad
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? name) {
    final initial = name != null && name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastSuggestedCard(ThemeData theme, HomeState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(state.lastSuggestedFood!.imageEmoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.lastSuggestedFood!.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.lastSuggestedFood!.timeMinutes} dk • ${state.lastSuggestedFood!.cuisine}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  String _getGreeting(String? name) {
    final hour = DateTime.now().hour;
    final prefix = hour < 12 ? 'GÜNAYDIN' : hour < 18 ? 'İYİ ÖĞLENLER' : 'İYİ AKŞAMLAR';
    return name != null && name.isNotEmpty ? '$prefix, ${name.toUpperCase()}' : prefix;
  }
}
