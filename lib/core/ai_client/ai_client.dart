import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatMessage {
  const ChatMessage(this.role, this.content);

  /// system | user | assistant
  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

class AiException implements Exception {
  AiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// OpenAI-compatible клиент (OmniRoute / CLIProxyAPI): POST {baseUrl}/chat/completions.
class AiClient {
  AiClient({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    http.Client? client,
  }) : _http = client ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final String model;
  final http.Client _http;

  Uri get _endpoint {
    final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/chat/completions');
  }

  Future<String> chat(
    List<ChatMessage> messages, {
    double temperature = 0.4,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    if (apiKey.trim().isEmpty) {
      throw AiException('Укажите API-ключ шлюза в разделе «Настройки».');
    }
    final http.Response res;
    try {
      res = await _http
          .post(
            _endpoint,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${apiKey.trim()}',
            },
            body: jsonEncode({
              'model': model.trim(),
              'messages': [for (final m in messages) m.toJson()],
              'temperature': temperature,
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw AiException('Шлюз не ответил вовремя. Попробуйте ещё раз.');
    } on FormatException {
      throw AiException('Некорректный Base URL шлюза.');
    } catch (_) {
      throw AiException('Нет связи со шлюзом. Проверьте интернет и Base URL.');
    }

    final body = utf8.decode(res.bodyBytes);
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw AiException('Шлюз отклонил ключ (${res.statusCode}). Проверьте API-ключ.');
    }
    if (res.statusCode == 429) {
      throw AiException('Лимит запросов исчерпан (429). Подождите или смените модель.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final snippet = body.length > 200 ? '${body.substring(0, 200)}…' : body;
      throw AiException('Ошибка шлюза ${res.statusCode}: $snippet');
    }
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'];
      if (content is String && content.trim().isNotEmpty) return content.trim();
    } catch (_) {}
    throw AiException('Шлюз вернул ответ в неожиданном формате.');
  }

  /// Запрос, ожидающий JSON-объект в ответе.
  Future<Map<String, dynamic>> chatJson(
    List<ChatMessage> messages, {
    double temperature = 0.3,
  }) async {
    final text = await chat(messages, temperature: temperature);
    final obj = extractJson(text);
    if (obj == null) {
      throw AiException('ИИ вернул не-JSON ответ. Попробуйте ещё раз.');
    }
    return obj;
  }

  void close() => _http.close();
}

/// Достаёт первый JSON-объект из текста (с учётом ```json ограждений).
Map<String, dynamic>? extractJson(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final v = jsonDecode(text.substring(start, end + 1));
    return v is Map<String, dynamic> ? v : null;
  } catch (_) {
    return null;
  }
}

