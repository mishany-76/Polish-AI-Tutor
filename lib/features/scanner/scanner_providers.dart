import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import 'ocr_service.dart';
import 'translation_service.dart';
import 'word_analysis.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final s = OcrService();
  ref.onDispose(s.dispose);
  return s;
});

/// Пересоздаётся при смене языка подсказок (UK/RU).
final translationServiceProvider = Provider<TranslationService>((ref) {
  final lang = ref.watch(settingsProvider.select((s) => s.lang));
  final s = TranslationService(lang: lang);
  ref.onDispose(s.dispose);
  return s;
});

final wordAnalysisServiceProvider = Provider<WordAnalysisService>((ref) {
  return WordAnalysisService(
    ref.watch(aiClientProvider),
    ref.watch(databaseProvider),
  );
});

