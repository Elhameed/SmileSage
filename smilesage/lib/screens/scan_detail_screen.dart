// lib/screens/scan_detail_screen.dart

import 'package:flutter/material.dart';

class ScanDetailScreen extends StatelessWidget {
  static const routeName = '/scan-detail';
  const ScanDetailScreen({Key? key}) : super(key: key);

  // Sample data – replace with real model results
  final List<Map<String, String>> _conditions = const [
    {'name': 'Gingivitis', 'severity': 'Mild'},
    {'name': 'Plaque Buildup', 'severity': 'Moderate'},
    {'name': 'Tooth Discoloration', 'severity': 'Mild'},
  ];

  final List<String> _images = const [
    'assets/images/scan2.png',
    'assets/images/scan3.png',
  ];

  @override
  Widget build(BuildContext context) {
    const headingText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);
    const iconBg = Color(0xFFE8F4EC);
    const primaryGreen = Color(0xFF7CF4A4);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Scan Report',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detected Conditions
            const Text(
              'Detected Conditions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 16),
            ..._conditions.map((c) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services, // or your tooth icon asset
                        color: headingText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: headingText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c['severity']!,
                            style: TextStyle(fontSize: 14, color: subtitleText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // Scan Images
            const Text(
              'Scan Images',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children:
                  _images.map((img) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              img,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList()
                    // remove extra right padding on last
                    ..removeLast()
                    ..add(
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            _images.last,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Personalized Tips
            const Text(
              'Personalized Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Brush twice a day with fluoride toothpaste. '
              'Floss daily to remove plaque between teeth. '
              'Use an antiseptic mouthwash to reduce bacteria. '
              'Schedule a professional cleaning every six months.',
              style: TextStyle(fontSize: 14, color: headingText),
            ),

            const SizedBox(height: 24),

            // Next Check-up
            const Text(
              'Next Check-up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: headingText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Suggested Date: November 15, 2024',
              style: TextStyle(fontSize: 14, color: headingText),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Download PDF
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: download PDF
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: iconBg,
                      shape: StadiumBorder(),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Download PDF',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: headingText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Share via Email
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: share via email
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Share via Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
