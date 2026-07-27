import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/jalali_utils.dart';
import '../models/loop.dart';
import '../models/loop_type.dart';
import '../providers/loop_provider.dart';
import '../services/file_storage_service.dart';
import '../widgets/add_capture_sheet.dart';
import '../widgets/mental_status_card.dart';
import '../widgets/next_action_card.dart';
import '../widgets/waiting_card.dart';
import '../widgets/schedule_card.dart';
import '../widgets/ai_summary_card.dart';
import 'text_capture_screen.dart';
import 'voice_capture_screen.dart';
import 'life_areas_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _fileStorage = FileStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoopProvider>().load();
    });
  }

  /// از RootScreen صدا زده می‌شود تا باتم‌شیت ثبت باز شود (دکمه‌ی + مشترک)
  void openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddCaptureSheet(
        onText: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TextCaptureScreen())),
        onVoice: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceCaptureScreen())),
        onImage: _captureImage,
        onFile: _captureFile,
      ),
    );
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    final image = picked ?? await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final savedPath = await _fileStorage.saveAttachment(File(image.path), folder: 'images');
    if (!mounted) return;
    await context.read<LoopProvider>().addLoop(
          Loop(
            title: 'تصویر ثبت‌شده',
            type: LoopType.document,
            source: 'image',
            attachments: [savedPath],
          ),
        );
  }

  Future<void> _captureFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);
    final savedPath = await _fileStorage.saveAttachment(file, folder: 'files');
    if (!mounted) return;
    await context.read<LoopProvider>().addLoop(
          Loop(
            title: result.files.single.name,
            type: LoopType.document,
            source: 'file',
            attachments: [savedPath],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoopProvider>();

    return SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.load,
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  children: [
                    _Header(onSettingsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        )),
                    const SizedBox(height: 20),
                    MentalStatusCard(message: provider.mentalStatusMessage),
                    const SizedBox(height: 14),
                    NextActionCard(
                      loop: provider.nextAction,
                      onStart: () {
                        // TODO(v2): بازکردن جزئیات مورد و علامت‌گذاری در حال انجام
                      },
                    ),
                    const SizedBox(height: 14),
                    WaitingCard(
                      items: provider.waitingItems,
                      onViewAll: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LifeAreasScreen()),
                      ),
                    ),
                    if (provider.waitingItems.isNotEmpty) const SizedBox(height: 14),
                    ScheduleCard(items: provider.todayItems),
                    if (provider.todayItems.isNotEmpty) const SizedBox(height: 14),
                    AiSummaryCard(summary: provider.aiSummary),
                    const SizedBox(height: 24),
                    _LifeAreasEntry(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LifeAreasScreen()),
                      ),
                    ),
                  ],
                ),
        ),
      );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onSettingsTap;
  const _Header({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('سلام', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                JalaliUtils.formatFull(DateTime.now()),
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined),
          style: IconButton.styleFrom(backgroundColor: AppColors.surface),
        ),
      ],
    );
  }
}

class _LifeAreasEntry extends StatelessWidget {
  final VoidCallback onTap;
  const _LifeAreasEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.grid_view_rounded, size: 18, color: AppColors.textSecondary),
            SizedBox(width: 8),
            Text('حوزه‌های زندگی', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
