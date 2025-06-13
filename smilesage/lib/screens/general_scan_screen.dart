import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'scan_workflow_screen.dart';

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

  // Image and model related variables
  File? _selectedImage;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  Interpreter? _interpreter;

  // Prediction results
  String? _predictedCondition;
  double? _confidence;

  // Class labels for the dental conditions
  final List<String> _classLabels = [
    'Hypodontia',
    'Ulcers',
    'Tooth Discoloration',
    'Healthy',
    'Calculus',
    'Caries',
    'Gingivitis',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      final interpreter =
          await Interpreter.fromAsset('models/efficientnetb0_finetuned.tflite');
      setState(() {
        _interpreter = interpreter;
        _isModelLoaded = true;
      });
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load AI model: $e')),
      );
    }
  }

  // Preprocess image for EfficientNetB0
  Float32List _preprocessImage(File imageFile) {
    final imageBytes = imageFile.readAsBytesSync();
    final image = img.decodeImage(imageBytes)!;
    final resized = img.copyResize(image, width: 224, height: 224);

    // Normalize pixel values to [0,1]
    final input = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }
    return input;
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
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  // Run inference on the selected image
  Future<void> _runInference() async {
    if (_selectedImage == null || !_isModelLoaded || _interpreter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image and ensure model is loaded'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Preprocess image
      final input = _preprocessImage(_selectedImage!);

      // Configure output tensor
      final output = List.filled(1 * _classLabels.length, 0.0)
          .reshape([1, _classLabels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Get prediction results
      final predictions = output[0];
      double maxScore = predictions[0];
      int maxIndex = 0;

      for (int i = 0; i < predictions.length; i++) {
        if (predictions[i] > maxScore) {
          maxScore = predictions[i];
          maxIndex = i;
        }
      }

      setState(() {
        _predictedCondition = _classLabels[maxIndex];
        _confidence = maxScore;
        _hasResult = true;
        _isProcessing = false;
      });
    } catch (e) {
      print('Inference error: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during prediction: $e')),
      );
    }
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
          onPressed: () => Navigator.of(
            context,
          ).pushReplacementNamed(ScanWorkflowScreen.routeName),
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
                  onPressed:
                      _selectedImage != null && _isModelLoaded && !_isProcessing
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
                          _isModelLoaded ? 'Analyze' : 'Loading...',
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

            // 6) "Detected Conditions" section (only show if _hasResult is true)
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
                    const SizedBox(height: 12),

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
                        // TODO: save result to history
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
