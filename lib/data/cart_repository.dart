import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';
import 'app_database.dart';

/// Abstraction cho gio hang -> Provider khong phu thuoc truc tiep vao SQLite,
/// nho vay viet unit test bang repository gia (in-memory) rat de.
abstract class CartRepository {
  Future<List<CartItem>> getAll();
  Future<void> upsert(CartItem item);
  Future<void> remove(int productId);
  Future<void> clear();
}

class SqfliteCartRepository implements CartRepository {
  SqfliteCartRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  @override
  Future<List<CartItem>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(AppDatabase.cartTable, orderBy: 'added_at DESC');
    return rows.map(CartItem.fromMap).toList();
  }

  @override
  Future<void> upsert(CartItem item) async {
    final db = await _db.database;
    final updated = await db.update(
      AppDatabase.cartTable,
      {'quantity': item.quantity},
      where: 'product_id = ?',
      whereArgs: [item.productId],
    );
    if (updated == 0) {
      await db.insert(
        AppDatabase.cartTable,
        {...item.toMap(), 'added_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> remove(int productId) async {
    final db = await _db.database;
    await db.delete(
      AppDatabase.cartTable,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<void> clear() async {
    final db = await _db.database;
    await db.delete(AppDatabase.cartTable);
  }
}
