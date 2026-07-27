import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/loop.dart';
import '../models/loop_type.dart';

/// لایه‌ی دسترسی به داده برای Loop.
/// تمام کوئری‌های SQLite اینجا متمرکز هستند تا در آینده،
/// جایگزینی SQLite با Postgres فقط به تغییر همین کلاس محدود شود.
class LoopRepository {
  Future<Database> get _db async => DatabaseHelper.instance.database;

  Future<Loop> create(Loop loop) async {
    final db = await _db;
    await db.insert('loops', loop.toMap());
    return loop;
  }

  Future<void> update(Loop loop) async {
    final db = await _db;
    await db.update(
      'loops',
      loop.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [loop.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('loops', where: 'id = ?', whereArgs: [id]);
  }

  Future<Loop?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('loops', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Loop.fromMap(maps.first);
  }

  Future<List<Loop>> getAll() async {
    final db = await _db;
    final maps = await db.query('loops', orderBy: 'created_at DESC');
    return maps.map(Loop.fromMap).toList();
  }

  Future<List<Loop>> getByType(LoopType type) async {
    final db = await _db;
    final maps = await db.query(
      'loops',
      where: 'type = ? AND status != ?',
      whereArgs: [type.name, LoopStatus.archived.name],
      orderBy: 'created_at DESC',
    );
    return maps.map(Loop.fromMap).toList();
  }

  Future<List<Loop>> getByCategory(String category) async {
    final db = await _db;
    final maps = await db.query(
      'loops',
      where: 'category = ? AND status != ?',
      whereArgs: [category, LoopStatus.archived.name],
      orderBy: 'created_at DESC',
    );
    return maps.map(Loop.fromMap).toList();
  }

  /// موارد "در انتظار" فعال — حداکثر برای نمایش در کارت هوم بعداً محدود می‌شود
  Future<List<Loop>> getWaiting() async {
    final db = await _db;
    final maps = await db.query(
      'loops',
      where: 'type = ? AND status != ?',
      whereArgs: [LoopType.waiting.name, LoopStatus.done.name],
      orderBy: 'created_at DESC',
    );
    return maps.map(Loop.fromMap).toList();
  }

  /// رویدادها و یادآوری‌های امروز (بر اساس تاریخ میلادی ذخیره شده، تبدیل نمایش در UI با jalali انجام می‌شود)
  Future<List<Loop>> getToday() async {
    final db = await _db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    final maps = await db.query(
      'loops',
      where: 'due_date >= ? AND due_date <= ? AND status != ?',
      whereArgs: [startOfDay, endOfDay, LoopStatus.done.name],
      orderBy: 'due_date ASC',
    );
    return maps.map(Loop.fromMap).toList();
  }

  /// همه‌ی موارد باز (برای محاسبه‌ی وضعیت ذهنی و next action)
  Future<List<Loop>> getOpenItems() async {
    final db = await _db;
    final maps = await db.query(
      'loops',
      where: 'status IN (?, ?)',
      whereArgs: [LoopStatus.open.name, LoopStatus.inProgress.name],
      orderBy: 'due_date ASC',
    );
    return maps.map(Loop.fromMap).toList();
  }

  /// جستجوی ساده‌ی محلی (قبل یا در کنار جستجوی هوشمند AI)
  Future<List<Loop>> search(String query) async {
    final db = await _db;
    final maps = await db.query(
      'loops',
      where: 'title LIKE ? OR description LIKE ? OR project LIKE ? OR person LIKE ?',
      whereArgs: List.filled(4, '%$query%'),
      orderBy: 'created_at DESC',
    );
    return maps.map(Loop.fromMap).toList();
  }
}
