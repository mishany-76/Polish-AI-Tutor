import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ai_client/ai_client.dart';
import '../../core/di/providers.dart';
import '../../core/localization/app_strings.dart';
import '../../core/settings/app_settings.dart';
import '../../core/updater/app_updater_service.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/user_profile.dart';
import '../scanner/translation_service.dart';
import '../guide/user_guide_screen.dart';

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
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(strings.settingsSaved)));
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
    final strings = ref.read(appStringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.cacheClearedSnack(n))),
    );
  }

  Future<void> _checkUpdate() async {
    setState(() => _checkingUpdate = true);
    try {
      final info = await ref.read(appUpdaterProvider).checkForUpdate();
      if (!mounted) return;
      final strings = ref.read(appStringsProvider);
      if (!info.hasUpdate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.alreadyLatestVersion(info.currentVersion)),
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
    final strings = ref.read(appStringsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.new_releases, color: Colors.amber),
            const SizedBox(width: 8),
            Flexible(child: Text(strings.updateAvailable(info.latestVersion))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${strings.currentVersion}: v${info.currentVersion}'),
            Text(
              '${strings.newVersion}: v${info.latestVersion}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (info.releaseNotes.isNotEmpty) ...[
              Text(strings.whatsNew, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: SingleChildScrollView(
                  child: Text(info.releaseNotes, style: const TextStyle(fontSize: 13)),
                ),
              ),
            ] else
              Text(strings.isPl
                  ? 'Dostępna jest nowa wersja z poprawkami i ulepszeniami.'
                  : (strings.isUk
                      ? 'Доступна нова версія з виправленнями та покращеннями.'
                      : 'Доступна новая версия с исправлениями и улучшениями.')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.isPl ? 'Później' : (strings.isUk ? 'Пізніше' : 'Позже')),
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
                      SnackBar(content: Text('Error: $url')),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.download),
            label: Text(strings.downloadApk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strings.uiLangTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<UiLang>(
            segments: const [
              ButtonSegment(value: UiLang.uk, label: Text('🇺🇦 Українська')),
              ButtonSegment(value: UiLang.ru, label: Text('🇷🇺 Русский')),
              ButtonSegment(value: UiLang.pl, label: Text('🇵🇱 Polski')),
            ],
            selected: {lang},
            onSelectionChanged: (s) =>
                ref.read(settingsProvider.notifier).setLang(s.first),
          ),
          const SizedBox(height: 28),
          Text(strings.aiGatewayTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            strings.aiGatewaySub,
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
              labelText: 'Модель (anti/gemini-3.8-flash-high)',
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
                label: Text(strings.saveSettings),
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
                label: Text(_testing ? strings.testingConnection : strings.testConnection),
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
          Text(strings.dataSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.cleaning_services),
            title: Text(strings.clearCacheTitle),
            subtitle: Text(strings.clearCacheSub),
            onTap: _clearCache,
          ),
          const SizedBox(height: 28),
          Text(strings.profileSectionTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final profile = ref.watch(userProfileProvider);
              final goalStr = switch (profile.goal) {
                PolishGoal.daily => strings.onboardingGoalDailyTitle,
                PolishGoal.documents => strings.onboardingGoalDocsTitle,
                PolishGoal.work => strings.onboardingGoalWorkTitle,
                PolishGoal.exam => strings.onboardingGoalExamTitle,
              };
              final levelStr = switch (profile.level) {
                PolishLevel.starter => strings.onboardingLevelStarterTitle,
                PolishLevel.basic => strings.onboardingLevelBasicTitle,
                PolishLevel.intermediate => strings.onboardingLevelInterTitle,
              };

              return Card(
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                AppTheme.primaryCarmine.withValues(alpha: 0.12),
                            child: const Text('🇵🇱', style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${strings.profileLevelLabel} $levelStr · ${strings.profileGoalLabel} $goalStr',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const OnboardingScreen(isRestart: true),
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(strings.profileRestartOnboarding),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(strings.aboutAppTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary),
              ),
              title: Text(
                strings.userGuideTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                strings.userGuideSubtitle,
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () => UserGuideScreen.show(context),
            ),
          ),
          const SizedBox(height: 10),
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
                            ref.watch(currentAppVersionProvider).when(
                                  data: (v) => Text(
                                    strings.versionShort(v),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  loading: () => Text(
                                    strings.versionShort(fallbackAppVersion),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  error: (_, _) => Text(
                                    strings.versionShort(fallbackAppVersion),
                                    style: theme.textTheme.bodySmall,
                                  ),
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
                      label: Text(_checkingUpdate ? strings.checkingUpdates : strings.checkUpdatesBtn),
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

