import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ذخیره‌ی امن تنظیمات کاربر — فقط برای اطلاعات اتصال به AI.
/// از FlutterSecureStorage استفاده می‌شود (Keystore روی اندروید)
/// تا API Key هرگز به صورت متن ساده روی دیسک ذخیره نشود.
class SettingsRepository {
  static const _storage = FlutterSecureStorage();

  static const _keyApiKey = 'ai_api_key';
  static const _keyBaseUrl = 'ai_base_url';
  static const _keyModel = 'ai_model';
  static const _keyWhisperModel = 'whisper_model';

  Future<String?> getApiKey() => _storage.read(key: _keyApiKey);
  Future<void> setApiKey(String value) => _storage.write(key: _keyApiKey, value: value);

  Future<String?> getBaseUrl() => _storage.read(key: _keyBaseUrl);
  Future<void> setBaseUrl(String value) => _storage.write(key: _keyBaseUrl, value: value);

  Future<String> getModel() async =>
      await _storage.read(key: _keyModel) ?? 'gpt-4o-mini';
  Future<void> setModel(String value) => _storage.write(key: _keyModel, value: value);

  Future<String> getWhisperModel() async =>
      await _storage.read(key: _keyWhisperModel) ?? 'whisper-1';
  Future<void> setWhisperModel(String value) =>
      _storage.write(key: _keyWhisperModel, value: value);

  Future<bool> isConfigured() async {
    final key = await getApiKey();
    final url = await getBaseUrl();
    return key != null && key.isNotEmpty && url != null && url.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyApiKey);
    await _storage.delete(key: _keyBaseUrl);
  }
}
