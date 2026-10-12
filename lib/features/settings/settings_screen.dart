import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/settings/app_settings.dart';
import '../../core/updater/app_updater_service.dart';
import '../scanner/translation_service.dart';

/// Настройки: язык подсказок, блок «ИИ-Шлюз» (OmniRoute/CLIProxy), очистка кэша.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _url;
  late final TextEditingController _key;
  late final TextEditingController _model;
  bool _obscure = true;
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _url = TextEditingController(text: s.baseUrl);
    _key = TextEditingController(text: s.apiKey);
    _model = TextEditingController(text: s.model);
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    _model.dispose();
    super.dispose();
  }

  AppSettings _draft() => ref.read(settingsProvider).copyWith(
        baseUrl: _url.text.trim().isEmpty ? defaultBaseUrl : _url.text.trim(),
        apiKey: _key.text.trim(),
        model: _model.text.trim().isEmpty ? defaultModel : _model.text.trim(),
      );

  Future<void> _save() async {
    await ref.read(settingsProvider.notifier).update(_draft());
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('✅ Настройки сохранены')));
  }

  Future<void> _test() async {
    final d = _draft();
    setState(() {
      _testing = true;
      _testResult = null;
    });
    final client = AiClient(baseUrl: d.baseUrl, apiKey: d.apiKey, model: d.model);
    try {
      final r = await client.chat(
        [const ChatMessage('user', 'Odpowiedz jednym słowem: cześć')],
        timeout: const Duration(seconds: 30),
      );
      if (mounted) {
        setState(() {
          _testOk = true;
          _testResult = 'Шлюз отвечает: «${r.length > 60 ? '${r.substring(0, 60)}…' : r}»';
        });
      }
    } on AiException catch (e) {
      if (mounted) {
        setState(() {
          _testOk = false;
          _testResult = e.message;
        });
      }
    } finally {
      client.close();
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _clearCache() async {
    final n = await ref.read(databaseProvider).clearCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Кэш ИИ очищен (записей: $n)')),
    );
  }

  Future<void> _checkUpdate() async {
    setState(() => _checkingUpdate = true);
    try {
      final info = await ref.read(appUpdaterProvider).checkForUpdate();
      if (!mounted) return;
      if (!info.hasUpdate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ У вас установлена актуальная версия (v${info.currentVersion})'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showUpdateDialog(info);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Ошибка проверки обновлений: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  void _showUpdateDialog(UpdateInfo info) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.new_releases, color: Colors.amber),
            const SizedBox(width: 8),
            Flexible(child: Text('Обновление v${info.latestVersion}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Текущая версия: v${info.currentVersion}'),
            Text(
              'Новая версия: v${info.latestVersion}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (info.releaseNotes.isNotEmpty) ...[
              const Text('Что нового:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(info.releaseNotes, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ] else
              const Text('Доступна новая версия с исправлениями и улучшениями.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Позже'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final url = info.downloadUrl;
              if (url != null && url.isNotEmpty) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Не удалось открыть ссылку: $url')),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Скачать и обновить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    return Scaffold(
      appBar: AppBar(title: const Text('⚙️ Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Язык подсказок', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<UiLang>(
            segments: const [
              ButtonSegment(value: UiLang.uk, label: Text('🇺🇦 Українська')),
              ButtonSegment(value: UiLang.ru, label: Text('🇷🇺 Русский')),
            ],
            selected: {lang},
            onSelectionChanged: (s) =>
                ref.read(settingsProvider.notifier).setLang(s.first),
          ),
          const SizedBox(height: 28),
          Text('ИИ-Шлюз (OpenAI-compatible)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'OmniRoute / CLIProxyAPI. Запросы идут на {Base URL}/chat/completions.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _key,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'API Key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _model,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Модель (можно ввести вручную)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final m in suggestedModels)
                ActionChip(
                  label: Text(m),
                  onPressed: () => setState(() => _model.text = m),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Сохранить'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _testing ? null : _test,
                icon: _testing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: const Text('Проверить'),
              ),
            ),
          ]),
          if (_testResult != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${_testOk ? '✅' : '❌'} $_testResult',
                style: TextStyle(
                  color: _testOk ? Colors.green : theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 28),
          Text('Данные', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Очистить кэш ИИ-разборов'),
            subtitle: const Text('Слова в словаре не удаляются'),
            onTap: _clearCache,
          ),
          const SizedBox(height: 28),
          Text('О приложении и обновления', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.system_update_alt, color: theme.colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Polish AI Tutor',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Версия: v$currentAppVersion',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _checkingUpdate ? null : _checkUpdate,
                      icon: _checkingUpdate
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      label: Text(_checkingUpdate ? 'Проверка...' : '🔄 Проверить обновления'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

