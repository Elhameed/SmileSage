// lib/screens/scan_history_screen.dart

import 'package:flutter/material.dart';
import 'scan_detail_screen.dart';

class ScanHistoryScreen extends StatelessWidget {
  static const routeName = '/scan-history';
  const ScanHistoryScreen({Key? key}) : super(key: key);

  // Example scan history data
  final List<Map<String, String>> _scans = const [
    {
      'title': 'Scan #1',
      'date': 'July 20, 2024',
      'image': 'assets/images/scan1.png',
    },
    {
      'title': 'Scan #2',
      'date': 'June 15, 2024',
      'image': 'assets/images/scan1.png',
    },
    {
      'title': 'Scan #3',
      'date': 'May 10, 2024',
      'image': 'assets/images/scan1.png',
    },
    {
      'title': 'Scan #4',
      'date': 'April 5, 2024',
      'image': 'assets/images/scan1.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const headingText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Scan History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: _scans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final scan = _scans[i];
          return InkWell(
            onTap: () {
              // TODO: navigate to scan detail
              Navigator.of(context).pushNamed(ScanDetailScreen.routeName);
            },
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    scan['image']!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                // Title & date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan['date']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: subtitleText,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
