import 'package:flutter/material.dart';
import 'ble_auto_scan.dart';
import 'ScanRecordPage.dart';
import 'database.dart';

void main() {
  DBHelper.init();
  runApp(const MyApp());
  bleScanner.start();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const ScanRecordPage());
  }
}
