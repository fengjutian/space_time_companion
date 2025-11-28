import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'database.dart';

class BleAutoScanner {
  Timer? _timer;
  int scanBatch = 0; // 每次扫描计数

  void start() {
    // 每 1 分钟扫描一次
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
      runScan();
    });

    // 立即执行一次
    runScan();
  }

  void stop() {
    _timer?.cancel();
  }

  void runScan() async {
    scanBatch++;
    debugPrint("开始第 $scanBatch 次扫描");

    // 5 秒扫描时间
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (var r in results) {
        await DBHelper.insertScan(
          name: r.device.platformName,
          deviceId: r.device.remoteId.str,
          rssi: r.rssi,
          batch: scanBatch,
        );
      }
    });
  }
}

final BleAutoScanner bleScanner = BleAutoScanner();
