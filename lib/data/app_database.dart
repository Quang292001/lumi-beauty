import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton mo database SQLite cua app.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String cartTable = 'cart_items';
  static const String favoriteTable = 'favorites';

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, 'lumi_beauty.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $cartTable (
            product_id INTEGER PRIMARY KEY,
            title      TEXT    NOT NULL,
            thumbnail  TEXT    NOT NULL,
            unit_price INTEGER NOT NULL,
            quantity   INTEGER NOT NULL CHECK (quantity > 0),
            stock      INTEGER NOT NULL,
            added_at   INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $favoriteTable (
            product_id INTEGER PRIMARY KEY,
            data       TEXT    NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}
