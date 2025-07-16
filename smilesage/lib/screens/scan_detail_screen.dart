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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/translation_service.dart';

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
        title: Text(
          AppLocalizations.of(context)!.scanDetails,
          style: const TextStyle(
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
                      AppLocalizations.of(context)!.confidencePercent(
                        (scanResult.confidence * 100).toStringAsFixed(0),
                      ),
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
            Text(
              AppLocalizations.of(context)!.analysis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 14),
            if (scanResult.explanation != null &&
                scanResult.explanation!.isNotEmpty)
              Builder(
                builder: (context) {
                  final isFrench =
                      Localizations.localeOf(context).languageCode == 'fr';
                  if (!isFrench) {
                    return Text(
                      scanResult.explanation!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: subtitleText,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }
                  return FutureBuilder<String>(
                    future: TranslationService.translateText(
                        scanResult.explanation!, 'fr'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                          scanResult.explanation!,
                          style: const TextStyle(
                            fontSize: 15,
                            color: subtitleText,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: subtitleText,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  );
                },
              ),
            const SizedBox(height: 24),

            // Personalized Tips Section
            Text(
              AppLocalizations.of(context)!.personalizedTips,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 14),
            _buildTip(AppLocalizations.of(context)!.tipBrushTwice),
            const SizedBox(height: 14),
            _buildTip(AppLocalizations.of(context)!.tipFlossDaily),
            const SizedBox(height: 14),
            _buildTip(AppLocalizations.of(context)!.tipDentalCheckup),
            const SizedBox(height: 24),

            // Scan Images Section
            Text(
              AppLocalizations.of(context)!.scanImages,
              style: const TextStyle(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.original,
                          style: const TextStyle(
                            fontSize: 13,
                            color: primaryGreen,
                            fontWeight: FontWeight.w400,
                          )),
                      Text(
                        AppLocalizations.of(context)!.dentalScan,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.gradcam,
                          style: const TextStyle(
                            fontSize: 13,
                            color: primaryGreen,
                            fontWeight: FontWeight.w400,
                          )),
                      Text(
                        AppLocalizations.of(context)!.heatmapOverlay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
                    child: Text(
                      AppLocalizations.of(context)!.downloadPdf,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                                  title: Text(
                                      AppLocalizations.of(context)!.success),
                                  content: Text(AppLocalizations.of(context)!
                                      .scanReportSavedDevice),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                          AppLocalizations.of(context)!.ok),
                                    ),
                                  ],
                                ),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          AppLocalizations.of(context)!
                                              .reportUploadedCloud)),
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
                    child: Text(
                      AppLocalizations.of(context)!.saveToCloud,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
    final loc = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                loc.saveReportToCloud,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.saveReportToCloudQuestion,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.thisWill,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text('• ${loc.storeReportFirebase}'),
                  Text('• ${loc.allowAccessAnyDevice}'),
                  Text('• ${loc.keepDataPrivate}'),
                  const SizedBox(height: 8),
                  Text(
                    loc.deleteDataAnytime,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc.notNow),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CF4A4),
                  ),
                  child: Text(
                    loc.saveToCloud,
                    style: const TextStyle(
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
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(loc.generatingPdf),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String pdfPath) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.pdfGeneratedSuccessfully),
          content: Text(loc.scanReportSavedDevice),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.ok),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(pdfPath);
              },
              child: Text(loc.openPdf),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.error),
          content: Text(loc.failedToGeneratePdf),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.ok),
            ),
          ],
        );
      },
    );
  }

  void _showCloudSuccessDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.success),
          content: Text(loc.scanReportSavedDevice),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.ok),
            ),
          ],
        );
      },
    );
  }

  void _showCloudErrorDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(loc.uploadFailed),
          content: Text(loc.failedToSaveCloud),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(loc.ok),
            ),
          ],
        );
      },
    );
  }
}
