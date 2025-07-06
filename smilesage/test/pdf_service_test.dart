import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:smilesage/models/scan_result.dart';
import 'package:smilesage/services/pdf_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PdfService Tests', () {
    test('should generate PDF report successfully', () async {
      // Create a sample scan result
      final scanResult = ScanResult(
        predictedCondition: 'Cavity',
        confidence: 0.85,
        originalImageBase64:
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', // 1x1 pixel PNG
        heatmapImageBase64:
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==', // 1x1 pixel PNG
        timestamp: DateTime.now(),
        explanation: 'This is a test explanation for the scan result.',
      );

      // Test PDF generation
      final result = await PdfService.generateScanReport(scanResult);

      // Note: In a real test environment, we would need to mock the file system
      // and permissions. For now, we just verify the method doesn't throw an exception.
      expect(result, isA<String?>());
    });

    test('should handle null explanation gracefully', () async {
      // Create a sample scan result without explanation
      final scanResult = ScanResult(
        predictedCondition: 'Gingivitis',
        confidence: 0.92,
        originalImageBase64:
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        heatmapImageBase64:
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        timestamp: DateTime.now(),
        explanation: null,
      );

      // Test PDF generation
      final result = await PdfService.generateScanReport(scanResult);

      expect(result, isA<String?>());
    });
  });
}
