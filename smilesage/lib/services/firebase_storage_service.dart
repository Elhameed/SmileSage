import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_result.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload PDF to Firebase Storage and return the download URL
  static Future<String?> uploadScanReport({
    required ScanResult scanResult,
    required String pdfPath,
    required String userEmail,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Read PDF file
      final pdfFile = File(pdfPath);
      if (!await pdfFile.exists()) {
        throw Exception('PDF file not found');
      }

      final pdfBytes = await pdfFile.readAsBytes();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'scan_reports/${user.uid}/scan_${timestamp}.pdf';

      // Upload to Firebase Storage
      final storageRef = _storage.ref().child(filename);
      final uploadTask = storageRef.putData(
        pdfBytes,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'userEmail': userEmail,
            'condition': scanResult.predictedCondition,
            'confidence': scanResult.confidence.toString(),
            'timestamp': scanResult.timestamp.toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading scan report: $e');
      return null;
    }
  }
}
