import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'tips_screen.dart';

class LearnScreen extends StatefulWidget {
  static const routeName = '/learn';
  const LearnScreen({Key? key}) : super(key: key);

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  int _selectedIndex = 4; // Learn tab

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
        Navigator.of(context).pushNamed(ClinicsScreen.routeName);
        break;
      default:
        setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundWhite = Colors.white;
    const darkText = Colors.black;
    const subtitleText = Color(0xFF7CA78C);
    const inputBg = Color(0xFFE8F4EC);
    const indicatorColor = Color(0xFF7CF4A4);
    const goldText = Color(0xFFB58E31);

    // Sample data for the “Hygiene” tab
    final hygieneItems = [
      {
        'type': 'Article',
        'title': 'Mastering the Art of Flossing: A Comprehensive Guide',
        'subtitle':
            'Learn the correct techniques for flossing to remove plaque and prevent gum disease.',
        'image': 'assets/images/learn1.png',
      },
      {
        'type': 'Video',
        'title': 'Brushing Techniques for a Healthier Smile',
        'subtitle':
            'Watch a step-by-step video on effective brushing methods to keep your teeth clean and strong.',
        'image': 'assets/images/learn2.png',
      },
      {
        'type': 'Article',
        'title': 'The Importance of Tongue Scraping',
        'subtitle':
            'Discover the benefits of tongue scraping and how it can improve your oral hygiene.',
        'image': 'assets/images/learn3.png',
      },
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: backgroundWhite,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Learn',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 1) Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search',
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 2) Tab bar
            TabBar(
              indicatorColor: indicatorColor,
              labelColor: darkText,
              unselectedLabelColor: subtitleText,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Hygiene'),
                Tab(text: 'Diet'),
                Tab(text: 'Diseases'),
                Tab(text: 'Orthodontics'),
              ],
            ),

            // 3) Tab views
            Expanded(
              child: TabBarView(
                children: [
                  // Hygiene tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: hygieneItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final item = hygieneItems[i];
                      return _LearnTile(
                        type: item['type']!,
                        title: item['title']!,
                        subtitle: item['subtitle']!,
                        imagePath: item['image']!,
                      );
                    },
                  ),

                  // Placeholder for other tabs
                  const Center(child: Text('No content yet')),
                  const Center(child: Text('No content yet')),
                  const Center(child: Text('No content yet')),
                ],
              ),
            ),
          ],
        ),

        // 4) Bottom navigation
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundWhite,
          selectedItemColor: indicatorColor,
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
      ),
    );
  }
}

/// A single content row in the Learn screen
class _LearnTile extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String imagePath;

  const _LearnTile({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const darkText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: subtitleText),
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
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
