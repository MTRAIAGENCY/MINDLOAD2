import 'dart:io';
import 'package:http/http.dart' as http;
import '../repositories/settings_repository.dart';
import 'ai_service.dart';

/// تبدیل فایل صوتی ضبط‌شده به متن با استفاده از Whisper API
/// (همان base URL و API Key تنظیم‌شده برای دستیار هوشمند استفاده می‌شود)
class VoiceService {
  final SettingsRepository _settings = SettingsRepository();

  Future<String> transcribe(File audioFile) async {
    final apiKey = await _settings.getApiKey();
    final baseUrl = await _settings.getBaseUrl();
    final model = await _settings.getWhisperModel();

    if (apiKey == null || apiKey.isEmpty || baseUrl == null || baseUrl.isEmpty) {
      throw AiNotConfiguredException();
    }

    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$cleanBaseUrl/audio/transcriptions');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = model
      ..fields['language'] = 'fa'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('خطا در تبدیل صدا به متن (${response.statusCode})');
    }

    final decoded = response.body;
    // پاسخ Whisper به صورت { "text": "..." } است
    final match = RegExp(r'"text"\s*:\s*"((?:[^"\\]|\\.)*)"').firstMatch(decoded);
    if (match != null) {
      return match
          .group(1)!
          .replaceAll(r'\n', '\n')
          .replaceAll(r'\"', '"');
    }
    return decoded;
  }
}
