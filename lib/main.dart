import 'package:flutter/material.dart';
import 'ble_auto_scan.dart';
import 'ScanRecordPage.dart';
import 'database.dart';

final scanner = BleAutoScanner();

void main() {
  DBHelper.init();
  runApp(const MyApp());
  scanner.start(); // 启动定时扫描
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("BLE Auto Scan")),
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanRecordPage()),
                );
              },
              child: Text("查看扫描记录"),
            ),
          ),
        ),
      ),
    );
  }
}
