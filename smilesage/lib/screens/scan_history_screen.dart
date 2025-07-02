import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';
import 'scan_detail_screen.dart';

class ScanHistoryScreen extends StatefulWidget {
  static const routeName = '/scan-history';
  const ScanHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  late Future<List<ScanResult>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadScanHistory();
  }

  Future<List<ScanResult>> _loadScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('scan_history') ?? [];
    return historyList
        .map((item) => ScanResult.fromJson(jsonDecode(item)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> _deleteScan(ScanResult target) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('scan_history') ?? [];

    final updatedList = historyList
        .where((item) {
          final decoded = ScanResult.fromJson(jsonDecode(item));
          return decoded.timestamp != target.timestamp;
        })
        .map((e) => e)
        .toList();

    await prefs.setStringList('scan_history', updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: FutureBuilder<List<ScanResult>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scan history yet.'));
          }

          final scans = snapshot.data!;

          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];

              return Dismissible(
                key: ValueKey(scan.timestamp.toIso8601String()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await _deleteScan(scan);
                  setState(() {
                    _historyFuture = _loadScanHistory();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan deleted')),
                  );
                },
                child: ListTile(
                  leading: Image.memory(
                    base64Decode(scan.originalImageBase64),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                  title: Text(scan.predictedCondition),
                  subtitle: Text(
                    '${scan.confidence.toStringAsFixed(2)} confidence\n${scan.timestamp.toLocal()}'
                        .split('.')[0],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanDetailScreen(scanResult: scan),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
