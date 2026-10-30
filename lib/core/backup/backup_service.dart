import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../achievements/achievement_service.dart';
import '../db/app_database.dart';

class BackupResult {
  final bool success;
  final int wordsCount;
  final int preferencesCount;
  final String? message;
  final String? filePath;

  const BackupResult({
    required this.success,
    required this.wordsCount,
    required this.preferencesCount,
    this.message,
    this.filePath,
  });
}

class BackupService {
  const BackupService();

  static Map<String, dynamic> wordToMap(Word w) => {
        'lemma': w.lemma,
        'surfaceForm': w.surfaceForm,
        'pos': w.pos,
        'gender': w.gender,
        'translationUk': w.translationUk,
        'translationRu': w.translationRu,
        'examplePl': w.examplePl,
        'exampleTr': w.exampleTr,
        'note': w.note,
        'isFalseFriend': w.isFalseFriend,
        'source': w.source,
        'createdAt': w.createdAt.toIso8601String(),
        'easeFactor': w.easeFactor,
        'intervalDays': w.intervalDays,
        'reps': w.reps,
        'lapses': w.lapses,
        'dueAt': w.dueAt.toIso8601String(),
        'lastReviewAt': w.lastReviewAt?.toIso8601String(),
      };

  static Word mapToWord(Map<String, dynamic> m) => Word(
        id: 0,
        lemma: m['lemma'] as String,
        surfaceForm: m['surfaceForm'] as String?,
        pos: m['pos'] as String?,
        gender: m['gender'] as String?,
        translationUk: m['translationUk'] as String?,
        translationRu: m['translationRu'] as String?,
        examplePl: m['examplePl'] as String?,
        exampleTr: m['exampleTr'] as String?,
        note: m['note'] as String?,
        isFalseFriend: (m['isFalseFriend'] as bool?) ?? false,
        source: (m['source'] as String?) ?? 'backup',
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        easeFactor: (m['easeFactor'] as num?)?.toDouble() ?? 2.5,
        intervalDays: (m['intervalDays'] as num?)?.toInt() ?? 0,
        reps: (m['reps'] as num?)?.toInt() ?? 0,
        lapses: (m['lapses'] as num?)?.toInt() ?? 0,
        dueAt: m['dueAt'] != null
            ? DateTime.tryParse(m['dueAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        lastReviewAt: m['lastReviewAt'] != null
            ? DateTime.tryParse(m['lastReviewAt'] as String)
            : null,
      );

  /// Экспорт полной резервной копии данных приложения в JSON-файл и вызов шеринга
  Future<BackupResult> exportBackup({
    required AppDatabase db,
    String appVersion = '1.5.3',
  }) async {
    final words = await db.allWords();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final Map<String, dynamic> prefMap = {};
    for (final k in keys) {
      final val = prefs.get(k);
      if (val != null) {
        prefMap[k] = val;
      }
    }

    final backupPayload = {
      'format': 'polish_ai_tutor_backup',
      'version': 1,
      'app_version': appVersion,
      'export_date': DateTime.now().toIso8601String(),
      'words_count': words.length,
      'words': words.map(wordToMap).toList(),
      'preferences': prefMap,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupPayload);

    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final fileName = 'polish_ai_tutor_backup_$dateStr.json';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonString, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Резервная копия Polish AI Tutor ($dateStr)',
      ),
    );

    return BackupResult(
      success: true,
      wordsCount: words.length,
      preferencesCount: prefMap.length,
      filePath: file.path,
    );
  }

  /// Импорт и восстановление данных из выбранного JSON-файла
  Future<BackupResult> importBackupFromFile({required AppDatabase db}) async {
    final pickedFiles = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (pickedFiles.isEmpty || pickedFiles.first.path == null) {
      return const BackupResult(
        success: false,
        wordsCount: 0,
        preferencesCount: 0,
        message: 'Файл не выбран',
      );
    }

    final file = File(pickedFiles.first.path!);
    final rawString = await file.readAsString(encoding: utf8);
    final dynamic decoded = jsonDecode(rawString);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Некорректный формат файла резервной копии');
    }

    if (!decoded.containsKey('words') && !decoded.containsKey('preferences')) {
      throw const FormatException('Файл не содержит данных Polish AI Tutor');
    }

    // 1. Восстановление SharedPreferences
    int restoredPrefsCount = 0;
    if (decoded['preferences'] is Map<String, dynamic>) {
      final prefs = await SharedPreferences.getInstance();
      final prefMap = decoded['preferences'] as Map<String, dynamic>;
      for (final entry in prefMap.entries) {
        final k = entry.key;
        final v = entry.value;
        if (v is String) {
          await prefs.setString(k, v);
          restoredPrefsCount++;
        } else if (v is bool) {
          await prefs.setBool(k, v);
          restoredPrefsCount++;
        } else if (v is int) {
          await prefs.setInt(k, v);
          restoredPrefsCount++;
        } else if (v is double) {
          await prefs.setDouble(k, v);
          restoredPrefsCount++;
        } else if (v is List) {
          await prefs.setStringList(k, v.map((e) => e.toString()).toList());
          restoredPrefsCount++;
        }
      }
      AchievementService.changeNotifier.value++;
    }

    // 2. Восстановление базы слов
    int restoredWordsCount = 0;
    if (decoded['words'] is List) {
      final rawList = decoded['words'] as List<dynamic>;
      for (final item in rawList) {
        if (item is Map<String, dynamic> && item['lemma'] is String) {
          final word = mapToWord(item);
          await db.restoreWord(word);
          restoredWordsCount++;
        }
      }
    }

    return BackupResult(
      success: true,
      wordsCount: restoredWordsCount,
      preferencesCount: restoredPrefsCount,
      filePath: file.path,
    );
  }
}
