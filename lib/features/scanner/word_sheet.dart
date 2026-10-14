import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import 'ocr_service.dart';
import 'scanner_providers.dart';
import 'word_analysis.dart';

/// Нижняя панель по тапу на слово:
/// перевод (ML Kit, офлайн) → «В колоду» → «Разобрать» (ИИ-шлюз) → «Сохранить разбор».
class WordSheet extends ConsumerStatefulWidget {
  const WordSheet({super.key, required this.word});

  final OcrWord word;

  @override
  ConsumerState<WordSheet> createState() => _WordSheetState();
}

class _WordSheetState extends ConsumerState<WordSheet> {
  late final Future<String> _translation;
  bool _inDeck = false;
  bool _checkedDeck = false;
  bool _analyzing = false;
  String? _analysisError;
  WordAnalysis? _analysis;
  bool _analysisSaved = false;

  String get _form => widget.word.clean;

  @override
  void initState() {
    super.initState();
    _translation = ref.read(translationServiceProvider).translateWord(
          _form,
          sentence: widget.word.lineText,
        );
    ref.read(databaseProvider).findByForm(_form).then((w) {
      if (mounted) {
        setState(() {
          _inDeck = w != null;
          _checkedDeck = true;
        });
      }
    });
  }

  Future<void> _addToDeck() async {
    final settings = ref.read(settingsProvider);
    String? tr;
    try {
      tr = await _translation;
    } catch (_) {}
    final added = await ref.read(databaseProvider).addScanWord(
          form: _form,
          translation: tr,
          uk: settings.isUk,
          examplePl: widget.word.lineText.isEmpty ? null : widget.word.lineText,
        );
    if (!mounted) return;
    setState(() => _inDeck = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(added
          ? '✅ Добавлено в колоду для тренировок'
          : 'Уже в колоде'),
    ));
  }

  Future<void> _analyze() async {
    setState(() {
      _analyzing = true;
      _analysisError = null;
    });
    try {
      final a = await ref.read(wordAnalysisServiceProvider).analyze(
            word: _form,
            sentence: widget.word.lineText,
            lang: ref.read(settingsProvider).lang,
          );
      if (mounted) setState(() => _analysis = a);
    } on AiException catch (e) {
      if (mounted) setState(() => _analysisError = e.message);
    } catch (_) {
      if (mounted) setState(() => _analysisError = 'Не удалось получить разбор.');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _saveAnalysis() async {
    final a = _analysis;
    if (a == null) return;
    final ex = a.examples.isEmpty ? null : a.examples.first;
    final note = [
      if (a.caseAnalysis.isNotEmpty) a.caseAnalysis,
      if (a.falseFriendNote != null) '⚠️ ${a.falseFriendNote}',
    ].join('\n');
    await ref.read(databaseProvider).saveAnalysis(
          form: _form,
          lemma: a.lemma,
          uk: ref.read(settingsProvider).isUk,
          pos: a.pos,
          gender: a.gender,
          translation: a.translation,
          examplePl: ex?.pl ?? widget.word.lineText,
          exampleTr: ex?.tr,
          note: note.isEmpty ? null : note,
          isFalseFriend: a.isFalseFriend,
        );
    if (!mounted) return;
    setState(() {
      _analysisSaved = true;
      _inDeck = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Разбор сохранён в словарь')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxH = MediaQuery.of(context).size.height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_form, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              _buildTranslation(theme),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (!_checkedDeck || _inDeck) ? null : _addToDeck,
                    icon: Icon(_inDeck ? Icons.check : Icons.add),
                    label: Text(_inDeck ? 'Уже в колоде' : 'В колоду'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _analyzing ? null : _analyze,
                    icon: _analyzing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(_analyzing ? 'Думаю…' : 'Разобрать'),
                  ),
                ),
              ]),
              if (_analysisError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_analysisError!,
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
              if (_analysis != null) _AnalysisCard(
                analysis: _analysis!,
                saved: _analysisSaved,
                onSave: _saveAnalysis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslation(ThemeData theme) {
    return FutureBuilder<String>(
      future: _translation,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text(
            'Не удалось перевести слово. Проверьте интернет или настройки ИИ-шлюза.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.error),
          );
        }
        if (!snap.hasData) {
          return const Row(children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text('ИИ переводит слово в контексте…'),
            ),
          ]);
        }
        return Text('→ ${snap.data}', style: theme.textTheme.titleLarge);
      },
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.analysis,
    required this.saved,
    required this.onSave,
  });

  final WordAnalysis analysis;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = analysis;
    final meta = [
      if (a.pos != null) a.pos!,
      if (a.gender != null) 'род: ${a.gender}',
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Базовая форма', style: theme.textTheme.labelMedium),
            Text(a.lemma.isEmpty ? '—' : a.lemma,
                style: theme.textTheme.titleLarge),
            if (a.translation.isNotEmpty) Text('→ ${a.translation}'),
            if (meta.isNotEmpty)
              Text(meta, style: theme.textTheme.bodySmall),
            if (a.caseAnalysis.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Разбор в этом предложении',
                  style: theme.textTheme.labelMedium),
              Text(a.caseAnalysis),
            ],
            if (a.isFalseFriend) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '⚠️ Ложный друг! ${a.falseFriendNote ?? ''}',
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
            if (a.examples.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Как говорят поляки', style: theme.textTheme.labelMedium),
              for (final e in a.examples)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('«${e.pl}»',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (e.tr.isNotEmpty)
                        Text(e.tr, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: saved ? null : onSave,
                icon: Icon(saved ? Icons.check : Icons.bookmark_add),
                label: Text(saved ? 'Сохранено в словарь' : 'Сохранить разбор в словарь'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
