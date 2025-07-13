import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  static const String _pdfStorageConsentKey = 'pdf_storage_consent';
  static const String _dataSharingConsentKey = 'data_sharing_consent';

  /// Check if user has consented to PDF storage
  static Future<bool> hasPdfStorageConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pdfStorageConsentKey) ?? false;
  }

  /// Set PDF storage consent
  static Future<void> setPdfStorageConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pdfStorageConsentKey, consent);
  }

  /// Check if user has consented to data sharing
  static Future<bool> hasDataSharingConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dataSharingConsentKey) ?? false;
  }

  /// Set data sharing consent
  static Future<void> setDataSharingConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataSharingConsentKey, consent);
  }

  /// Reset all consents (useful for testing or user logout)
  static Future<void> resetAllConsents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pdfStorageConsentKey);
    await prefs.remove(_dataSharingConsentKey);
  }

  /// Get consent status for all features
  static Future<Map<String, bool>> getAllConsentStatus() async {
    return {
      'pdfStorage': await hasPdfStorageConsent(),
      'dataSharing': await hasDataSharingConsent(),
    };
  }
}
