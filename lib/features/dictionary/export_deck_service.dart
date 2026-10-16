import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/db/app_database.dart';
import '../../core/localization/app_strings.dart';

enum ExportFormat {
  ankiTsv, // Tab-separated with #tags: polish, transcription, translation, example, note, tags
  quizletCsv, // Comma-separated: polish, translation
  standardCsv, // Full CSV: Front, Back, Context, Notes, PartOfSpeech, Gender, Status
}

class ExportResult {
  final int wordsCount;
  final String filePath;
  final String fileName;
  final ExportFormat format;

  const ExportResult({
    required this.wordsCount,
    required this.filePath,
    required this.fileName,
    required this.format,
  });
}

class ExportDeckService {
  const ExportDeckService();

  /// Формирует TSV-файл для Anki с поддержкой HTML-форматирования и тегов.
  /// Anki импортирует файлы с разделителем Tab и заголовками полей.
  String generateAnkiTsv(List<Word> words, {required bool isUk}) {
    final buffer = StringBuffer();
    // Служебная строка-подсказка для Anki:
    buffer.writeln('#separator:tab');
    buffer.writeln('#html:true');
    buffer.writeln('#tags column:7');
    buffer.writeln(
        '#Front\tBack\tPartOfSpeech\tExample\tNotes\tInterval\tTags');

    for (final w in words) {
      final front = _escapeTsv(w.lemma);
      final translation = _escapeTsv(w.translation(isUk) ?? '');
      final posGender = _escapeTsv([
        if (w.pos != null && w.pos!.isNotEmpty) w.pos!,
        if (w.gender != null && w.gender!.isNotEmpty) '(${w.gender})',
      ].join(' '));

      final example = _escapeTsv(
        [
          if (w.examplePl != null && w.examplePl!.isNotEmpty)
            '<b>${w.examplePl}</b>',
          if (w.exampleTr != null && w.exampleTr!.isNotEmpty)
            '<i>${w.exampleTr}</i>',
        ].join('<br>'),
      );

      final notes = _escapeTsv(
        [
          if (w.isFalseFriend) '⚠️ <b>Fałszywy przyjaciel / Ложный друг</b>',
          if (w.note != null && w.note!.isNotEmpty) w.note!,
        ].join('<br>'),
      );

      final interval = '${w.intervalDays}d';
      final statusTag = switch (w.status) {
        WordStatus.fresh => 'nowe',
        WordStatus.learning => 'nauka',
        WordStatus.mastered => 'opanowane',
      };
      final tags = 'PolishAI $statusTag ${w.source}';

      buffer.writeln(
          '$front\t$translation\t$posGender\t$example\t$notes\t$interval\t$tags');
    }

    return buffer.toString();
  }

  /// Формирует CSV-файл для импорта в Quizlet (Термин, Определение).
  String generateQuizletCsv(List<Word> words, {required bool isUk}) {
    final buffer = StringBuffer();
    for (final w in words) {
      final term = w.lemma.replaceAll('"', '""');
      final tr = (w.translation(isUk) ?? '').replaceAll('"', '""');
      final extra = [
        if (w.pos != null) '[${w.pos}]',
        if (w.examplePl != null) '(${w.examplePl})',
      ].join(' ');

      final def = extra.isNotEmpty ? '$tr $extra'.trim() : tr;
      buffer.writeln('"$term","$def"');
    }
    return buffer.toString();
  }

  /// Стандартный CSV с полными полями (RFC 4180).
  String generateStandardCsv(List<Word> words, {required bool isUk}) {
    final buffer = StringBuffer();
    buffer.writeln(
        '"Słowo (PL)","Tłumaczenie","Część mowy","Rodzaj","Przykład (PL)","Przykład (Tłumaczenie)","Notatka","Fałszywy przyjaciel","Status","Interwał (dni)"');

    for (final w in words) {
      final status = switch (w.status) {
        WordStatus.fresh => 'Nowe',
        WordStatus.learning => 'W trakcie',
        WordStatus.mastered => 'Opanowane',
      };

      final fields = [
        w.lemma,
        w.translation(isUk) ?? '',
        w.pos ?? '',
        w.gender ?? '',
        w.examplePl ?? '',
        w.exampleTr ?? '',
        w.note ?? '',
        w.isFalseFriend ? 'Tak' : 'Nie',
        status,
        w.intervalDays.toString(),
      ];

      final escaped = fields.map((f) => '"${f.replaceAll('"', '""')}"').join(',');
      buffer.writeln(escaped);
    }

    return buffer.toString();
  }

  /// Экспортирует слова во временный файл и возвращает путь для отправки.
  Future<ExportResult> exportToFile({
    required List<Word> words,
    required ExportFormat format,
    required bool isUk,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final (ext, content, prefix) = switch (format) {
      ExportFormat.ankiTsv => (
          'txt',
          generateAnkiTsv(words, isUk: isUk),
          'Polish_AI_Anki_Deck'
        ),
      ExportFormat.quizletCsv => (
          'csv',
          generateQuizletCsv(words, isUk: isUk),
          'Polish_AI_Quizlet_Deck'
        ),
      ExportFormat.standardCsv => (
          'csv',
          generateStandardCsv(words, isUk: isUk),
          'Polish_AI_Dictionary'
        ),
    };

    final fileName = '${prefix}_$dateStr.$ext';
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    // Записываем с BOM UTF-8 для гарантированного распознавания в Excel/Windows
    final utf8WithBom = [0xEF, 0xBB, 0xBF, ...content.codeUnits];
    await file.writeAsBytes(utf8WithBom);

    return ExportResult(
      wordsCount: words.length,
      filePath: file.path,
      fileName: fileName,
      format: format,
    );
  }

  /// Открывает системное окно шеринга (Telegram, Google Drive, AnkiDroid, Почта и т.д.)
  Future<ShareResult> shareExportedFile({
    required ExportResult result,
    required AppStrings strings,
  }) async {
    final xFile = XFile(
      result.filePath,
      name: result.fileName,
      mimeType: result.fileName.endsWith('.txt') ? 'text/plain' : 'text/csv',
    );

    final subject = strings.isPl
        ? 'Talia Polish AI Tutor (${result.wordsCount} słów)'
        : (strings.isUk
            ? 'Колода Polish AI Tutor (${result.wordsCount} слів)'
            : 'Колода Polish AI Tutor (${result.wordsCount} слов)');

    final text = strings.isPl
        ? 'Eksport talii z aplikacji Polish AI Tutor do Anki / Quizlet. Liczba słów: ${result.wordsCount}.'
        : (strings.isUk
            ? 'Експорт колоди з додатку Polish AI Tutor до Anki / Quizlet. Кількість слів: ${result.wordsCount}.'
            : 'Экспорт колоды из приложения Polish AI Tutor в Anki / Quizlet. Количество слов: ${result.wordsCount}.');

    return SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: subject,
        text: text,
      ),
    );
  }

  String _escapeTsv(String s) {
    return s
        .replaceAll('\t', ' ')
        .replaceAll('\r', '')
        .replaceAll('\n', '<br>');
  }
}
