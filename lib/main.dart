import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/user_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final store = SettingsStore(prefs);
  final initial = await store.load();

  try {
    await NotificationService.instance.init();
    final notifEnabled = prefs.getBool(NotificationService.prefNotificationsEnabled) ?? true;
    if (notifEnabled) {
      final hour = prefs.getInt(NotificationService.prefNotificationsHour) ?? 19;
      final minute = prefs.getInt(NotificationService.prefNotificationsMinute) ?? 0;
      NotificationService.instance.scheduleDailyReminder(
        hour: hour,
        minute: minute,
        language: initial.lang,
      );
    }
  } catch (e) {
    debugPrint('Notification setup error in main: $e');
  }

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      settingsStoreProvider.overrideWithValue(store),
      initialSettingsProvider.overrideWithValue(initial),
    ],
    child: const PolishTutorApp(),
  ));
}

class PolishTutorApp extends ConsumerWidget {
  const PolishTutorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return MaterialApp(
      title: 'Polish AI Tutor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: profile.onboardingCompleted
          ? const AppShell()
          : const OnboardingScreen(),
    );
  }
}
