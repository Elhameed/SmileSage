import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/scan_result.dart';
import '../services/pdf_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/consent_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:open_file/open_file.dart';

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
    const linkText = Color(0xFFF0F5F2);
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
                  child: Icon(MdiIcons.toothOutline, size: 32, color: navyText),
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
            const SizedBox(height: 14),
            if (scanResult.explanation != null &&
                scanResult.explanation!.isNotEmpty)
              Text(
                scanResult.explanation!,
                style: const TextStyle(
                  fontSize: 15,
                  color: subtitleText,
                  fontWeight: FontWeight.w400,
                ),
              ),
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
            const SizedBox(height: 14),
            _buildTip('Brush twice daily with fluoride toothpaste.'),
            const SizedBox(height: 14),
            _buildTip('Floss daily to remove plaque between teeth.'),
            const SizedBox(height: 14),
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
            // First pair: Original Dental Scan
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Original',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryGreen,
                          fontWeight: FontWeight.w400,
                        )),
                    const Text('Dental Scan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        )),
                  ],
                ),
                const SizedBox(width: 56),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    base64Decode(scanResult.originalImageBase64),
                    width: 120,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Second pair: Grad-CAM Heatmap Overlay
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grad-CAM',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryGreen,
                          fontWeight: FontWeight.w400,
                        )),
                    const Text('Heatmap Overlay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        )),
                  ],
                ),
                const SizedBox(width: 56),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    base64Decode(scanResult.heatmapImageBase64),
                    width: 120,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      _showLoadingDialog(context);
                      final pdfPath =
                          await PdfService.generateScanReport(scanResult);
                      navigator.pop(); // Close loading dialog

                      if (pdfPath != null) {
                        _showSuccessDialog(context, pdfPath);
                      } else {
                        _showErrorDialog(context);
                      }
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
                        color: Colors.black, // changed from white to black
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
                  child: ElevatedButton(
                    onPressed: () async {
                      final hasConsent =
                          await ConsentService.hasPdfStorageConsent();
                      if (!hasConsent) {
                        final consented =
                            await _showPdfStorageConsentDialog(context);
                        if (consented) {
                          await ConsentService.setPdfStorageConsent(true);
                        } else {
                          return;
                        }
                      }

                      final navigator = Navigator.of(context);
                      _showLoadingDialog(context);
                      final pdfPath =
                          await PdfService.generateScanReport(scanResult);
                      navigator.pop(); // Close loading dialog

                      if (pdfPath != null) {
                        final userEmail = AuthService().currentUser?.email;
                        if (userEmail != null) {
                          final uploadUrl =
                              await FirebaseStorageService.uploadScanReport(
                            scanResult: scanResult,
                            pdfPath: pdfPath,
                            userEmail: userEmail,
                          );

                          if (uploadUrl != null) {
                            await ProfileService()
                                .saveScanMetadataToCloud(scanResult);
                            if (context.mounted) {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Success'),
                                  content: const Text(
                                      'Your scan report has been saved to your secure cloud storage. You can access it from any device.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Report uploaded to cloud!')),
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              _showCloudErrorDialog(context);
                            }
                          }
                        } else {
                          if (context.mounted) {
                            _showCloudErrorDialog(context);
                          }
                        }
                      } else {
                        _showErrorDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFE8F2E8), // changed from 0xFF0A244E
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save to Cloud',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // ensure text is black
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
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child:
              Icon(Icons.tips_and_updates, color: Color(0xFF7CF4A4), size: 22),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Color(0xFF3A3A3A)),
          ),
        ),
      ],
    );
  }

  // Helper methods for consent dialogs
  Future<bool> _showPdfStorageConsentDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Save Report to Cloud',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Would you like to save this scan report to your secure cloud storage?',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'This will:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('• Store your report securely in Firebase'),
                  Text('• Allow you to access it from any device'),
                  Text('• Keep your data private and encrypted'),
                  SizedBox(height: 8),
                  Text(
                    'You can delete this data anytime from your profile settings.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not Now'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CF4A4),
                  ),
                  child: const Text(
                    'Save to Cloud',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Helper methods for PDF download dialogs
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Text('Generating PDF...'),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String pdfPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF Generated Successfully'),
          content:
              const Text('Your scan report has been saved to your device.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(pdfPath);
              },
              child: const Text('Open PDF'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Failed to generate PDF. Please check your storage permissions and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showCloudSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text(
              'Your scan report has been saved to your secure cloud storage. You can access it from any device.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showCloudErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Failed'),
          content: const Text(
              'Failed to save report to cloud storage. Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
