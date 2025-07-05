import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/scan_result.dart';

class ScanDetailScreen extends StatelessWidget {
  static const routeName = '/scan-detail';
  final ScanResult scanResult;

  const ScanDetailScreen({Key? key, required this.scanResult})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const navyText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF3A3A3A);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightGrayFill = Color(0xFFF6F6F6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Scan Details',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scan Result Section
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: lightGrayFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.medical_services_outlined,
                      size: 32, color: navyText),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scanResult.predictedCondition,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: navyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Confidence: ${(scanResult.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Analysis Section
            const Text(
              'Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 8),
            if (scanResult.predictedCondition.isNotEmpty)
              Text(
                'The scan indicates signs of ${scanResult.predictedCondition.toLowerCase()}.',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: subtitleText,
                ),
              ),
            if (scanResult.explanation != null &&
                scanResult.explanation!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                scanResult.explanation!,
                style: const TextStyle(
                  fontSize: 15,
                  color: subtitleText,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Personalized Tips Section
            const Text(
              'Personalized Tips',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 8),
            _buildTip('Brush twice daily with fluoride toothpaste.'),
            _buildTip('Floss daily to remove plaque between teeth.'),
            _buildTip('Schedule a dental check-up within the next month.'),
            const SizedBox(height: 24),

            // Scan Images Section
            const Text(
              'Scan Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Original',
                          style: TextStyle(fontSize: 13, color: subtitleText)),
                      const Text('Dental Scan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: navyText)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(scanResult.originalImageBase64),
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Grad-CAM',
                          style: TextStyle(fontSize: 13, color: subtitleText)),
                      const Text('Heatmap Overlay',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: navyText)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(scanResult.heatmapImageBase64),
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement PDF download
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Download PDF',
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement share via email
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: navyText, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Share via Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: navyText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper widget for tips
  Widget _buildTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: false, onChanged: null),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Color(0xFF3A3A3A)),
            ),
          ),
        ),
      ],
    );
  }
}
