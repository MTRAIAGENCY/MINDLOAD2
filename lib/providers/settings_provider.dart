import 'package:flutter/foundation.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo = SettingsRepository();

  String apiKey = '';
  String baseUrl = '';
  String model = 'gpt-4o-mini';
  String whisperModel = 'whisper-1';
  bool isConfigured = false;
  bool isLoading = true;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    apiKey = await _repo.getApiKey() ?? '';
    baseUrl = await _repo.getBaseUrl() ?? '';
    model = await _repo.getModel();
    whisperModel = await _repo.getWhisperModel();
    isConfigured = await _repo.isConfigured();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save({
    required String apiKey,
    required String baseUrl,
    required String model,
    required String whisperModel,
  }) async {
    await _repo.setApiKey(apiKey.trim());
    await _repo.setBaseUrl(baseUrl.trim());
    await _repo.setModel(model.trim());
    await _repo.setWhisperModel(whisperModel.trim());
    await load();
  }
}
