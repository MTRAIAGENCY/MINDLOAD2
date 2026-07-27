import 'package:shamsi_date/shamsi_date.dart';

class JalaliUtils {
  JalaliUtils._();

  static const _weekDays = [
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  static const _months = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  /// مثل: «دوشنبه ۵ مرداد ۱۴۰۴»
  static String formatFull(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${_weekDays[j.weekDay - 1]} ${toPersianDigits(j.day)} ${_months[j.month - 1]} ${toPersianDigits(j.year)}';
  }

  /// مثل: «۵ مرداد»
  static String formatShort(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${toPersianDigits(j.day)} ${_months[j.month - 1]}';
  }

  /// مثل: «۱۴:۳۰»
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return toPersianDigits('$hour:$minute');
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static String toPersianDigits(dynamic input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var text = input.toString();
    for (var i = 0; i < western.length; i++) {
      text = text.replaceAll(western[i], persian[i]);
    }
    return text;
  }
}
