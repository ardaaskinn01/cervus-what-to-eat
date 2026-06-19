import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_notifier.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        children: [
          // 1. PROFIL KARTI
          _buildProfileCard(settings.name, settings.dietType, settings.allergies, theme),
          const SizedBox(height: 32),

          // 2. UYGULAMA TERCİHLERİ
          _buildGroupTitle('Uygulama'),
          _buildSettingsGroup([
            _buildSettingRow(
              icon: Icons.person_outline_rounded,
              color: Colors.orange,
              title: 'İsim Değiştir',
              subtitle: settings.name,
              onTap: () => _editName(context, settings.name),
            ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alerjiler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Gluten', 'Süt Ürünü', 'Yumurta', 'Fındık', 'Fıstık', 'Balık', 'Kabuklu Deniz Ürünleri', 'Soya', 'Hardal'].map((allergy) {
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

          // 4. DİĞER / HAKKINDA
          _buildGroupTitle('Diğer'),
          _buildSettingsGroup([
            _buildSettingRow(
              icon: Icons.privacy_tip_outlined,
              color: Colors.teal,
              title: 'Gizlilik Politikası',
              onTap: () => _launchPrivacyPolicy(),
            ),
          ], theme),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String dietType, List<String> allergies, ThemeData theme) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final subText = allergies.isNotEmpty ? '$dietType • ${allergies.length} Alerji' : dietType;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? 'Kullanıcı' : name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subText, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
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

  void _editName(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('İsim Güncelle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Yeni İsminiz',
                  filled: true,
                  fillColor: AppColors.textSecondary.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.length >= 2) {
                      ref.read(settingsNotifierProvider.notifier).updateName(newName);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Güncelle', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showDietPicker(BuildContext context, String current) {
    final diets = ['Normal', 'Vejetaryen', 'Vegan', 'Glutensiz'];
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: diets.map((d) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(d, style: TextStyle(fontWeight: d == current ? FontWeight.bold : FontWeight.normal)),
              trailing: d == current ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
              onTap: () {
                ref.read(settingsNotifierProvider.notifier).updateDietType(d);
                Navigator.pop(ctx);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://cervusdigital.com/pickeat/privacy-policy/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}

