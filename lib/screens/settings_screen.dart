import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _whisperController = TextEditingController();
  bool _obscureKey = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final s = context.read<SettingsProvider>();
      await s.load();
      _apiKeyController.text = s.apiKey;
      _baseUrlController.text = s.baseUrl;
      _modelController.text = s.model;
      _whisperController.text = s.whisperModel;
      setState(() {});
    });
  }

  Future<void> _save() async {
    await context.read<SettingsProvider>().save(
          apiKey: _apiKeyController.text,
          baseUrl: _baseUrlController.text,
          model: _modelController.text.isEmpty ? 'gpt-4o-mini' : _modelController.text,
          whisperModel: _whisperController.text.isEmpty ? 'whisper-1' : _whisperController.text,
        );
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تنظیمات هوش مصنوعی')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'آدرس و کلید سرویس هوش مصنوعی سازگار با OpenAI را وارد کن. این اطلاعات فقط روی همین گوشی و به‌صورت رمزنگاری‌شده ذخیره می‌شود.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 24),
          _field(label: 'Base URL', controller: _baseUrlController, hint: 'https://api.openai.com/v1'),
          const SizedBox(height: 16),
          _field(
            label: 'API Key',
            controller: _apiKeyController,
            hint: 'sk-...',
            obscure: _obscureKey,
            suffix: IconButton(
              icon: Icon(_obscureKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscureKey = !_obscureKey),
            ),
          ),
          const SizedBox(height: 16),
          _field(label: 'مدل چت', controller: _modelController, hint: 'gpt-4o-mini'),
          const SizedBox(height: 16),
          _field(label: 'مدل تبدیل صدا (Whisper)', controller: _whisperController, hint: 'whisper-1'),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _save,
            child: Text(_saved ? 'ذخیره شد ✓' : 'ذخیره'),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}
