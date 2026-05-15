import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'features/settings/settings_notifier.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/ad_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/dashboard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  // Graceful initialization of services
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification Service init error: $e');
  }

  try {
    await AdService.instance.init(prefs);
  } catch (e) {
    debugPrint('Ad Service init error: $e');
  }

  try {
    await DashboardService().init();
  } catch (e) {
    debugPrint('Dashboard Service init error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WhatToEatApp(),
    ),
  );
}

class WhatToEatApp extends ConsumerWidget {
  const WhatToEatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    return MaterialApp.router(
      title: 'Bugün Ne Yesem?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
