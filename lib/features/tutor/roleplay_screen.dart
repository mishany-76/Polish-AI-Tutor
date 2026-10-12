import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/speech/speech_services.dart';
import '../../core/widgets/talking_wave_indicator.dart';
import '../scanner/translation_service.dart' show UiLang;
import 'scenarios.dart';

class _Msg {
  _Msg.npc(
    this.text, {
    this.npcTr,
    this.feedback,
    this.correction,
    this.hint,
    this.hintTr,
  }) : fromUser = false;

  _Msg.user(this.text)
      : fromUser = true,
        npcTr = null,
        feedback = null,
        correction = null,
        hint = null,
        hintTr = null;

  final String text;
  final bool fromUser;
  String? npcTr;
  final String? feedback;
  final String? correction;
  final String? hint;
  String? hintTr;
  bool showTranslation = false;
}

/// Ролевой диалог: ИИ играет поляка, пользователь отвечает голосом или текстом.
class RoleplayScreen extends ConsumerStatefulWidget {
  const RoleplayScreen({super.key, required this.scenario});

  final Scenario scenario;

  @override
  ConsumerState<RoleplayScreen> createState() => _RoleplayScreenState();
}

class _RoleplayScreenState extends ConsumerState<RoleplayScreen> {
  final _msgs = <_Msg>[];
  final _history = <ChatMessage>[];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _stt = SttService();

  bool _loading = false;
  bool _listening = false;
  bool _speakNpc = true;
  String? _error;
  String? _speakingText;

  @override
  void initState() {
    super.initState();
    _history.add(const ChatMessage(
      'user',
      'Zacznij scenę: przywitaj się jako twoja postać i zadaj pierwsze pytanie.',
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestNpc());
  }

  @override
  void dispose() {
    _stt.cancel();
    _stopSpeaking();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    setState(() => _speakingText = text);
    try {
      await ref.read(ttsProvider).speak(text);
    } finally {
      if (mounted && _speakingText == text) {
        setState(() => _speakingText = null);
      }
    }
  }

  void _stopSpeaking() {
    ref.read(ttsProvider).stop();
    if (_speakingText != null) {
      setState(() => _speakingText = null);
    }
  }

  String get _systemPrompt {
    final s = widget.scenario;
    final lang = ref.read(settingsProvider).lang;
    final targetLang = lang == UiLang.uk ? 'украинский (українська мова)' : 'русский (русский язык)';
    final uiName = lang == UiLang.uk ? 'украинском' : 'русском';
    return '''
Ты — «Kasia», добрый и терпеливый польский собеседник и репетитор. Ученик — взрослый человек, живущий в Польше.
Сцена: ${s.title}. Твоя роль: ${s.npcRole}. Ситуация: ${s.setting}. Уровень: ${s.level}.
Язык перевода и подсказок: $targetLang ($uiName).

ПРАВИЛА:
1. Реплика персонажа ("npc_pl") — ТОЛЬКО по-польски, строго 1–2 коротких живых предложения (максимум 20–25 слов).
2. ЦЕНЫ, ЧИСЛА И СЧЕТА: Если в сцене происходит оплата, покупка, счет или банковская операция, ОБЯЗАТЕЛЬНО называй реалистичные суммы счета ПОЛЬСКИМИ СЛОВАМИ (например: «Do zapłaty czterdzieści siedem złotych i osiemdziesiąt groszy» или «To będzie dwadzieścia trzy złote»). Спрашивай: «Płatność kartą, gotówką czy BLIKiem?», «Wydać resztę?», «Czy potrzebny jest paragon fiskalny?».
3. ЛИТЕРАТУРНЫЙ ПЕРЕВОД РЕПЛИКИ ("npc_translation") — ОБЯЗАТЕЛЬНО переведи реплику персонажа на $targetLang точно, живо и с учетом контекста (например, Żappka — це додаток/приложение Żappka, paragon — чек, rachunek — счёт, BLIK — платіж BLIK).
4. Обратная связь ("feedback") на реплику ученика — на $uiName языке (1 короткое предложение: похвала или мягкое исправление 1 главной ошибки; если ошибок нет или первая реплика — null).
5. "correction" — правильная польская фраза ученика при ошибке, иначе null.
6. "hint_pl" — краткий польский образец ответа ученика (до 8-10 слов). Если была названа сумма счета, в подсказку ОБЯЗАТЕЛЬНО включи расшифровку суммы цифрами (например: "47,80 zł — Płacę kartą" или "23,50 zł — Płacę BLIKiem").
7. "hint_translation" — перевод образца ответа на $targetLang.
8. Не задавай длинных вопросов, говори кратко и живо, как реальный поляк.

ФОРМАТ — ТОЛЬКО один строгий JSON без markdown:
{
  "npc_pl": "реплика на польском",
  "npc_translation": "высококачественный перевод на $targetLang",
  "feedback": "обратная связь или null",
  "correction": "исправление или null",
  "hint_pl": "образец ответа или null",
  "hint_translation": "перевод образца или null"
}
На самую первую реплику сцены feedback=null, correction=null.''';
  }

  Future<void> _requestNpc() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await ref.read(aiClientProvider).chat([
        ChatMessage('system', _systemPrompt),
        ..._history,
      ], temperature: 0.7);
      final obj = extractJson(raw);
      String? s(dynamic v) {
        final t = v?.toString().trim();
        return (t == null || t.isEmpty || t == 'null') ? null : t;
      }

      final npc = s(obj?['npc_pl']) ?? s(obj?['npc']) ?? raw;
      final npcTr = s(obj?['npc_translation']);
      final hint = s(obj?['hint_pl']) ?? s(obj?['hint']);
      final hintTr = s(obj?['hint_translation']);
      _history.add(ChatMessage('assistant', raw));
      if (!mounted) return;

      final msg = _Msg.npc(
        npc,
        npcTr: npcTr,
        feedback: s(obj?['feedback']),
        correction: s(obj?['correction']),
        hint: hint,
        hintTr: hintTr,
      );

      setState(() {
        _msgs.add(msg);
      });
      _scrollDown();
      if (_speakNpc) _speak(npc);
    } on AiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Что-то пошло не так. Повторите.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _send([String? override]) {
    final text = (override ?? _input.text).trim();
    if (text.isEmpty || _loading) return;
    _input.clear();
    _stopSpeaking();
    _history.add(ChatMessage('user', text));
    setState(() => _msgs.add(_Msg.user(text)));
    _scrollDown();
    _requestNpc();
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
      _toast('Нужен доступ к микрофону для голосового ответа.');
      return;
    }
    await ref.read(ttsProvider).stop();
    final ok = await _stt.init(onError: (_) {
      if (mounted) setState(() => _listening = false);
    });
    if (!ok) {
      _toast('Распознавание речи недоступно на этом устройстве.');
      return;
    }
    setState(() => _listening = true);
    await _stt.listen((text, isFinal) {
      if (!mounted) return;
      _input.text = text;
      if (isFinal) {
        setState(() => _listening = false);
        _send();
      }
    });
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  Future<void> _finish() async {
    await _stt.cancel();
    _stopSpeaking();
    if (_msgs.where((m) => m.fromUser).isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (!mounted) return;
    final lang = ref.read(settingsProvider).lang;
    final uiName = lang == UiLang.uk ? 'украинском' : 'русском';
    final future = ref.read(aiClientProvider).chatJson([
      ChatMessage('system', _systemPrompt),
      ..._history,
      ChatMessage(
        'user',
        'Koniec sceny. Подведи итог СТРОГО одним JSON без markdown на $uiName языке: '
        '{"praise":"1 похвала","improvements":["1-2 главных улучшения"],'
        '"new_words":[{"pl":"слово или фраза","tr":"перевод"}]} — ровно 3 new_words.',
      ),
    ]);
    await showDialog<void>(
      context: context,
      builder: (_) => _SummaryDialog(future: future, uk: lang == UiLang.uk),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scenario;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${s.emoji} ${s.title}', style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            tooltip: 'Озвучка ответов',
            onPressed: () {
              setState(() => _speakNpc = !_speakNpc);
              if (!_speakNpc) _stopSpeaking();
            },
            icon: Icon(_speakNpc ? Icons.volume_up : Icons.volume_off),
          ),
          TextButton(onPressed: _finish, child: const Text('Завершить')),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text('${s.level} · ${s.vocab.join(' · ')}',
                  style: theme.textTheme.bodySmall),
            ),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.all(12),
                children: [
                  for (final m in _msgs) _bubble(m, theme),
                  if (_loading)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ref.watch(settingsProvider).isUk
                                  ? 'Пані Кася друкує…'
                                  : 'Пани Кася печатает…',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(children: [
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: theme.colorScheme.error)),
                        TextButton(
                          onPressed: _requestNpc,
                          child: const Text('Повторить'),
                        ),
                      ]),
                    ),
                ],
              ),
            ),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_Msg m, ThemeData theme) {
    if (m.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(m.text, style: const TextStyle(fontSize: 16)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m.feedback != null)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '💡 ${m.feedback}${m.correction != null ? '\n✔ ${m.correction}' : ''}',
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(m.text, style: const TextStyle(fontSize: 16)),
                  ),
                  if (_speakingText == m.text) ...[
                    TalkingWaveIndicator(color: theme.colorScheme.primary, height: 16),
                    const SizedBox(width: 2),
                  ],
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: _speakingText == m.text ? 'Остановить' : 'Озвучить',
                    onPressed: () => _speakingText == m.text ? _stopSpeaking() : _speak(m.text),
                    icon: Icon(
                      _speakingText == m.text ? Icons.stop_circle_outlined : Icons.volume_up,
                      size: 20,
                      color: _speakingText == m.text ? theme.colorScheme.primary : null,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Показать перевод',
                    onPressed: () {
                      setState(() {
                        m.showTranslation = !m.showTranslation;
                      });
                    },
                    icon: Icon(
                      Icons.translate,
                      size: 20,
                      color: m.showTranslation ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
              if (m.showTranslation) ...[
                const Divider(height: 12),
                Text(
                  (m.npcTr != null && m.npcTr!.isNotEmpty)
                      ? m.npcTr!
                      : '(Переклад недоступний)',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (m.hint != null)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _input.text = m.hint!,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Подсказка (нажмите, чтобы вставить):',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          if (_speakingText == m.hint) ...[
                            TalkingWaveIndicator(color: theme.colorScheme.primary, height: 14),
                            const SizedBox(width: 4),
                          ],
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: _speakingText == m.hint ? 'Остановить' : 'Озвучить подсказку',
                            icon: Icon(
                              _speakingText == m.hint ? Icons.stop_circle_outlined : Icons.volume_up,
                              size: 19,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              if (_speakingText == m.hint) {
                                _stopSpeaking();
                              } else {
                                _speak(m.hint!);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.hint!,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      if (m.hintTr != null && m.hintTr!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          m.hintTr!,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _inputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(children: [
        IconButton.filledTonal(
          onPressed: _loading ? null : _toggleMic,
          icon: Icon(_listening ? Icons.stop : Icons.mic),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _input,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              hintText: _listening ? 'Слушаю…' : 'Odpowiedz po polsku…',
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _loading ? null : _send,
          icon: const Icon(Icons.send),
        ),
      ]),
    );
  }
}

class _SummaryDialog extends ConsumerWidget {
  const _SummaryDialog({required this.future, required this.uk});

  final Future<Map<String, dynamic>> future;
  final bool uk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Итог сцены'),
      content: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Text('Не удалось подвести итог: ${snap.error}');
          }
          if (!snap.hasData) {
            return const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final d = snap.data!;
          final improvements = (d['improvements'] as List? ?? const [])
              .map((e) => e.toString())
              .toList();
          final words = <(String, String)>[
            for (final w in (d['new_words'] as List? ?? const []))
              if (w is Map && w['pl'] != null)
                (w['pl'].toString(), (w['tr'] ?? '').toString()),
          ];
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (d['praise'] != null) Text('👏 ${d['praise']}'),
                for (final i in improvements)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('💡 $i'),
                  ),
                if (words.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Слова для повторения:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  for (final w in words) Text('• ${w.$1} — ${w.$2}'),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () async {
                      final db = ref.read(databaseProvider);
                      var added = 0;
                      for (final w in words) {
                        if (await db.addScanWord(
                          form: w.$1,
                          translation: w.$2,
                          uk: uk,
                          source: 'chat',
                        )) {
                          added++;
                        }
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('✅ Добавлено в колоду: $added'),
                        ));
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Добавить в колоду'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}

