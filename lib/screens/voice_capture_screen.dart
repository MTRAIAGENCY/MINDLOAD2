import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../core/theme/app_colors.dart';
import '../providers/loop_provider.dart';
import '../services/voice_service.dart';

class VoiceCaptureScreen extends StatefulWidget {
  const VoiceCaptureScreen({super.key});

  @override
  State<VoiceCaptureScreen> createState() => _VoiceCaptureScreenState();
}

enum _RecState { idle, recording, transcribing, saving }

class _VoiceCaptureScreenState extends State<VoiceCaptureScreen> {
  final _recorder = AudioRecorder();
  final _voiceService = VoiceService();
  _RecState _state = _RecState.idle;
  String? _error;
  String? _recordedPath;

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      setState(() => _error = 'دسترسی به میکروفون داده نشده است.');
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _state = _RecState.recording;
      _recordedPath = path;
      _error = null;
    });
  }

  Future<void> _stopAndProcess() async {
    final path = await _recorder.stop();
    if (path == null) {
      setState(() => _state = _RecState.idle);
      return;
    }
    setState(() => _state = _RecState.transcribing);
    try {
      final text = await _voiceService.transcribe(File(path));
      if (text.trim().isEmpty) {
        setState(() {
          _state = _RecState.idle;
          _error = 'متنی شناسایی نشد. دوباره تلاش کن.';
        });
        return;
      }
      setState(() => _state = _RecState.saving);
      if (!mounted) return;
      await context.read<LoopProvider>().captureText(text, source: 'voice');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _state = _RecState.idle;
        _error = 'تبدیل صدا به متن ممکن نشد. تنظیمات هوش مصنوعی را بررسی کن.';
      });
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _state == _RecState.recording;
    final isBusy = _state == _RecState.transcribing || _state == _RecState.saving;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ثبت صوتی')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: isBusy ? null : (isRecording ? _stopAndProcess : _startRecording),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isRecording ? AppColors.warningSoft : AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: isBusy
                      ? const Padding(
                          padding: EdgeInsets.all(36),
                          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
                        )
                      : Icon(
                          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: isRecording ? AppColors.warning : AppColors.primary,
                          size: 48,
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _state == _RecState.recording
                    ? 'در حال ضبط... برای پایان دوباره لمس کن'
                    : _state == _RecState.transcribing
                        ? 'در حال تبدیل صدا به متن...'
                        : _state == _RecState.saving
                            ? 'در حال ذخیره...'
                            : 'برای شروع ضبط لمس کن',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
