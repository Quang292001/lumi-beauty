import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'core/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tren web, SQLite chay bang WebAssembly va luu vao IndexedDB.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(LumiBeautyApp(apiClient: ApiClient()));
}
