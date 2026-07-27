import 'package:flutter/foundation.dart';
import '../models/loop.dart';
import '../services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final AiService _ai = AiService();
  final List<ChatMessage> messages = [];
  bool isSending = false;
  String? error;

  Future<void> send(String text, {required List<Loop> context}) async {
    messages.add(ChatMessage(role: 'user', content: text));
    isSending = true;
    error = null;
    notifyListeners();

    try {
      final reply = await _ai.chat(messages, context: context);
      messages.add(ChatMessage(role: 'assistant', content: reply));
    } catch (e) {
      error = e is AiNotConfiguredException
          ? e.message
          : 'ارتباط با دستیار برقرار نشد. لطفاً دوباره تلاش کن.';
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void clear() {
    messages.clear();
    error = null;
    notifyListeners();
  }
}
