import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/loop_provider.dart';

class TextCaptureScreen extends StatefulWidget {
  const TextCaptureScreen({super.key});

  @override
  State<TextCaptureScreen> createState() => _TextCaptureScreenState();
}

class _TextCaptureScreenState extends State<TextCaptureScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    await context.read<LoopProvider>().captureText(text, source: 'text');
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ثبت فکر')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 17, height: 1.6),
                decoration: const InputDecoration(
                  hintText: 'الان به چه چیزی فکر می‌کنی؟',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('ثبت'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
