import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io' as io;
import '../../../providers/diagnostic_provider.dart';

class HealthTip {
  final String title;
  final String description;
  final String emoji;
  final List<Color> colors;

  const HealthTip({
    required this.title,
    required this.description,
    required this.emoji,
    required this.colors,
  });
}

const List<HealthTip> healthTips = [
  HealthTip(
    title: 'Kelola Stres Anda',
    description: 'Sempatkan 5 menit untuk Box Breathing jika Anda merasa kewalahan.',
    emoji: '🧘‍♀️',
    colors: [Color(0xFF8B5CF6), Color(0xFF6C63FF)],
  ),
  HealthTip(
    title: 'Tidur yang Cukup',
    description: 'Tidur 7-8 jam membantu meregenerasi sel otak dan menstabilkan emosi.',
    emoji: '😴',
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  ),
  HealthTip(
    title: 'Ekspresikan Perasaan',
    description: 'Menulis jurnal mood harian sangat baik untuk meluapkan beban pikiran.',
    emoji: '📝',
    colors: [Color(0xFF10B981), Color(0xFF047857)],
  ),
  HealthTip(
    title: 'Koneksi Sosial',
    description: 'Berbagi cerita dengan orang terdekat dapat mengurangi kecemasan.',
    emoji: '🤗',
    colors: [Color(0xFFFF9F64), Color(0xFFFF7043)],
  ),
];

class HealthBannerCarousel extends StatefulWidget {
  final bool isDarkBg;
  const HealthBannerCarousel({super.key, required this.isDarkBg});

  @override
  State<HealthBannerCarousel> createState() => _HealthBannerCarouselState();
}

class _HealthBannerCarouselState extends State<HealthBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final diagnosticProvider = Provider.of<DiagnosticProvider>(context, listen: false);
        final count = diagnosticProvider.posters.isEmpty ? 4 : diagnosticProvider.posters.length;
        if (count > 0) {
          int nextPage = _currentPage + 1;
          if (nextPage >= count) {
            nextPage = 0;
          }
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (path.startsWith('http://') ||
        path.startsWith('https://') ||
        path.startsWith('blob:')) {
      return NetworkImage(path);
    }
    return FileImage(io.File(path));
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticProvider = Provider.of<DiagnosticProvider>(context);
    final List<String> defaultPosters = const [
      'assets/poster/poster1.jpg',
      'assets/poster/poster3.jpg',
      'assets/poster/poster4.jpg',
      'assets/poster/posterr5.jpg',
    ];
    final activePosters = diagnosticProvider.posters.isEmpty 
        ? defaultPosters 
        : diagnosticProvider.posters;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: activePosters.length,
            itemBuilder: (context, index) {
              final imagePath = activePosters[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(widget.isDarkBg ? 0.3 : 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(
                    image: _getImageProvider(imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(activePosters.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 16 : 6,
              decoration: BoxDecoration(
                color: isActive 
                    ? (widget.isDarkBg ? const Color(0xFF00C9A7) : const Color(0xFF6C63FF))
                    : (widget.isDarkBg ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
