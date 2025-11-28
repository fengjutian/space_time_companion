import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static bool _inited = false;

  static void init() {
    if (_inited) return;
    _inited = true;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static Future<Database> getDB() async {
    init();
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), "ble_scan.db");
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
        CREATE TABLE ble_scan_record (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          deviceId TEXT,
          rssi INTEGER,
          time TEXT,
          scanBatch INTEGER
        )
        """);
      },
    );
    return _db!;
  }

  static Future<void> insertScan({
    required String name,
    required String deviceId,
    required int rssi,
    required int batch,
  }) async {
    final db = await getDB();
    await db.insert("ble_scan_record", {
      "name": name,
      "deviceId": deviceId,
      "rssi": rssi,
      "time": DateTime.now().toIso8601String(),
      "scanBatch": batch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
