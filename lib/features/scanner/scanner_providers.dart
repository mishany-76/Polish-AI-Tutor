import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import 'doc_analysis_service.dart';
import 'menu_analysis_service.dart';
import 'ocr_service.dart';
import 'translation_service.dart';
import 'word_analysis.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final s = OcrService();
  ref.onDispose(s.dispose);
  return s;
});

/// Пересоздаётся при смене языка подсказок (UK/RU) или настроек шлюза.
final translationServiceProvider = Provider<TranslationService>((ref) {
  final lang = ref.watch(settingsProvider.select((s) => s.lang));
  final aiClient = ref.watch(aiClientProvider);
  final db = ref.watch(databaseProvider);
  final s = TranslationService(
    aiClient: aiClient,
    db: db,
    lang: lang,
  );
  ref.onDispose(s.dispose);
  return s;
});

final wordAnalysisServiceProvider = Provider<WordAnalysisService>((ref) {
  return WordAnalysisService(
    ref.watch(aiClientProvider),
    ref.watch(databaseProvider),
  );
});

final docAnalysisServiceProvider = Provider<DocAnalysisService>((ref) {
  return DocAnalysisService(
    ref.watch(aiClientProvider),
    ref.watch(databaseProvider),
  );
});

final menuAnalysisServiceProvider = Provider<MenuAnalysisService>((ref) {
  return MenuAnalysisService(
    aiClient: ref.watch(aiClientProvider),
    db: ref.watch(databaseProvider),
  );
});



