import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// ذخیره‌ی محلی فایل‌های پیوست (عکس، PDF، صدا) در پوشه‌ی مخصوص اپ
class FileStorageService {
  Future<String> saveAttachment(File source, {required String folder}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDir.path, 'mindload_attachments', folder));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(source.path)}';
    final targetPath = p.join(targetDir.path, fileName);
    final saved = await source.copy(targetPath);
    return saved.path;
  }
}
