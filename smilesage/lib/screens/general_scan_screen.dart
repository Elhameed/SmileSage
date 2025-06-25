import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'scan_workflow_screen.dart';
import 'dart:async';

class GeneralScanScreen extends StatefulWidget {
  static const routeName = '/general-scan';
  const GeneralScanScreen({Key? key}) : super(key: key);

  @override
  State<GeneralScanScreen> createState() => _GeneralScanScreenState();
}

class _GeneralScanScreenState extends State<GeneralScanScreen> {
  // Track which scan type is selected: 0 = General, 1 = Braces
  int _selectedIndex = 0;

  // Track whether an image/condition has been detected
  bool _hasResult = false;

  // Image and API related variables
  File? _selectedImage;
  bool _isProcessing = false;

  // Prediction results
  String? _predictedCondition;
  double? _confidence;
  Map<String, double>? _allPredictions;

  // API endpoint configuration
  static const String _apiEndpoint =
      "https://teniola04-dental-api.hf.space/predict";
  static const Duration _apiTimeout = Duration(seconds: 30);

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  // Pick image from gallery
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
          _hasResult = false; // Reset previous results
          _predictedCondition = null;
          _confidence = null;
          _allPredictions = null;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Error selecting image: ${e.toString()}');
    }
  }

  // Preprocess image to match model requirements
  Future<Uint8List> _preprocessImage(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Decode image
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) throw Exception('Failed to decode image');

      // Resize to 224x224
      final resizedImage =
          img.copyResize(originalImage, width: 224, height: 224);

      // Remove alpha channel if it exists (manual method)
      final rgbImage =
          img.Image(width: resizedImage.width, height: resizedImage.height);
      for (int y = 0; y < resizedImage.height; y++) {
        for (int x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          rgbImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
        }
      }
      // Encode as JPEG
      return Uint8List.fromList(img.encodeJpg(rgbImage));
    } catch (e) {
      print('Image preprocessing error: $e');
      throw Exception('Image processing failed');
    }
  }

  // Send image to API for prediction
  Future<void> _runInference() async {
    if (_selectedImage == null) {
      _showSnackBar('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Preprocess the image
      final processedImage = await _preprocessImage(_selectedImage!);

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(_apiEndpoint))
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          processedImage,
          filename: 'dental_scan.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));

      // Send request with timeout
      var response = await request.send().timeout(_apiTimeout);

      // Process response
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        setState(() {
          _predictedCondition = jsonResponse['condition'];
          _confidence = jsonResponse['confidence'] is int
              ? (jsonResponse['confidence'] as int).toDouble()
              : jsonResponse['confidence'] as double;
          _allPredictions =
              (jsonResponse['all_predictions'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
                key, value is int ? value.toDouble() : value as double),
          );
          _hasResult = true;
        });
      } else {
        final errorBody = await response.stream.bytesToString();
        _showSnackBar(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}\n$errorBody');
      }
    } on http.ClientException catch (e) {
      _showSnackBar('Network error: ${e.message}');
    } on TimeoutException {
      _showSnackBar('Request timed out. Please try again');
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Helper to show snackbar messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red.shade700,
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
        title: const Text(
          'Scan',
          style: TextStyle(
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

            // 1) "Select Scan Type" label
            const Text(
              'Select Scan Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 12),

            // 2) Toggle pills for General vs. Braces
            Row(
              children: [
                // General Scan pill
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 0),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _selectedIndex == 0 ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedIndex == 0
                              ? primaryGreen
                              : Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'General Scan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedIndex == 0 ? Colors.white : navyText,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Braces Scan pill
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 1),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:
                            _selectedIndex == 1 ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedIndex == 1
                              ? primaryGreen
                              : Colors.grey.shade400,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'Braces Scan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _selectedIndex == 1 ? Colors.white : navyText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 3) "Select Image" section label
            const Text(
              'Select Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 12),

            // 4) Image selection area
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
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
                        children: const [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to select image from gallery',
                            style: TextStyle(fontSize: 14, color: subtitleText),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                _selectedImage != null ? 'Image selected' : 'No image selected',
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
                      : const Text(
                          'Analyze',
                          style: TextStyle(
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
              const Text(
                'Detection Results',
                style: TextStyle(
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
                      'Predicted Condition:',
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
                      'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: navyText,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // All predictions visualization
                    if (_allPredictions != null) ...[
                      const Text(
                        'All Predictions:',
                        style: TextStyle(
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
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          'Grad-CAM Heatmap\n(Coming Soon)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Bottom action buttons
              Row(
                children: [
                  // Ask a Question (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/chat');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryGreen, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Ask a Question',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Save to History (Filled)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Result saved to history'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Save to History',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
