import 'package:flutter/foundation.dart';
import '../models/loop.dart';
import '../models/loop_type.dart';
import '../repositories/loop_repository.dart';
import '../services/ai_service.dart';

const _smallNumberWords = {1: 'یک', 2: 'دو', 3: 'سه', 4: 'چهار'};

class LoopProvider extends ChangeNotifier {
  final LoopRepository _repo = LoopRepository();
  final AiService _ai = AiService();

  List<Loop> _all = [];
  bool isLoading = true;
  String? aiSummary;

  List<Loop> get all => _all;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _all = await _repo.getAll();
    isLoading = false;
    notifyListeners();
    _refreshAiSummary();
  }

  Future<void> _refreshAiSummary() async {
    try {
      aiSummary = await _ai.dailySummary(openItems, todayItems);
    } catch (_) {
      aiSummary = null; // اگر AI تنظیم نشده یا خطا داد، کارت خلاصه چیزی نشان نمی‌دهد
    }
    notifyListeners();
  }

  List<Loop> get openItems => _all
      .where((l) => l.status == LoopStatus.open || l.status == LoopStatus.inProgress)
      .toList();

  List<Loop> get waitingItems =>
      _all.where((l) => l.type == LoopType.waiting && l.status != LoopStatus.done).toList();

  List<Loop> get todayItems {
    final now = DateTime.now();
    return _all.where((l) {
      if (l.dueDate == null) return false;
      final d = l.dueDate!;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  /// آیتم‌هایی که "فوری" محسوب می‌شوند: امروز سررسید دارند یا از موعدشان گذشته
  List<Loop> get urgentItems {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return openItems.where((l) => l.dueDate != null && l.dueDate!.isBefore(endOfToday)).toList();
  }

  /// انتخاب قطعی و قابل‌پیش‌بینیِ «تنها اقدام بعدی»:
  /// ۱) نزدیک‌ترین موعد سررسید در بین موارد باز
  /// ۲) در نبود موعد، آخرین موردِ باز از نوع Task که ثبت شده
  Loop? get nextAction {
    final withDue = openItems.where((l) => l.dueDate != null).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    if (withDue.isNotEmpty) return withDue.first;

    final tasks = openItems.where((l) => l.type == LoopType.task).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (tasks.isNotEmpty) return tasks.first;

    return openItems.isNotEmpty ? openItems.first : null;
  }

  /// پیام کارت «وضعیت ذهنی» — همیشه آرام، هرگز عدد بزرگ
  String get mentalStatusMessage {
    final count = urgentItems.length;
    if (count == 0) return 'همه چیز تحت کنترل است.';
    if (count == 1) return 'امروز فقط یک موضوع نیاز به توجه دارد.';
    if (_smallNumberWords.containsKey(count)) {
      return 'امروز فقط ${_smallNumberWords[count]} موضوع نیاز به توجه دارند.';
    }
    return 'امروز چند موضوع نیاز به توجه دارند.';
  }

  Future<void> addLoop(Loop loop) async {
    await _repo.create(loop);
    await load();
  }

  Future<void> updateLoop(Loop loop) async {
    await _repo.update(loop);
    await load();
  }

  Future<void> markDone(Loop loop) async {
    await _repo.update(loop.copyWith(status: LoopStatus.done));
    await load();
  }

  Future<void> deleteLoop(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<List<Loop>> byCategory(String category) => _repo.getByCategory(category);

  Future<List<Loop>> localSearch(String query) => _repo.search(query);

  /// ثبت متن آزاد فارسی و تبدیل خودکار آن به یک Loop ساختاریافته با کمک AI.
  /// در صورت عدم تنظیم AI یا بروز خطا، یک Loop ساده از نوع Task با همان متن ساخته می‌شود
  /// تا داده‌ی کاربر هرگز گم نشود.
  Future<Loop> captureText(String text, {String source = 'text'}) async {
    try {
      final extracted = await _ai.extractFromText(text);
      final loop = Loop(
        title: extracted.title,
        description: extracted.description,
        type: extracted.type,
        dueDate: extracted.dueDate,
        category: extracted.category,
        project: extracted.project,
        person: extracted.person,
        aiSummary: extracted.summary,
        source: source,
      );
      await addLoop(loop);
      return loop;
    } catch (_) {
      final fallback = Loop(title: text, type: LoopType.task, source: source);
      await addLoop(fallback);
      return fallback;
    }
  }
}
