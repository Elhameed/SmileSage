import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_workflow_screen.dart';
import '../models/scan_result.dart';
import 'dart:async';
import 'chat_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/translation_service.dart';

class GeneralScanScreen extends StatefulWidget {
  static const routeName = '/general-scan';
  const GeneralScanScreen({Key? key}) : super(key: key);

  @override
  State<GeneralScanScreen> createState() => _GeneralScanScreenState();
}

class _GeneralScanScreenState extends State<GeneralScanScreen> {
  int _selectedIndex = 0;
  bool _hasResult = false;
  File? _selectedImage;
  bool _isProcessing = false;

  String? _predictedCondition;
  double? _confidence;
  Map<String, double>? _allPredictions;
  Uint8List? _gradcamBytes;
  ScanResult? _lastScanResult;
  String? _explanation; // For storing the condition explanation
  bool _isFetchingExplanation = false; // Loading state for explanation

  static const String _apiEndpoint =
      "https://teniola04-dental-api.hf.space/predict";
  static const String _explanationEndpoint =
      "https://teniola04-gemini-dental-chat.hf.space/chat"; // Gemini proxy
  static const Duration _apiTimeout = Duration(seconds: 30);

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _hasResult = false;
          _predictedCondition = null;
          _confidence = null;
          _allPredictions = null;
          _gradcamBytes = null;
          _lastScanResult = null;
          _explanation = null; // Reset explanation
        });
      }
    } catch (e) {
      _showSnackBar(
          AppLocalizations.of(context)!.errorSelectingImage(e.toString()));
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _hasResult = false;
          _predictedCondition = null;
          _confidence = null;
          _allPredictions = null;
          _gradcamBytes = null;
          _lastScanResult = null;
          _explanation = null; // Reset explanation
        });
      }
    } catch (e) {
      _showSnackBar(
          AppLocalizations.of(context)!.errorCapturingImage(e.toString()));
    }
  }

  Future<Uint8List> _preprocessImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception('Failed to decode image');

      final resizedImage =
          img.copyResize(originalImage, width: 224, height: 224);
      final rgbImage =
          img.Image(width: resizedImage.width, height: resizedImage.height);
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          rgbImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
        }
      }
      return Uint8List.fromList(img.encodeJpg(rgbImage));
    } catch (e) {
      throw Exception(AppLocalizations.of(context)!.imageProcessingFailed);
    }
  }

  Future<void> _fetchConditionExplanation(String condition) async {
    setState(() {
      _isFetchingExplanation = true;
    });

    // Refined, concise user prompt for all conditions
    String userPrompt;
    String systemPrompt =
        "You are a dental health assistant. When explaining a dental scan result, address the user directly in a friendly, positive, and concise way. In 4–5 sentences, briefly explain the likely causes, common symptoms, and basic care tips for the detected condition. Do not mention that you are an AI.";

    if (condition.toLowerCase() == "ulcer") {
      userPrompt =
          "My dental scan result is: mouth ulcer. Please explain with confidence and clarity what this means, including causes, symptoms, and basic care tips. Do not use uncertain language. Please keep your answer concise, friendly, and supportive.";
      systemPrompt +=
          " For mouth ulcers, explain with certainty and clarity, and avoid uncertain or hedging language.";
    } else if (condition.toLowerCase() == "healthy") {
      userPrompt =
          "My dental scan result is: healthy teeth. Please congratulate me and explain what this means in a personal, positive, and supportive way. Briefly mention what good oral hygiene includes, and keep your answer concise.";
    } else {
      userPrompt =
          "My dental scan result is: $condition. What does this mean for me? Please keep your answer concise in 3-4 sentences.";
    }

    try {
      final response = await http
          .post(
            Uri.parse(_explanationEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "system_prompt": systemPrompt,
              "messages": [
                {"role": "user", "content": userPrompt}
              ]
            }),
          )
          .timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        String explanation = jsonResponse['response'];
        // Translate if needed
        if (Localizations.localeOf(context).languageCode == 'fr') {
          explanation =
              await TranslationService.translateText(explanation, 'fr');
        }
        setState(() {
          _explanation = explanation;
        });
      } else {
        _showSnackBar(AppLocalizations.of(context)!
            .failedToGetExplanation(response.statusCode.toString()));
      }
    } on TimeoutException {
      _showSnackBar(AppLocalizations.of(context)!.explanationRequestTimedOut);
    } catch (e) {
      _showSnackBar(
          AppLocalizations.of(context)!.errorGettingExplanation(e.toString()));
    } finally {
      setState(() {
        _isFetchingExplanation = false;
      });
    }
  }

  Future<void> _saveToHistory(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList('scan_history') ?? [];
    historyList.add(jsonEncode(result.toJson()));
    await prefs.setStringList('scan_history', historyList);
    _showSnackBar(AppLocalizations.of(context)!.resultSavedToHistory);
  }

  void _handleSaveButton() {
    if (_lastScanResult != null) {
      // Create a new ScanResult with explanation included
      final resultWithExplanation = ScanResult(
        predictedCondition: _lastScanResult!.predictedCondition,
        confidence: _lastScanResult!.confidence,
        originalImageBase64: _lastScanResult!.originalImageBase64,
        heatmapImageBase64: _lastScanResult!.heatmapImageBase64,
        timestamp: _lastScanResult!.timestamp,
        explanation: _explanation,
      );
      _saveToHistory(resultWithExplanation);
    } else {
      _showSnackBar(AppLocalizations.of(context)!.noResultToSave);
    }
  }

  Future<void> _runInference() async {
    if (_selectedImage == null) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseSelectImageFirst);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final processedImage = await _preprocessImage(_selectedImage!);

      var request = http.MultipartRequest('POST', Uri.parse(_apiEndpoint))
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          processedImage,
          filename: 'dental_scan.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));

      var response = await request.send().timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        final scanResult = ScanResult(
          predictedCondition: jsonResponse['condition'],
          confidence: (jsonResponse['confidence'] as num).toDouble(),
          originalImageBase64:
              base64Encode(await _selectedImage!.readAsBytes()),
          heatmapImageBase64: jsonResponse['heatmap_base64'],
          timestamp: DateTime.now(),
        );

        setState(() {
          _predictedCondition = scanResult.predictedCondition;
          _confidence = scanResult.confidence;
          _allPredictions = (jsonResponse['all_predictions']
                  as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, (value as num).toDouble()));
          _gradcamBytes = base64Decode(scanResult.heatmapImageBase64);
          _lastScanResult = scanResult;
          _hasResult = true;
        });

        // Fetch explanation for the predicted condition
        _fetchConditionExplanation(_predictedCondition!);
      } else {
        final errorBody = await response.stream.bytesToString();
        _showSnackBar(AppLocalizations.of(context)!.apiError(
            response.statusCode.toString(),
            response.reasonPhrase ?? '',
            errorBody));
      }
    } on http.ClientException catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.networkError(e.message));
    } on TimeoutException {
      _showSnackBar(AppLocalizations.of(context)!.requestTimedOut);
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.genericError(e.toString()));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Build prediction confidence bar
  Widget _buildConfidenceBar(String condition, double confidence) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                condition,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A244E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: confidence,
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            color: condition == _predictedCondition
                ? const Color(0xFF7CF4A4)
                : const Color(0xFFA0D9FF),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Color constants
    const navyText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF3A3A3A);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightGrayFill = Color(0xFFE8F4EC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context)
              .pushReplacementNamed(ScanWorkflowScreen.routeName),
        ),
        title: Text(
          AppLocalizations.of(context)!.scan,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: navyText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 3) "Select Image" section label
            Text(
              AppLocalizations.of(context)!.selectImage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 12),

            // 4) Image selection area
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: lightGrayFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImageFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label:
                                  Text(AppLocalizations.of(context)!.takePhoto),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: const Icon(Icons.photo_library),
                              label:
                                  Text(AppLocalizations.of(context)!.gallery),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: primaryGreen, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                _selectedImage != null
                    ? AppLocalizations.of(context)!.imageSelected
                    : AppLocalizations.of(context)!.noImageSelected,
                style: const TextStyle(fontSize: 14, color: subtitleText),
              ),
            ),

            const SizedBox(height: 16),

            // 5) "Analyze" button
            Center(
              child: SizedBox(
                width: 140,
                height: 44,
                child: ElevatedButton(
                  onPressed: _selectedImage != null && !_isProcessing
                      ? _runInference
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: const StadiumBorder(),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.analyze,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 6) "Detected Conditions" section
            if (_hasResult && _predictedCondition != null) ...[
              Text(
                AppLocalizations.of(context)!.detectionResults,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navyText,
                ),
              ),
              const SizedBox(height: 12),

              // Results container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: lightGrayFill,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.predictedCondition,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subtitleText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _predictedCondition!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: navyText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!
                          .confidence((_confidence! * 100).toStringAsFixed(1)),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: navyText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Explanation section
                    if (_explanation != null) ...[
                      Text(
                        AppLocalizations.of(context)!.explanation,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtitleText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _explanation!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: navyText,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else if (_isFetchingExplanation) ...[
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // All predictions visualization
                    if (_allPredictions != null) ...[
                      Text(
                        AppLocalizations.of(context)!.allPredictions,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subtitleText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._allPredictions!.entries
                          .map((entry) =>
                              _buildConfidenceBar(entry.key, entry.value))
                          .toList(),
                      const SizedBox(height: 12),
                    ],

                    // Placeholder for Grad-CAM heatmap
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _gradcamBytes != null
                          ? Image.memory(_gradcamBytes!, fit: BoxFit.cover)
                          : Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .gradcamUnavailable,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Bottom action buttons
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ask a Question (Outlined)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            ChatScreen.routeName,
                            arguments: {
                              'condition': _predictedCondition,
                              'confidence': _confidence,
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: primaryGreen, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.askAQuestion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primaryGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Save to History (Filled)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSaveButton,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.saveToHistory,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
