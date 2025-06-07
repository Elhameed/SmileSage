import 'package:flutter/material.dart';

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
          onPressed: () => Navigator.of(context).pop(),
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
                        color: _selectedIndex == 0
                            ? primaryGreen
                            : Colors.white,
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
                        color: _selectedIndex == 1
                            ? primaryGreen
                            : Colors.white,
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

            // 3) "Camera" section label
            const Text(
              'Camera',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: navyText,
              ),
            ),
            const SizedBox(height: 12),

            // 4) Camera preview placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: lightGrayFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/camera_preview.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Hold Steady',
                style: TextStyle(fontSize: 14, color: subtitleText),
              ),
            ),

            const SizedBox(height: 16),
            // 5) "Capture" button
            Center(
              child: SizedBox(
                width: 140,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: trigger camera capture & detection logic
                    setState(() => _hasResult = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: const StadiumBorder(),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Capture',
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

            // 6) "Detected Conditions" section (only show if _hasResult is true)
            if (_hasResult) ...[
              const Text(
                'Detected Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: navyText,
                ),
              ),
              const SizedBox(height: 12),

              // Placeholder for detected-conditions image
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: lightGrayFill,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/detected_conditions.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                'Confidence: 85%',
                style: TextStyle(fontSize: 14, color: navyText),
              ),

              const SizedBox(height: 16),
              // Bottom action buttons
              Row(
                children: [
                  // Ask a Question (Outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: navigate to chat/QA flow
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
