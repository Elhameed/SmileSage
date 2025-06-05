import 'package:flutter/material.dart';
import 'general_scan_screen.dart';

class ScanWorkflowScreen extends StatelessWidget {
  static const routeName = '/scan-workflow';

  const ScanWorkflowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blackText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF3A3A3A);
    const descriptionGold = Color(0xFFA1824A);
    const primaryGreen = Color(0xFF00C566);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header & Scan Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Scan Your Teeth',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: blackText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose the type of scan you’d like to perform. Hold your phone steady while scanning.',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ScanOptionTile(
                    title: 'General Scan',
                    description:
                        'Scan your teeth for cavities, gum disease, and more',
                    descriptionColor: descriptionGold,
                    onTap: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(GeneralScanScreen.routeName),
                  ),
                  const SizedBox(height: 16),
                  _ScanOptionTile(
                    title: 'Braces Scan',
                    description: 'Scan your teeth for braces related issues',
                    descriptionColor: descriptionGold,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120), // Safe spacing between scan and image

            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/teeth_scan.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Start Scan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanOptionTile extends StatelessWidget {
  final String title;
  final String description;
  final Color descriptionColor;
  final VoidCallback onTap;

  const _ScanOptionTile({
    Key? key,
    required this.title,
    required this.description,
    required this.descriptionColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const blackText = Color(0xFF0A244E);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: blackText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 28, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
