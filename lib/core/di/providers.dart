import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai_client/ai_client.dart';
import '../db/app_database.dart';
import '../settings/app_settings.dart';
import '../speech/speech_services.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final wordsProvider = StreamProvider<List<Word>>(
  (ref) => ref.watch(databaseProvider).watchWords(),
);

/// Сколько слов нужно повторить сегодня (по SM-2).
final dueCountProvider = Provider<int>((ref) {
  final words = ref.watch(wordsProvider).value ?? const <Word>[];
  return words.where((w) => w.isDue).length;
});

/// Клиент шлюза пересоздаётся при смене Base URL / ключа / модели.
final aiClientProvider = Provider<AiClient>((ref) {
  final s = ref.watch(settingsProvider);
  final c = AiClient(baseUrl: s.baseUrl, apiKey: s.apiKey, model: s.model);
  ref.onDispose(c.close);
  return c;
});

final ttsProvider = Provider<TtsService>((ref) {
  final t = TtsService();
  ref.onDispose(t.stop);
  return t;
});

class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

/// Управление текущей активной вкладкой нижней навигации (0: Обучение, 1: Переводчик, 2: Словарь, 3: Настройки)
final currentTabProvider =
    NotifierProvider<CurrentTabNotifier, int>(CurrentTabNotifier.new);

