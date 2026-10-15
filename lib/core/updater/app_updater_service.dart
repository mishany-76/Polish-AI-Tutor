import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class UpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String? downloadUrl;
  final String? htmlUrl;

  const UpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes = '',
    this.downloadUrl,
    this.htmlUrl,
  });
}

const currentAppVersion = "1.0.9";

class AppUpdaterService {
  static const String currentVersion = currentAppVersion;
  static const String _releasesApiUrl =
      'https://api.github.com/repos/mishany-76/Polish-AI-Tutor/releases/latest';

  Future<UpdateInfo> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_releasesApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Polish-AI-Tutor-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawTag = (data['tag_name'] as String? ?? '').trim();
        final cleanTag = rawTag.replaceAll(RegExp(r'^[vV]'), '');
        final body = (data['body'] as String? ?? '').trim();
        final htmlUrl = data['html_url'] as String?;

        String? apkUrl;
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null) {
          for (final asset in assets) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            if (name.endsWith('.apk')) {
              apkUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }

        final downloadTarget = apkUrl ?? htmlUrl;
        final isNewer = _isVersionNewer(cleanTag, currentVersion);

        return UpdateInfo(
          hasUpdate: isNewer,
          currentVersion: currentVersion,
          latestVersion: cleanTag.isNotEmpty ? cleanTag : currentVersion,
          releaseNotes: body,
          downloadUrl: downloadTarget,
          htmlUrl: htmlUrl,
        );
      } else if (response.statusCode == 404) {
        // No releases published yet on this repository
        return const UpdateInfo(
          hasUpdate: false,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          releaseNotes: 'Нові релізи поки відсутні на GitHub.',
        );
      } else {
        throw Exception('GitHub API returned status ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw or handle network errors gracefully
      rethrow;
    }
  }

  static bool _isVersionNewer(String remote, String current) {
    if (remote.isEmpty) return false;
    final rParts = remote.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final cParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = rParts.length > cParts.length ? rParts.length : cParts.length;
    for (int i = 0; i < maxLen; i++) {
      final r = i < rParts.length ? rParts[i] : 0;
      final c = i < cParts.length ? cParts[i] : 0;
      if (r > c) return true;
      if (r < c) return false;
    }
    return false;
  }
}

final appUpdaterProvider = Provider<AppUpdaterService>((ref) {
  return AppUpdaterService();
});

