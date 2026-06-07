import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/providers/filter_provider.dart';
import '../../features/settings/settings_notifier.dart';
import '../../features/fridge/fridge_mode_sheet.dart';
import '../suggestion/suggestion_state.dart';
import 'home_notifier.dart';
import 'home_state.dart';
import '../../features/suggestion/suggestion_notifier.dart';
import '../../core/services/location_service.dart';
import '../../core/services/dashboard_service.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../../shared/widgets/glass_container.dart';
import '../../shared/widgets/scale_button.dart';

final locationServiceProvider = Provider((ref) => LocationService.instance);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _dashboardLogged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDashboard();
    });
  }

  Future<void> _initDashboard() async {
    if (_dashboardLogged) return;
    
    final userProfile = ref.read(settingsNotifierProvider);
    if (userProfile.name != null && userProfile.name!.isNotEmpty) {
      // 1. Log Visit
      await DashboardService().logVisit(
        name: userProfile.name!,
        additionalData: {
          'dietType': userProfile.dietType,
          'isDarkMode': userProfile.isDarkMode,
          'notificationsEnabled': userProfile.notificationsEnabled,
          'allergies': userProfile.allergies,
        },
      );
      _dashboardLogged = true;

      // 2. Check for Update
      if (mounted) {
        await DashboardService().checkForUpdate(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeNotifierProvider);
    final userProfile = ref.read(settingsNotifierProvider);
    final globalFilter = ref.watch(filterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> moods = [
      {'label': 'Enerjik', 'icon': Icons.bolt_rounded},
      {'label': 'Farklı', 'icon': Icons.explore_rounded},
      {'label': 'Konforlu', 'icon': Icons.home_rounded},
      {'label': 'Hafif', 'icon': Icons.eco_rounded},
      {'label': 'Nostaljik', 'icon': Icons.history_rounded},
      {'label': 'Keyifli', 'icon': Icons.sentiment_very_satisfied_rounded},
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
                        const SizedBox(height: 8),
                        Text(
                          'Bugün ne yesem?',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 32,
                            letterSpacing: -1,
                          ),
                        ),
                    ],
                  ),
                ],
              ).animate().fade(duration: 600.ms).slideY(begin: -0.1, curve: Curves.easeOutCubic),

              const SizedBox(height: 32),

              Text(
                'Nasıl hissediyorsun?',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  final isSelected = state.selectedMood == mood['label'];
                  
                  return ScaleButton(
                    onTap: () => ref.read(homeNotifierProvider.notifier).setMood(mood['label']!),
                    child: GlassContainer(
                      borderRadius: 18,
                      blur: 10,
                      padding: EdgeInsets.zero,
                      color: isSelected 
                        ? null 
                        : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                      border: isSelected 
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
                        : Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05), width: 0.5),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                      ],
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mood['icon'] as IconData,
                              size: 22,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mood['label']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ).animate().fade(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, curve: Curves.easeOut),


              const SizedBox(height: 32),

              // Gelişmiş Filtreler logic
              Center(
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const FilterBottomSheet(),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Gelişmiş Filtreler',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (!globalFilter.isEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              globalFilter.activeFilterCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ).animate().fade(delay: 250.ms),

              const SizedBox(height: 16),

              ScaleButton(
                onTap: () {
                  ref.read(suggestionNotifierProvider.notifier).state = SuggestionState();
                  context.push('/suggestion');
                },
                child: GlassContainer(
                  borderRadius: 24,
                  blur: 15,
                  padding: EdgeInsets.zero,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
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
                                    fontSize: 18,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.02, 1.02), duration: 1500.ms, curve: Curves.easeInOut)
                 .animate().shimmer(delay: 1.seconds, duration: 2.seconds),
              ).animate().fade(delay: 400.ms, duration: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context: context,
                      title: 'Buzdolabı',
                      subtitle: 'Fikir al',
                      icon: Icons.kitchen_outlined,
                      color: AppColors.secondary,
                      isDark: isDark,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
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
                      isDark: isDark,
                      onTap: () => context.push('/weekly_plan'),
                    ),
                  ),
                ],
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              _buildActionCard(
                context: context,
                title: 'Dışarıdayım',
                subtitle: 'Yakınındaki en iyi restoranları keşfet',
                icon: Icons.location_on_rounded,
                color: Colors.teal,
                isDark: isDark,
                onTap: () async {
                  final locationService = ref.read(locationServiceProvider);
                  final granted = await locationService.requestPermission();
                  if (granted && context.mounted) {
                    context.push('/nearby');
                  } else if (context.mounted) {
                    _showLocationDeniedDialog(context);
                  }
                },
              ).animate().fade(delay: 450.ms).slideY(begin: 0.1),

              const SizedBox(height: 80),
            ],
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
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isDark ? 0.2 : 0.1)),
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


  String _getGreeting(String? name) {
    final hour = DateTime.now().hour;
    final prefix = hour < 12 ? 'GÜNAYDIN' : hour < 18 ? 'İYİ ÖĞLENLER' : 'İYİ AKŞAMLAR';
    return name != null && name.isNotEmpty ? '$prefix, ${name.toUpperCase()}' : prefix;
  }

  void _showLocationDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konum Erişimi Gerekli'),
        content: const Text(
          'Yakınınızdaki restoranları bulabilmemiz için konum izni vermeniz gerekmektedir.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
