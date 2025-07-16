import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'tips_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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

    // Expanded content for all tabs
    final hygieneItems = [
      {
        'type': 'Article',
        'title': 'Mastering the Art of Flossing',
        'subtitle':
            'Learn the correct techniques for flossing to remove plaque and prevent gum disease.',
        'image': 'assets/images/learn1.png',
        'url': 'https://www.mouthhealthy.org/all-topics-a-z/flossing',
      },
      {
        'type': 'Video',
        'title': 'Brushing Techniques for a Healthier Smile',
        'subtitle':
            'Watch a step-by-step video on effective brushing methods to keep your teeth clean and strong.',
        'image': 'assets/images/learn2.png',
        'url': 'https://www.youtube.com/watch?v=3oG_JLuQ8T8',
      },
      {
        'type': 'Article',
        'title': 'The Importance of Tongue Scraping',
        'subtitle':
            'Discover the benefits of tongue scraping and how it can improve your oral hygiene.',
        'image': 'assets/images/learn3.png',
        'url':
            'https://www.healthline.com/health/dental-and-oral-health/tongue-scraping',
      },
      {
        'type': 'Tip',
        'title': 'Replace Your Toothbrush Regularly',
        'subtitle':
            'Change your toothbrush every 3-4 months or sooner if bristles are frayed.',
        'image': 'assets/images/brushing.png',
      },
      {
        'type': 'Resource',
        'title': 'ADA Oral Hygiene Recommendations',
        'subtitle': 'Official guidelines from the American Dental Association.',
        'image': 'assets/images/learn4.png',
        'url':
            'https://www.ada.org/resources/ada-library/oral-health-topics/home-care',
      },
    ];

    final dietItems = [
      {
        'type': 'Article',
        'title': 'Foods That Strengthen Your Teeth',
        'subtitle':
            'Explore foods rich in calcium and phosphorus for stronger enamel.',
        'image': 'assets/images/learn5.png',
        'url':
            'https://www.colgate.com/en-us/oral-health/nutrition-and-oral-health/healthy-foods-list-seven-best-foods-for-your-teeth',
      },
      {
        'type': 'Tip',
        'title': 'Limit Sugary Snacks',
        'subtitle': 'Reduce sugar intake to prevent cavities and tooth decay.',
        'image': 'assets/images/learn6.png',
      },
      {
        'type': 'Video',
        'title': 'How Diet Affects Oral Health',
        'subtitle':
            'A short video on the impact of nutrition on your teeth and gums.',
        'image': 'assets/images/learn7.png',
        'url': 'https://www.youtube.com/watch?v=7F5rVxe4XXE',
      },
      {
        'type': 'Resource',
        'title': 'Healthy Drinks for Your Smile',
        'subtitle': 'Discover beverages that are tooth-friendly.',
        'image': 'assets/images/learn8.png',
        'url':
            'https://www.colgate.com/en-us/oral-health/nutrition-and-oral-health/drinks-that-can-harm-your-teeth',
      },
    ];

    final diseasesItems = [
      {
        'type': 'Article',
        'title': 'Understanding Gum Disease',
        'subtitle':
            'Learn about the causes, symptoms, and prevention of gum disease.',
        'image': 'assets/images/learn9.png',
        'url':
            'https://my.clevelandclinic.org/health/diseases/21482-gum-periodontal-disease',
      },
      {
        'type': 'Article',
        'title': 'Tooth Decay: What You Need to Know',
        'subtitle': 'Find out how cavities form and how to protect your teeth.',
        'image': 'assets/images/learn10.png',
        'url':
            'https://www.mayoclinic.org/diseases-conditions/cavities/symptoms-causes/syc-20352892',
      },
      {
        'type': 'Video',
        'title': 'Recognizing Oral Cancer Signs',
        'subtitle': 'A video guide to spotting early signs of oral cancer.',
        'image': 'assets/images/learn11.png',
        'url': 'https://www.youtube.com/watch?v=vvP8Et1NPJU&t=12s',
      },
      {
        'type': 'Tip',
        'title': 'Regular Dental Checkups',
        'subtitle':
            'Visit your dentist every 6 months for early detection and prevention.',
        'image': 'assets/images/learn12.png',
      },
    ];

    final orthoItems = [
      {
        'type': 'Article',
        'title': 'Braces: What to Expect',
        'subtitle':
            'A beginner’s guide to orthodontic treatment and what to expect.',
        'image': 'assets/images/learn13.png',
        'url': 'https://bexarsmiles.com/straight-talk-about-braces/',
      },
      {
        'type': 'Tip',
        'title': 'Caring for Braces',
        'subtitle': 'How to keep your teeth and braces clean and healthy.',
        'image': 'assets/images/learn14.png',
      },
      {
        'type': 'Video',
        'title': 'How Invisalign Works',
        'subtitle': 'A video explaining clear aligner treatment.',
        'image': 'assets/images/learn15.png',
        'url': 'https://www.youtube.com/watch?v=Rg7yOACRjoA',
      },
      {
        'type': 'Resource',
        'title': 'Find an Orthodontist',
        'subtitle': 'Search for certified orthodontists near you.',
        'image': 'assets/images/clinic_map.png',
        'url': 'https://www.aaoinfo.org/locator/',
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
                        url: item['url'],
                      );
                    },
                  ),
                  // Diet tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: dietItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final item = dietItems[i];
                      return _LearnTile(
                        type: item['type']!,
                        title: item['title']!,
                        subtitle: item['subtitle']!,
                        imagePath: item['image']!,
                        url: item['url'],
                      );
                    },
                  ),
                  // Diseases tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: diseasesItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final item = diseasesItems[i];
                      return _LearnTile(
                        type: item['type']!,
                        title: item['title']!,
                        subtitle: item['subtitle']!,
                        imagePath: item['image']!,
                        url: item['url'],
                      );
                    },
                  ),
                  // Orthodontics tab
                  ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: orthoItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, i) {
                      final item = orthoItems[i];
                      return _LearnTile(
                        type: item['type']!,
                        title: item['title']!,
                        subtitle: item['subtitle']!,
                        imagePath: item['image']!,
                        url: item['url'],
                      );
                    },
                  ),
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
  final String? url;

  const _LearnTile({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.url,
  }) : super(key: key);

  void _launchUrl(BuildContext context) async {
    if (url != null) {
      final uri = Uri.parse(url!);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);

    return InkWell(
      onTap: url != null ? () => _launchUrl(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (url != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        type == 'Video'
                            ? Icons.play_circle_fill
                            : Icons.open_in_new,
                        size: 16,
                        color: subtitleText,
                      ),
                    ],
                  ],
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
      ),
    );
  }
}
