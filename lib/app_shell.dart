import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/providers.dart';
import 'core/localization/app_strings.dart';
import 'features/dashboard/learn_dashboard.dart';
import 'features/dictionary/dictionary_screen.dart';
import 'features/scanner/scanner_screen.dart';
import 'features/settings/settings_screen.dart';

/// Нижняя навигация: Обучение · Переводчик · Словарь · Настройки.
/// Строится только активная вкладка, чтобы камера освобождалась при уходе со вкладки Переводчик.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _pages = <Widget>[
    LearnDashboard(),
    ScannerScreen(),
    DictionaryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(currentTabProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      body: KeyedSubtree(key: ValueKey(index), child: _pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(currentTabProvider.notifier).setTab(i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.track_changes),
            label: strings.tabLearn,
          ),
          NavigationDestination(
            icon: const Icon(Icons.translate),
            label: strings.tabTranslator,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book),
            label: strings.tabDictionary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: strings.tabSettings,
          ),
        ],
      ),
    );
  }
}
