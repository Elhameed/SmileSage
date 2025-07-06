import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import '../models/scan_result.dart';

class PdfService {
  static Future<String?> generateScanReport(ScanResult scanResult) async {
    try {
      // Use Downloads directory for Android, Documents for iOS/other
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await DownloadsPathProvider.downloadsDirectory;
        if (directory == null) {
          // Fallback to app-specific external storage
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        print('Could not resolve a directory for saving PDF.');
        return null;
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            _buildHeader(scanResult),
            pw.SizedBox(height: 20),
            _buildScanResultSection(scanResult),
            pw.SizedBox(height: 20),
            _buildAnalysisSection(scanResult),
            pw.SizedBox(height: 20),
            _buildTipsSection(),
            pw.SizedBox(height: 20),
            _buildImagesSection(scanResult),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      );

      // Generate filename with timestamp
      final timestamp = scanResult.timestamp.toIso8601String().split('T')[0];
      final filename =
          'SmileSage_Scan_${timestamp}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$filename');

      // Save PDF
      await file.writeAsBytes(await pdf.save());
      print('PDF saved to: ${file.path}');
      return file.path;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  static pw.Widget _buildHeader(ScanResult scanResult) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SmileSage',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Dental Health Report',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              child: pw.Text(
                'Scan Report',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Text(
          'Generated on: ${DateTime.now().toString().split('.')[0]}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildScanResultSection(ScanResult scanResult) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Scan Results',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '🦷',
                    style: pw.TextStyle(fontSize: 20),
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      scanResult.predictedCondition,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Confidence: ${(scanResult.confidence * 100).toStringAsFixed(0)}%',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.green700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAnalysisSection(ScanResult scanResult) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Analysis',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Text(
            'The scan indicates signs of ${scanResult.predictedCondition.toLowerCase()}' +
                (scanResult.explanation != null &&
                        scanResult.explanation!.isNotEmpty
                    ? ', ${scanResult.explanation!}'
                    : '.'),
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey800,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTipsSection() {
    final tips = [
      'Brush twice daily with fluoride toothpaste.',
      'Floss daily to remove plaque between teeth.',
      'Schedule a dental check-up within the next month.',
      'Limit sugary foods and drinks.',
      'Use mouthwash as recommended by your dentist.',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Personalized Tips',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        ...tips.map((tip) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '• ',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.green600,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      tip,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  static pw.Widget _buildImagesSection(ScanResult scanResult) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Scan Images',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Original Dental Scan',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    height: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Image(
                      pw.MemoryImage(
                          base64Decode(scanResult.originalImageBase64)),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Grad-CAM Heatmap Overlay',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    height: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Image(
                      pw.MemoryImage(
                          base64Decode(scanResult.heatmapImageBase64)),
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Important Notice',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.red700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report is generated by SmileSage AI and should not replace professional dental consultation. '
            'Please consult with a qualified dentist for proper diagnosis and treatment.',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
}
