import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_shell.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = SettingsStore(await SharedPreferences.getInstance());
  final initial = await store.load();

  runApp(ProviderScope(
    overrides: [
      settingsStoreProvider.overrideWithValue(store),
      initialSettingsProvider.overrideWithValue(initial),
    ],
    child: const PolishTutorApp(),
  ));
}

class PolishTutorApp extends StatelessWidget {
  const PolishTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polish AI Tutor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}
