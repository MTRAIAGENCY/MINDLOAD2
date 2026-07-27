import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'loop_type.dart';

const _uuid = Uuid();

/// واحد پایه‌ی داده در سراسر اپ.
/// هر Task، Waiting، Idea، Event، سند مالی و ... یک نمونه از Loop است.
class Loop {
  final String id;
  final String title;
  final String? description;
  final LoopType type;
  final LoopStatus status;
  final String? category; // مثلا: حوزه‌ی زندگی مرتبط (LifeArea.name)
  final String? project;
  final String? person; // شخص مرتبط (مثلا در انتظار پاسخ چه کسی)
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? aiSummary;
  final String source; // text | voice | image | file | manual
  final List<String> attachments; // مسیرهای فایل محلی
  final Map<String, dynamic> metadata; // فیلدهای اختصاصی هر نوع (مبلغ، مکان و ...)

  Loop({
    String? id,
    required this.title,
    this.description,
    required this.type,
    this.status = LoopStatus.open,
    this.category,
    this.project,
    this.person,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.aiSummary,
    this.source = 'manual',
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        attachments = attachments ?? const [],
        metadata = metadata ?? const {};

  Loop copyWith({
    String? title,
    String? description,
    LoopType? type,
    LoopStatus? status,
    String? category,
    String? project,
    String? person,
    DateTime? dueDate,
    DateTime? updatedAt,
    String? aiSummary,
    String? source,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
  }) {
    return Loop(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      project: project ?? this.project,
      person: person ?? this.person,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      aiSummary: aiSummary ?? this.aiSummary,
      source: source ?? this.source,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'category': category,
      'project': project,
      'person': person,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ai_summary': aiSummary,
      'source': source,
      'attachments': jsonEncode(attachments),
      'metadata': jsonEncode(metadata),
    };
  }

  factory Loop.fromMap(Map<String, dynamic> map) {
    return Loop(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      type: LoopType.fromString(map['type'] as String),
      status: LoopStatus.fromString(map['status'] as String),
      category: map['category'] as String?,
      project: map['project'] as String?,
      person: map['person'] as String?,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      aiSummary: map['ai_summary'] as String?,
      source: map['source'] as String? ?? 'manual',
      attachments: map['attachments'] != null
          ? List<String>.from(jsonDecode(map['attachments'] as String))
          : const [],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(jsonDecode(map['metadata'] as String))
          : const {},
    );
  }
}
