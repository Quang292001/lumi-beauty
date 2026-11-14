import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import 'app_database.dart';

abstract class FavoriteRepository {
  Future<List<Product>> getAll();
  Future<void> add(Product product);
  Future<void> remove(int productId);
}

/// Luu ca object Product duoi dang JSON string de mo lai chi tiet ma khong
/// can goi API.
class SqfliteFavoriteRepository implements FavoriteRepository {
  SqfliteFavoriteRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  final AppDatabase _db;

  @override
  Future<List<Product>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.favoriteTable,
      orderBy: 'created_at DESC',
    );
    return rows
        .map((row) => Product.fromJson(
              jsonDecode(row['data'] as String) as Map<String, dynamic>,
            ))
        .toList();
  }

  @override
  Future<void> add(Product product) async {
    final db = await _db.database;
    await db.insert(
      AppDatabase.favoriteTable,
      {
        'product_id': product.id,
        'data': jsonEncode(product.toJson()),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> remove(int productId) async {
    final db = await _db.database;
    await db.delete(
      AppDatabase.favoriteTable,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
