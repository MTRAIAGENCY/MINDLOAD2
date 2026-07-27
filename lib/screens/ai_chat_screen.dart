import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../providers/loop_provider.dart';

const _suggestedQuestions = [
  'امروز چه کاری مهم است؟',
  'منتظر چه چیزی هستم؟',
  'قبض‌هایم را نشان بده.',
  'پروژه‌هایم را خلاصه کن.',
  'آخرین ایده من چه بود؟',
];

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();
    final loops = context.read<LoopProvider>().all;
    await context.read<ChatProvider>().send(text.trim(), context: loops);
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Text('دستیار', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            child: chat.messages.isEmpty
                ? _EmptyState(onSuggestionTap: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, i) {
                      final m = chat.messages[i];
                      final isUser = m.role == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: isUser ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            m.content,
                            style: TextStyle(
                              color: isUser ? Colors.white : AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (chat.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(chat.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
          if (chat.isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'پیام بنویس...'),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _send(_controller.text),
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  const _EmptyState({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.smart_toy_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'هر چیزی که به ذهنت می‌رسد بپرس',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestedQuestions
                .map(
                  (q) => ActionChip(
                    label: Text(q),
                    backgroundColor: AppColors.surface,
                    side: BorderSide.none,
                    onPressed: () => onSuggestionTap(q),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
