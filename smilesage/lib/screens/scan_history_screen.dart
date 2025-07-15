import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';
import 'scan_detail_screen.dart';
import '../services/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final localScans = historyList
        .map((item) => ScanResult.fromJson(jsonDecode(item)))
        .toList();

    List<ScanResult> cloudScans = [];
    try {
      cloudScans = await ProfileService().fetchCloudScans();
    } catch (e) {
      // If not logged in or offline, ignore
    }

    // Merge, avoiding duplicates (by timestamp)
    final allScans = <String, ScanResult>{};
    for (final scan in [...localScans, ...cloudScans]) {
      allScans[scan.timestamp.toIso8601String()] = scan;
    }
    return allScans.values.toList().reversed.toList();
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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          AppLocalizations.of(context)!.scanHistory,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<ScanResult>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(AppLocalizations.of(context)!
                    .errorWithMessage(snapshot.error.toString())));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(AppLocalizations.of(context)!.noScanHistory));
          }

          final scans = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: scans.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final scan = scans[index];
              final scanNumber = 'Scan #${index + 1}';
              final scanNumberText = AppLocalizations.of(context)!
                  .scanNumber((index + 1).toString());
              final formattedDate = _formatDate(scan.timestamp);

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
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context)!.scanDeleted)),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(scan.originalImageBase64),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      scanNumberText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A8A8A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(scan.timestamp),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFB0B0B0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.black, size: 28),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanDetailScreen(scanResult: scan),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Example: July 20, 2024
    final loc = AppLocalizations.of(context)!;
    final months = [
      loc.monthJanuary,
      loc.monthFebruary,
      loc.monthMarch,
      loc.monthApril,
      loc.monthMay,
      loc.monthJune,
      loc.monthJuly,
      loc.monthAugust,
      loc.monthSeptember,
      loc.monthOctober,
      loc.monthNovember,
      loc.monthDecember,
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    // Example: 02:15 PM
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final loc = AppLocalizations.of(context)!;
    final ampm = hour >= 12 ? loc.pm : loc.am;
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $ampm';
  }
}
