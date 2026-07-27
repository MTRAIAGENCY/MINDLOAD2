import 'package:flutter/material.dart';

/// انواع مختلف "Loop" — واحد پایه‌ی ذخیره‌سازی در این اپ.
/// هر چیزی که کاربر ثبت می‌کند (کار، منتظر، ایده، رویداد و ...) یک Loop است.
enum LoopType {
  task,
  waiting,
  idea,
  reminder,
  event,
  knowledge,
  document,
  financial,
  health,
  home;

  String get label {
    switch (this) {
      case LoopType.task:
        return 'کار';
      case LoopType.waiting:
        return 'در انتظار';
      case LoopType.idea:
        return 'ایده';
      case LoopType.reminder:
        return 'یادآوری';
      case LoopType.event:
        return 'رویداد';
      case LoopType.knowledge:
        return 'دانش';
      case LoopType.document:
        return 'سند';
      case LoopType.financial:
        return 'مالی';
      case LoopType.health:
        return 'سلامت';
      case LoopType.home:
        return 'خانه';
    }
  }

  IconData get icon {
    switch (this) {
      case LoopType.task:
        return Icons.check_circle_outline;
      case LoopType.waiting:
        return Icons.hourglass_empty_rounded;
      case LoopType.idea:
        return Icons.lightbulb_outline;
      case LoopType.reminder:
        return Icons.notifications_none_rounded;
      case LoopType.event:
        return Icons.event_outlined;
      case LoopType.knowledge:
        return Icons.menu_book_outlined;
      case LoopType.document:
        return Icons.description_outlined;
      case LoopType.financial:
        return Icons.account_balance_wallet_outlined;
      case LoopType.health:
        return Icons.favorite_border_rounded;
      case LoopType.home:
        return Icons.home_outlined;
    }
  }

  static LoopType fromString(String value) {
    return LoopType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LoopType.task,
    );
  }
}

/// وضعیت یک Loop
enum LoopStatus {
  open,
  inProgress,
  waiting,
  done,
  archived;

  String get label {
    switch (this) {
      case LoopStatus.open:
        return 'باز';
      case LoopStatus.inProgress:
        return 'در حال انجام';
      case LoopStatus.waiting:
        return 'در انتظار';
      case LoopStatus.done:
        return 'انجام شد';
      case LoopStatus.archived:
        return 'بایگانی شده';
    }
  }

  static LoopStatus fromString(String value) {
    return LoopStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LoopStatus.open,
    );
  }
}

/// حوزه‌ی زندگی (برای گرید Life Areas)
enum LifeArea {
  financial,
  home,
  family,
  health,
  projects,
  ideas,
  documents,
  knowledge;

  String get label {
    switch (this) {
      case LifeArea.financial:
        return 'مالی';
      case LifeArea.home:
        return 'خانه';
      case LifeArea.family:
        return 'خانواده';
      case LifeArea.health:
        return 'سلامت';
      case LifeArea.projects:
        return 'پروژه‌ها';
      case LifeArea.ideas:
        return 'ایده‌ها';
      case LifeArea.documents:
        return 'اسناد';
      case LifeArea.knowledge:
        return 'دانش';
    }
  }

  IconData get icon {
    switch (this) {
      case LifeArea.financial:
        return Icons.account_balance_wallet_outlined;
      case LifeArea.home:
        return Icons.home_outlined;
      case LifeArea.family:
        return Icons.groups_outlined;
      case LifeArea.health:
        return Icons.favorite_border_rounded;
      case LifeArea.projects:
        return Icons.rocket_launch_outlined;
      case LifeArea.ideas:
        return Icons.lightbulb_outline;
      case LifeArea.documents:
        return Icons.description_outlined;
      case LifeArea.knowledge:
        return Icons.menu_book_outlined;
    }
  }
}
