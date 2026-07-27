import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AddCaptureSheet extends StatelessWidget {
  final VoidCallback onText;
  final VoidCallback onVoice;
  final VoidCallback onImage;
  final VoidCallback onFile;

  const AddCaptureSheet({
    super.key,
    required this.onText,
    required this.onVoice,
    required this.onImage,
    required this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 20),
            const Text(
              'الان به چه چیزی فکر می‌کنی؟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _option(context, icon: Icons.edit_note_rounded, label: 'متن', onTap: onText),
                _option(context, icon: Icons.mic_none_rounded, label: 'صدا', onTap: onVoice),
                _option(context, icon: Icons.camera_alt_outlined, label: 'عکس', onTap: onImage),
                _option(context, icon: Icons.attach_file_rounded, label: 'فایل', onTap: onFile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
