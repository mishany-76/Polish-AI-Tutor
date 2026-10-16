import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Озвучка польского (встроенный TTS Android).
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _tts.setLanguage('pl-PL');
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  /// Возвращает false, если озвучить не удалось (нет голоса pl-PL и т.п.).
  Future<bool> speak(String text, {double? rate}) async {
    try {
      await _init();
      if (rate != null) {
        await _tts.setSpeechRate(rate);
      } else {
        await _tts.setSpeechRate(0.45);
      }
      await _tts.stop();
      final r = await _tts.speak(text);
      return r == 1;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Распознавание речи пользователя (pl-PL).
class SttService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  bool get isListening => _stt.isListening;

  Future<bool> init({void Function(String)? onError}) async {
    _available = await _stt.initialize(
      onError: (e) => onError?.call(e.errorMsg),
    );
    return _available;
  }

  Future<void> listen(
    void Function(String text, bool isFinal) onResult,
  ) async {
    if (!_available) return;
    await _stt.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'pl_PL',
        listenFor: const Duration(seconds: 25),
        pauseFor: const Duration(seconds: 3),
      ),
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
    );
  }

  Future<void> stop() => _stt.stop();
  Future<void> cancel() => _stt.cancel();
}
