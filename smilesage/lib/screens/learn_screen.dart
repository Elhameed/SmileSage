import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'scan_workflow_screen.dart';
import 'clinics_screen.dart';
import 'tips_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    final loc = AppLocalizations.of(context)!;
    // Expanded content for all tabs
    final hygieneItems = [
      {
        'type': loc.learnTypeArticle,
        'title': loc.learnTitleFlossing,
        'subtitle': loc.learnSubtitleFlossing,
        'image': 'assets/images/learn1.png',
        'url': 'https://www.mouthhealthy.org/all-topics-a-z/flossing',
      },
      {
        'type': loc.learnTypeVideo,
        'title': loc.learnTitleBrushing,
        'subtitle': loc.learnSubtitleBrushing,
        'image': 'assets/images/learn2.png',
        'url': 'https://www.youtube.com/watch?v=3oG_JLuQ8T8',
      },
      {
        'type': loc.learnTypeArticle,
        'title': loc.learnTitleTongueScraping,
        'subtitle': loc.learnSubtitleTongueScraping,
        'image': 'assets/images/learn3.png',
        'url':
            'https://www.healthline.com/health/dental-and-oral-health/tongue-scraping',
      },
      {
        'type': loc.learnTypeTip,
        'title': loc.learnTitleReplaceToothbrush,
        'subtitle': loc.learnSubtitleReplaceToothbrush,
        'image': 'assets/images/brushing.png',
      },
      {
        'type': loc.learnTypeResource,
        'title': loc.learnTitleADA,
        'subtitle': loc.learnSubtitleADA,
        'image': 'assets/images/learn4.png',
        'url':
            'https://www.ada.org/resources/ada-library/oral-health-topics/home-care',
      },
    ];
    final dietItems = [
      {
        'type': loc.learnTypeArticle,
        'title': loc.learnTitleFoodsStrengthen,
        'subtitle': loc.learnSubtitleFoodsStrengthen,
        'image': 'assets/images/learn5.png',
        'url':
            'https://www.colgate.com/en-us/oral-health/nutrition-and-oral-health/healthy-foods-list-seven-best-foods-for-your-teeth',
      },
      {
        'type': loc.learnTypeTip,
        'title': loc.learnTitleLimitSugar,
        'subtitle': loc.learnSubtitleLimitSugar,
        'image': 'assets/images/learn6.png',
      },
      {
        'type': loc.learnTypeVideo,
        'title': loc.learnTitleDietVideo,
        'subtitle': loc.learnSubtitleDietVideo,
        'image': 'assets/images/learn7.png',
        'url': 'https://www.youtube.com/watch?v=7F5rVxe4XXE',
      },
      {
        'type': loc.learnTypeResource,
        'title': loc.learnTitleHealthyDrinks,
        'subtitle': loc.learnSubtitleHealthyDrinks,
        'image': 'assets/images/learn8.png',
        'url':
            'https://www.colgate.com/en-us/oral-health/nutrition-and-oral-health/drinks-that-can-harm-your-teeth',
      },
    ];
    final diseasesItems = [
      {
        'type': loc.learnTypeArticle,
        'title': loc.learnTitleGumDisease,
        'subtitle': loc.learnSubtitleGumDisease,
        'image': 'assets/images/learn9.png',
        'url':
            'https://my.clevelandclinic.org/health/diseases/21482-gum-periodontal-disease',
      },
      {
        'type': loc.learnTypeArticle,
        'title': loc.learnTitleToothDecay,
        'subtitle': loc.learnSubtitleToothDecay,
        'image': 'assets/images/learn10.png',
        'url':
            'https://www.mayoclinic.org/diseases-conditions/cavities/symptoms-causes/syc-20352892',
      },
      {
        'type': loc.learnTypeVideo,
        'title': loc.learnTitleOralCancer,
        'subtitle': loc.learnSubtitleOralCancer,
        'image': 'assets/images/learn11.png',
        'url': 'https://www.youtube.com/watch?v=vvP8Et1NPJU&t=12s',
      },
      {
        'type': loc.learnTypeTip,
        'title': loc.learnTitleDentalCheckups,
        'subtitle': loc.learnSubtitleDentalCheckups,
        'image': 'assets/images/learn12.png',
      },
    ];
    final orthoItems = [
      {
        'type': loc.learnTypeArticle,
        'title': loc.learnTitleBraces,
        'subtitle': loc.learnSubtitleBraces,
        'image': 'assets/images/learn13.png',
        'url': 'https://bexarsmiles.com/straight-talk-about-braces/',
      },
      {
        'type': loc.learnTypeTip,
        'title': loc.learnTitleCaringBraces,
        'subtitle': loc.learnSubtitleCaringBraces,
        'image': 'assets/images/learn14.png',
      },
      {
        'type': loc.learnTypeVideo,
        'title': loc.learnTitleInvisalign,
        'subtitle': loc.learnSubtitleInvisalign,
        'image': 'assets/images/learn15.png',
        'url': 'https://www.youtube.com/watch?v=Rg7yOACRjoA',
      },
      {
        'type': loc.learnTypeResource,
        'title': loc.learnTitleFindOrtho,
        'subtitle': loc.learnSubtitleFindOrtho,
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
          title: Text(
            loc.learnTabOrthodontics, // Or use a localized title if needed
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
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
                  hintText:
                      loc.search, // Use a localized search hint if available
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
              tabs: [
                Tab(text: loc.learnTabHygiene),
                Tab(text: loc.learnTabDiet),
                Tab(text: loc.learnTabDiseases),
                Tab(text: loc.learnTabOrthodontics),
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
                        unableToOpenLink: loc.learnUnableToOpenLink,
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
                        unableToOpenLink: loc.learnUnableToOpenLink,
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
                        unableToOpenLink: loc.learnUnableToOpenLink,
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
                        unableToOpenLink: loc.learnUnableToOpenLink,
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
          items: [
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage('assets/images/icon_home.png')),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage('assets/images/icon_tips.png')),
              label: AppLocalizations.of(context)!.tips,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage('assets/images/icon_scan.png')),
              label: AppLocalizations.of(context)!.scan,
            ),
            BottomNavigationBarItem(
              icon:
                  const ImageIcon(AssetImage('assets/images/icon_clinics.png')),
              label: AppLocalizations.of(context)!.clinics,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage('assets/images/icon_learn.png')),
              label: AppLocalizations.of(context)!.learn,
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnTile extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final String imagePath;
  final String? url;
  final String unableToOpenLink;

  const _LearnTile({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    this.url,
    required this.unableToOpenLink,
  }) : super(key: key);

  void _launchUrl(BuildContext context) async {
    if (url != null) {
      final uri = Uri.parse(url!);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(unableToOpenLink)),
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
                        type == AppLocalizations.of(context)!.learnTypeVideo
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
