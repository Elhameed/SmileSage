// This file defines the complete scan result model
import 'dart:convert';

class ScanResult {
  final String predictedCondition;
  final double confidence;
  final String originalImageBase64;
  final String heatmapImageBase64;
  final DateTime timestamp;

  ScanResult({
    required this.predictedCondition,
    required this.confidence,
    required this.originalImageBase64,
    required this.heatmapImageBase64,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'predictedCondition': predictedCondition,
        'confidence': confidence,
        'originalImageBase64': originalImageBase64,
        'heatmapImageBase64': heatmapImageBase64,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      predictedCondition: json['predictedCondition'],
      confidence: (json['confidence'] as num).toDouble(),
      originalImageBase64: json['originalImageBase64'],
      heatmapImageBase64: json['heatmapImageBase64'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
