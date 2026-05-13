import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settings_notifier.dart';
import '../history/gamification_notifier.dart';
import '../../core/theme/colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final gamification = ref.watch(gamificationNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        children: [
          // 1. PROFIL KARTI
          _buildProfileCard(settings.name, gamification.xp, theme),
          const SizedBox(height: 32),

          // 2. UYGULAMA TERCİHLERİ
          _buildGroupTitle('Uygulama'),
          _buildSettingsGroup([
            _buildSettingRow(
              icon: Icons.dark_mode_outlined,
              color: Colors.purple,
              title: 'Karanlık Mod',
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: (val) => ref.read(settingsNotifierProvider.notifier).toggleTheme(val),
              ),
            ),
            _buildSettingRow(
              icon: Icons.notifications_none_rounded,
              color: Colors.blue,
              title: 'Bildirimler',
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (val) => ref.read(settingsNotifierProvider.notifier).toggleNotifications(val, '12:00'),
              ),
            ),
          ], theme),
          const SizedBox(height: 24),

          // 3. BESLENME PROFİLİ
          _buildGroupTitle('Beslenme Profili'),
          _buildSettingsGroup([
            _buildSettingRow(
              icon: Icons.restaurant_rounded,
              color: AppColors.primary,
              title: 'Diyet Tipi',
              subtitle: settings.dietType,
              onTap: () => _showDietPicker(context, settings.dietType),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alerjiler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Fındık', 'Gluten', 'Deniz ürünü', 'Yumurta'].map((allergy) {
                      final isSelected = settings.allergies.contains(allergy);
                      return FilterChip(
                        label: Text(allergy),
                        selected: isSelected,
                        onSelected: (selected) {
                          final newList = List<String>.from(settings.allergies);
                          selected ? newList.add(allergy) : newList.remove(allergy);
                          ref.read(settingsNotifierProvider.notifier).updateAllergies(newList);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ], theme),
          const SizedBox(height: 24),

          // 4. TEHLİKELİ BÖLGE
          _buildGroupTitle('Veri Yönetimi'),
          _buildSettingsGroup([
            _buildSettingRow(
              icon: Icons.delete_sweep_outlined,
              color: Colors.red,
              title: 'Geçmişi Temizle',
              titleColor: Colors.red,
              onTap: () => _confirmClearHistory(context),
            ),
          ], theme),

          const SizedBox(height: 48),
          const Center(
            child: Text(
              'Versiyon 1.2.0\nBugün Ne Yesem? • 2024',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, int xp, ThemeData theme) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Kullanıcı' : name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('$xp XP • Gurme Seviyesi', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1).fadeIn();
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(children: children),
    ).animate().fade(delay: 100.ms);
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: titleColor)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showDietPicker(BuildContext context, String current) {
    final diets = ['Normal', 'Vejetaryen', 'Vegan', 'Glutensiz'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: diets.map((d) => ListTile(
            title: Text(d, style: TextStyle(fontWeight: d == current ? FontWeight.bold : FontWeight.normal)),
            trailing: d == current ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
            onTap: () {
              ref.read(settingsNotifierProvider.notifier).updateDietType(d);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emin misiniz?'),
        content: const Text('Tüm yeme geçmişiniz silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              ref.read(settingsNotifierProvider.notifier).clearHistory();
              Navigator.pop(ctx);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
