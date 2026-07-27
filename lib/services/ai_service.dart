import 'dart:convert';
import 'package:http/http.dart' as http;
import '../repositories/settings_repository.dart';
import '../models/loop.dart';
import '../models/loop_type.dart';

class AiNotConfiguredException implements Exception {
  final String message = 'سرویس هوش مصنوعی هنوز تنظیم نشده است.';
}

/// نتیجه‌ی استخراج ساختاریافته از متن آزاد فارسی کاربر
class ExtractedLoop {
  final String title;
  final String? description;
  final LoopType type;
  final DateTime? dueDate;
  final String? category;
  final String? project;
  final String? person;
  final String? summary;

  ExtractedLoop({
    required this.title,
    this.description,
    required this.type,
    this.dueDate,
    this.category,
    this.project,
    this.person,
    this.summary,
  });

  factory ExtractedLoop.fromJson(Map<String, dynamic> json) {
    DateTime? due;
    if (json['due_date'] != null && (json['due_date'] as String).isNotEmpty) {
      due = DateTime.tryParse(json['due_date']);
    }
    return ExtractedLoop(
      title: json['title'] ?? 'بدون عنوان',
      description: json['description'],
      type: LoopType.fromString(json['type'] ?? 'task'),
      dueDate: due,
      category: json['category'],
      project: json['project'],
      person: json['person'],
      summary: json['summary'],
    );
  }
}

/// یک پیام ساده برای رابط چت دستیار
class ChatMessage {
  final String role; // user | assistant
  final String content;
  ChatMessage({required this.role, required this.content});
}

class AiService {
  final SettingsRepository _settings = SettingsRepository();

  Future<Map<String, String>> _headers() async {
    final key = await _settings.getApiKey();
    if (key == null || key.isEmpty) throw AiNotConfiguredException();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $key',
    };
  }

  Future<String> _baseUrl() async {
    final url = await _settings.getBaseUrl();
    if (url == null || url.isEmpty) throw AiNotConfiguredException();
    // اطمینان از نبود اسلش اضافه در انتها
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// استخراج ساختاریافته از یک جمله‌ی آزاد فارسی مثل:
  /// "فردا ساعت ۵ برم دکتر"
  Future<ExtractedLoop> extractFromText(String text) async {
    final today = DateTime.now().toIso8601String();
    final systemPrompt = '''
تو دستیار استخراج اطلاعات ساختاریافته از متن فارسی هستی.
امروز میلادی: $today
از متن کاربر این فیلدها را استخراج کن و فقط یک JSON خام برگردان، بدون هیچ توضیح اضافه یا Markdown:
{
  "title": "عنوان کوتاه",
  "description": "توضیح تکمیلی یا خالی",
  "type": "یکی از: task, waiting, idea, reminder, event, knowledge, document, financial, health, home",
  "due_date": "تاریخ و زمان به فرمت ISO8601 میلادی در صورت وجود، وگرنه خالی",
  "category": "یکی از حوزه‌های زندگی به انگلیسی: financial, home, family, health, projects, ideas, documents, knowledge - یا خالی",
  "project": "نام پروژه‌ی مرتبط در صورت وجود",
  "person": "نام شخص مرتبط در صورت وجود (مثلا کسی که منتظر پاسخش هستیم)",
  "summary": "یک جمله‌ی کوتاه و آرام‌بخش به فارسی درباره‌ی این مورد"
}
''';

    final body = jsonEncode({
      'model': await _settings.getModel(),
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': text},
      ],
      'temperature': 0.2,
    });

    final response = await http.post(
      Uri.parse('${await _baseUrl()}/chat/completions'),
      headers: await _headers(),
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('خطا در ارتباط با سرویس هوش مصنوعی (${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final content = decoded['choices'][0]['message']['content'] as String;
    final cleaned = content.replaceAll('```json', '').replaceAll('```', '').trim();
    final json = jsonDecode(cleaned) as Map<String, dynamic>;
    return ExtractedLoop.fromJson(json);
  }

  /// چت آزاد با دستیار — کانتکست فعلیِ Loopهای باز کاربر به عنوان زمینه فرستاده می‌شود
  /// تا دستیار بتواند بر اساس داده‌های واقعی پاسخ دهد (بدون هیچ ابزار خارجی).
  Future<String> chat(List<ChatMessage> history, {required List<Loop> context}) async {
    final contextText = context.isEmpty
        ? 'در حال حاضر هیچ موردی ثبت نشده.'
        : context
            .take(50)
            .map((l) =>
                '- [${l.type.label}] ${l.title}${l.dueDate != null ? " (موعد: ${l.dueDate})" : ""}${l.project != null ? " | پروژه: ${l.project}" : ""}${l.person != null ? " | شخص: ${l.person}" : ""}')
            .join('\n');

    final systemPrompt = '''
تو دستیار ذهنی شخصی کاربر هستی. لحن تو آرام، مختصر و دلگرم‌کننده است.
هرگز کاربر را با تعداد زیاد کارها مضطرب نکن. همیشه فارسی و روان صحبت کن.
این‌ها داده‌های فعلی ثبت‌شده‌ی کاربر است، فقط بر اساس همین‌ها پاسخ بده:
$contextText
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {'role': m.role, 'content': m.content}),
    ];

    final response = await http.post(
      Uri.parse('${await _baseUrl()}/chat/completions'),
      headers: await _headers(),
      body: jsonEncode({
        'model': await _settings.getModel(),
        'messages': messages,
        'temperature': 0.4,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('خطا در ارتباط با سرویس هوش مصنوعی (${response.statusCode})');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded['choices'][0]['message']['content'] as String;
  }

  /// خلاصه‌ی آرام‌بخش روزانه برای کارت هوم — بر پایه‌ی موارد باز واقعی
  Future<String> dailySummary(List<Loop> openLoops, List<Loop> today) async {
    if (openLoops.isEmpty) {
      return 'همه چیز تحت کنترل است. امروز هیچ کار مهمی در انتظار تو نیست.';
    }
    final prompt = '''
بر اساس این لیست، یک خلاصه‌ی خیلی کوتاه (حداکثر دو جمله)، آرام و دلگرم‌کننده به فارسی بنویس.
هرگز عدد کل موارد را ذکر نکن. فقط روی مهم‌ترین نکته تمرکز کن.
موارد باز: ${openLoops.take(20).map((l) => l.title).join('، ')}
موارد امروز: ${today.map((l) => l.title).join('، ')}
''';
    final response = await http.post(
      Uri.parse('${await _baseUrl()}/chat/completions'),
      headers: await _headers(),
      body: jsonEncode({
        'model': await _settings.getModel(),
        'messages': [
          {'role': 'system', 'content': 'تو دستیاری آرام‌بخش هستی که هرگز اضطراب ایجاد نمی‌کند.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.5,
      }),
    );
    if (response.statusCode != 200) {
      return 'امروز روز آرامی است.';
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return (decoded['choices'][0]['message']['content'] as String).trim();
  }
}
