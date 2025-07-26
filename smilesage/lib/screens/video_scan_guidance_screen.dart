import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoScanGuidanceScreen extends StatefulWidget {
  const VideoScanGuidanceScreen({Key? key}) : super(key: key);

  @override
  State<VideoScanGuidanceScreen> createState() =>
      _VideoScanGuidanceScreenState();
}

class _VideoScanGuidanceScreenState extends State<VideoScanGuidanceScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/guidance_demo.mp4')
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Color constants matching app theme
    const navyText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF3A3A3A);
    const primaryGreen = Color(0xFF7CF4A4);
    const lightGrayFill = Color(0xFFE8F4EC);
    const warmBackground =
        Color(0xFFE8F4EC); // Warm off-white for subtle warmth

    return Scaffold(
      backgroundColor: warmBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: navyText),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: lightGrayFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _isInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: VideoPlayer(_controller),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: lightGrayFill,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF7CF4A4),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'How to record your dental scan',
                style: const TextStyle(
                  color: navyText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildStep(Icons.light_mode, 'Be in a well-lit room'),
              _buildStep(Icons.stay_current_portrait,
                  'Hold the phone steady at mouth level'),
              _buildStep(Icons.arrow_forward,
                  'Move slowly from left to right, keeping your teeth in focus'),
              _buildStep(Icons.arrow_back,
                  'Return from right to left to complete the scan'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: navyText,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Start Recording',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7CF4A4), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF0A244E), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
