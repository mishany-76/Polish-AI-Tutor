import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/speech/speech_services.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/translation_service.dart' show UiLang;
import 'exam_model.dart';
import 'exam_result_screen.dart';
import 'exam_service.dart';

class _ExamMsg {
  _ExamMsg.examiner(this.text) : fromCandidate = false;
  _ExamMsg.candidate(this.text) : fromCandidate = true;

  final String text;
  final bool fromCandidate;
}

/// Экран проведения экзаменационного испытания (Boss Fight CEFR)
class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key, this.examiner});

  final ExamExaminer? examiner;

  static Future<void> show(BuildContext context, [ExamExaminer? examiner]) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamScreen(examiner: examiner),
      ),
    );
  }

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  ExamExaminer get _examiner => widget.examiner ?? kDefaultExaminers[0];
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final SttService _stt = SttService();

  final List<_ExamMsg> _messages = [];
  final List<ChatMessage> _transcript = [];

  bool _loading = false;
  bool _evaluating = false;
  bool _listening = false;
  bool _speakExaminer = true;

  // Таймер на 5 минут (300 секунд)
  int _secondsRemaining = 300;
  Timer? _countdownTimer;

  // Польская клавиатурная панель диакритики
  static const _diacritics = ['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż'];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _initExam();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    _stt.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        // Время вышло — предлагаем оценить
        _toast('⏱️ Czas egzaminu dobiegł końca!');
      }
    });
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _candidateAnswersCount => _messages.where((m) => m.fromCandidate).length;

  int get _currentStage {
    final count = _candidateAnswersCount;
    if (count <= 1) return 1;
    if (count <= 3) return 2;
    return 3;
  }

  Future<void> _initExam() async {
    final initialPl = _examiner.openingPl;
    _messages.add(_ExamMsg.examiner(initialPl));
    _transcript.add(ChatMessage('assistant', initialPl));
    if (_speakExaminer) _speak(initialPl);
  }

  Future<void> _speak(String text) async {
    try {
      await ref.read(ttsProvider).speak(text);
    } catch (_) {}
  }

  Future<void> _stopSpeaking() async {
    try {
      await ref.read(ttsProvider).stop();
    } catch (_) {}
  }

  void _insertChar(String ch) {
    final text = _input.text;
    final sel = _input.selection;
    if (sel.isValid && sel.start >= 0) {
      final newText = text.replaceRange(sel.start, sel.end, ch);
      _input.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + ch.length),
      );
    } else {
      _input.text = text + ch;
      _input.selection = TextSelection.collapsed(offset: _input.text.length);
    }
  }

  Future<void> _sendCandidateReply() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading || _evaluating) return;
    _input.clear();
    _stopSpeaking();

    setState(() {
      _messages.add(_ExamMsg.candidate(text));
      _transcript.add(ChatMessage('user', text));
      _loading = true;
    });
    _scrollDown();

    try {
      final stage = _currentStage;
      final prompt = '''
Jesteś oficjalnym egzaminatorem języka polskiego (${_examiner.name}, ${_examiner.rolePl}).
Prowadzisz państwowy egzamin ustny ze znajomości języka polskiego jako obcego.

Aktualny etap egzaminu:
Etap 1: Autoprezentacja, kim jest kandydat, plany i życie w Polsce.
Etap 2: Praktyczna sytuacja życiowa (np. załatwienie sprawy w urzędzie, wynajem mieszkania, wizyta u lekarza, bank lub praca).
Etap 3: Pytanie problemowe, opinia kandydata, argumentacja (np. adaptacja, tradycje, różnice kulturowe).

Obecny etap kandydata na podstawie liczby odpowiedzi: Etap $stage.
Zadaj kolejne realistyczne pytanie egzaminacyjne. 
Odpowiadaj WYŁĄCZNIE po polsku, naturalnym, profesjonalnym tonem egzaminatora. Nie dodawaj żadnych tłumaczeń ani podpowiedzi w tekście. Mów zwięźle (1-3 zdania).
''';

      final response = await ref.read(aiClientProvider).chat([
        ChatMessage('system', prompt),
        ..._transcript,
      ], temperature: 0.5);

      final cleanReply = response.trim();
      _transcript.add(ChatMessage('assistant', cleanReply));

      if (mounted) {
        setState(() {
          _messages.add(_ExamMsg.examiner(cleanReply));
        });
        _scrollDown();
        if (_speakExaminer) _speak(cleanReply);
      }
    } catch (_) {
      // Fallback реплика экзаменатора при отсутствии сети
      final fallbackReply = _fallbackExaminerReply(_candidateAnswersCount);
      _transcript.add(ChatMessage('assistant', fallbackReply));
      if (mounted) {
        setState(() {
          _messages.add(_ExamMsg.examiner(fallbackReply));
        });
        _scrollDown();
        if (_speakExaminer) _speak(fallbackReply);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fallbackExaminerReply(int turn) {
    switch (turn) {
      case 1:
        return 'Dziękuję za przedstawienie się. Przejdźmy teraz do etapu drugiego: wyobraźmy sobie, że musi pan/pani załatwić sprawę meldunku w polskim urzędzie. Jak pan/pani wytłumaczy urzędnikowi swój cel wizyty?';
      case 2:
        return 'Rozumiem. A co zrobi pan/pani, jeśli właściciel wynajmowanego mieszkania zgłosi niespodziewaną podwyżkę opłat za media? Jak zareagujesz?';
      case 3:
      default:
        return 'Bardzo dobrze. Na koniec etapu trzeciego: proszę wyrazić swoją opinię, co jest najtrudniejsze w nauce języka polskiego dla obcokrajowca i jak pan/pani sobie z tym radzi?';
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      return;
    }
    final perm = await Permission.microphone.request();
    if (!perm.isGranted) {
      _toast('Wymagany jest dostęp do mikrofonu do odpowiedzi ustnej.');
      return;
    }
    await _stopSpeaking();
    final ok = await _stt.init(onError: (_) {
      if (mounted) setState(() => _listening = false);
    });
    if (!ok) {
      _toast('Rozpoznawanie mowy nie jest dostępne na tym urządzeniu.');
      return;
    }
    setState(() => _listening = true);
    await _stt.listen((text, isFinal) {
      if (!mounted) return;
      _input.text = text;
      if (isFinal) {
        setState(() => _listening = false);
        _sendCandidateReply();
      }
    });
  }

  Future<void> _finishAndEvaluate() async {
    if (_candidateAnswersCount == 0) {
      _toast('Proszę odpowiedzieć przynajmniej na jedno pytanie egzaminatora.');
      return;
    }

    _countdownTimer?.cancel();
    await _stopSpeaking();
    await _stt.cancel();

    setState(() => _evaluating = true);

    final lang = ref.read(settingsProvider).lang;
    final examService = ref.read(examServiceProvider);

    final result = await examService.evaluateExam(
      transcript: _transcript,
      examinerName: _examiner.name,
      lang: lang,
    );

    if (mounted) {
      setState(() => _evaluating = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ExamResultScreen(result: result),
        ),
      );
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const Text('🎓', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.examBossTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    strings.examBossSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _speakExaminer ? 'Głos egzaminatora włączony' : 'Głos wyłączony',
            icon: Icon(_speakExaminer ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() => _speakExaminer = !_speakExaminer);
              if (!_speakExaminer) _stopSpeaking();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Шапка экзаменатора с таймером и стадиями
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryCarmine.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Text(_examiner.emoji, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _examiner.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            _examiner.role(lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Таймер
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _secondsRemaining <= 60
                            ? Colors.red.withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _secondsRemaining <= 60 ? Colors.red : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: _secondsRemaining <= 60 ? Colors.red : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formattedTime,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _secondsRemaining <= 60 ? Colors.red : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Индикатор стадий (1. Kim jesteś ➔ 2. Sytuacja ➔ 3. Opinia)
                Row(
                  children: [
                    _stagePill(1, '1. Kim jesteś', _currentStage >= 1, _currentStage == 1),
                    const SizedBox(width: 4),
                    _stagePill(2, '2. Sytuacja', _currentStage >= 2, _currentStage == 2),
                    const SizedBox(width: 4),
                    _stagePill(3, '3. Opinia', _currentStage >= 3, _currentStage == 3),
                  ],
                ),
              ],
            ),
          ),

          // Чат сообщений
          Expanded(
            child: _evaluating
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppTheme.primaryCarmine),
                        const SizedBox(height: 16),
                        Text(
                          lang == UiLang.pl
                              ? 'Komisja ocenia Twoje odpowiedzi według kryteriów CEFR…'
                              : (lang == UiLang.uk
                                  ? 'Комісія оцінює ваші відповіді за критеріями CEFR…'
                                  : 'Комиссия оценивает ваши ответы по шкале CEFR…'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      return _buildMsgBubble(m);
                    },
                  ),
          ),

          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang == UiLang.pl ? 'Egzaminator analizuje wypowiedź…' : 'Экзаменатор слушает ответ…',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

          // Кнопка завершения экзамена
          if (_candidateAnswersCount >= 1 && !_evaluating)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _finishAndEvaluate,
                  icon: const Icon(Icons.assignment_turned_in, size: 18),
                  label: Text(
                    strings.examFinishButton,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // Панель диакритики
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _diacritics.length,
              separatorBuilder: (context, index) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final ch = _diacritics[index];
                return InkWell(
                  onTap: () => _insertChar(ch),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ch,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // Поле ввода и кнопка микрофона/отправки
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: lang == UiLang.pl
                            ? 'Odpowiedź kandydata po polsku…'
                            : (lang == UiLang.uk ? 'Відповідь польською мовою…' : 'Ответ на польском языке…'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onSubmitted: (_) => _sendCandidateReply(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: _listening ? Colors.red : AppTheme.primaryCarmine,
                    ),
                    icon: Icon(_listening ? Icons.mic : Icons.mic_none),
                    onPressed: _toggleMic,
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppTheme.primaryCarmine),
                    icon: const Icon(Icons.send_rounded),
                    onPressed: _sendCandidateReply,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stagePill(int stageNum, String title, bool isCurrentOrDone, bool isCurrent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCurrent
              ? AppTheme.primaryCarmine
              : (isCurrentOrDone
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.grey.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isCurrent
                ? Colors.white
                : (isCurrentOrDone ? Colors.green.shade800 : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildMsgBubble(_ExamMsg m) {
    final theme = Theme.of(context);
    final isCandidate = m.fromCandidate;

    return Align(
      alignment: isCandidate ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCandidate
              ? AppTheme.primaryCarmine
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: isCandidate
              ? null
              : Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCandidate) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _examiner.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryCarmine,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _speak(m.text),
                    child: const Icon(Icons.volume_up, size: 15, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              m.text,
              style: TextStyle(
                fontSize: 14.5,
                color: isCandidate ? Colors.white : theme.colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

