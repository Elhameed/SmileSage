import 'package:flutter/material.dart';
import 'scan_workflow_screen.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'tips_screen.dart';

class ClinicsScreen extends StatefulWidget {
  static const routeName = '/clinics';
  const ClinicsScreen({Key? key}) : super(key: key);

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  int _selectedIndex = 3;
  final List<Map<String, String>> _clinics = [
    {
      'name': 'Bright Smiles Dental',
      'address': '123 Main St, San Francisco, CA 94105',
      'image': 'assets/images/clinic1.png',
    },
    {
      'name': 'Golden Gate Dental Care',
      'address': '456 Oak Ave, San Francisco, CA 94118',
      'image': 'assets/images/clinic2.png',
    },
    {
      'name': 'Presidio Dental Group',
      'address': '789 Pine St, San Francisco, CA 94115',
      'image': 'assets/images/clinic3.png',
    },
  ];

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        break;
      case 1:
        Navigator.of(context).pushNamed(TipsScreen.routeName);
        break;
      case 2:
        Navigator.of(context).pushNamed(ScanWorkflowScreen.routeName);
        break;
      case 3:
        break;
      case 4:
        Navigator.of(context).pushNamed(LearnScreen.routeName);
        break;
      default:
        setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF7CF4A4);
    const headingText = Color(0xFF0A244E);
    const searchBg = Color(0xFFE8F4EC);
    const backgroundWhite = Colors.white;
    const goldText = Color(0xFFB58E31);

    final mapHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Find a Clinic',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // 1) Map image at top
          SizedBox(
            height: mapHeight,
            width: double.infinity,
            child: Image.asset(
              'assets/images/clinic_map.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2) Search bar overlay
          Positioned(
            top: 16,
            left: 24,
            right: 24,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search for a clinic',
                  filled: true,
                  fillColor: searchBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // 3) Plus button overlay
          Positioned(
            top: mapHeight - 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // TODO: handle add clinic action
                },
              ),
            ),
          ),

          // 4) Draggable sheet with clinic list
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.55,
            maxChildSize: 0.90,
            builder: (_, controller) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // “Nearby Clinics” header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nearby Clinics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: headingText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Clinic list
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _clinics.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) {
                        final clinic = _clinics[i];
                        return _ClinicTile(
                          name: clinic['name']!,
                          address: clinic['address']!,
                          imagePath: clinic['image']!,
                          onNavigate: () {
                            // TODO: launch maps/navigation
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 5) BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: goldText,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_tips.png')),
            label: 'Tips',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_scan.png')),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_clinics.png')),
            label: 'Clinics',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/icon_learn.png')),
            label: 'Learn',
          ),
        ],
      ),
    );
  }
}

class _ClinicTile extends StatelessWidget {
  final String name;
  final String address;
  final String imagePath;
  final VoidCallback onNavigate;

  const _ClinicTile({
    Key? key,
    required this.name,
    required this.address,
    required this.imagePath,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headingText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);

    return Row(
      children: [
        // Text & Navigate button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: headingText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(fontSize: 14, color: subtitleText),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onNavigate,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F4EC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Navigate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A244E),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
