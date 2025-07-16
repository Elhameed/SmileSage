import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // TODO: Replace with secure storage for production!
  static const String _apiKey = 'AIzaSyAAZIGTY9QdGeZB_N4oyqzjrcazCJ_IrmQ';

  static Future<String> translateText(String text, String targetLang) async {
    final url = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2?key=$_apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'target': targetLang,
        'format': 'text',
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      return text; // fallback to original if translation fails
    }
  }
}
