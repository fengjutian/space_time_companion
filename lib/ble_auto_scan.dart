import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database.dart';

class BleAutoScanner {
  Timer? _timer;
  int scanBatch = 0; // 每次扫描计数
  bool get isRunning => _timer != null;
  bool _scanInProgress = false;
  StreamSubscription<List<ScanResult>>? _sub;

  BleAutoScanner();

  Future<void> start() async {
    if (_timer != null) return;
    final ok = await _ensurePermissions();
    if (!ok) {
      debugPrint("蓝牙/定位权限未授权，无法开始扫描");
      return;
    }
    _ensureSubscription();
    // 每 1 分钟扫描一次
    _timer = Timer.periodic(Duration(seconds: 10), (_) {
      runScan();
    });

    // 立即执行一次
    runScan();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    try {
      FlutterBluePlus.stopScan();
    } catch (_) {}
    _sub?.cancel();
    _sub = null;
  }

  void runScan() async {
    if (_scanInProgress) return;
    _scanInProgress = true;
    scanBatch++;
    debugPrint("开始第 $scanBatch 次扫描");
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    Future.delayed(Duration(seconds: 6), () {
      _scanInProgress = false;
    });
  }

  Future<bool> _ensurePermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      return statuses.values.every((s) => s.isGranted);
    }
    return true;
  }

  void _ensureSubscription() {
    if (_sub != null) return;
    _sub = FlutterBluePlus.scanResults.listen((results) async {
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
