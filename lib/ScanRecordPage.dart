import 'package:flutter/material.dart';
import 'ble_auto_scan.dart';
import 'database.dart';

class ScanRecordPage extends StatefulWidget {
  const ScanRecordPage({super.key});
  @override
  _ScanRecordPageState createState() => _ScanRecordPageState();
}

class _ScanRecordPageState extends State<ScanRecordPage> {
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final db = await DBHelper.getDB();
    final result = await db.query(
      "ble_scan_record",
      orderBy: "scanBatch DESC, time DESC",
    );

    setState(() {
      records = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<int, List<Map<String, dynamic>>> grouped = {};

    // 按 scanBatch 分组
    for (var item in records) {
      int batch = item["scanBatch"];
      grouped.putIfAbsent(batch, () => []);
      grouped[batch]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("蓝牙扫描记录"),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              bleScanner.start();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          children: grouped.entries.map((entry) {
            int batch = entry.key;
            List<Map<String, dynamic>> batchRecords = entry.value;

            return ExpansionTile(
              title: Text(
                "第 $batch 次扫描",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(batchRecords.first["time"]),
              children: batchRecords.map((item) {
                return ListTile(
                  leading: Icon(Icons.bluetooth),
                  title: Text(
                    item["name"]?.isNotEmpty == true ? item["name"] : "未知设备",
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("MAC/UUID: ${item["deviceId"]}"),
                      Text("时间: ${item["time"]}"),
                    ],
                  ),
                  trailing: Text(
                    "RSSI\n${item["rssi"]}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
