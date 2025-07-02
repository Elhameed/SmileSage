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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('Original Image:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navyText)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(scanResult.originalImageBase64),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Grad-CAM Visualization:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navyText)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(scanResult.heatmapImageBase64),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text('Predicted Condition: ${scanResult.predictedCondition}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subtitleText)),
            const SizedBox(height: 8),
            Text(
                'Confidence: ${(scanResult.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: subtitleText)),
            const SizedBox(height: 8),
            Text('Scanned on: ${scanResult.timestamp.toLocal()}'.split('.')[0],
                style: const TextStyle(fontSize: 14, color: subtitleText)),
          ],
        ),
      ),
    );
  }
}
