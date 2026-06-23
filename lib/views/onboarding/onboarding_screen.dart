import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<OnboardingData> _slides = [
    OnboardingData(
      title: 'Selamat Datang di RiseUp',
      description:
          'Temukan kembali kedamaian hatimu. RiseUp hadir sebagai ruang aman untuk memantau, merawat, dan memulihkan kesehatan mentalmu secara mandiri.',
      gradientStart: const Color(0xFFFFF0E6),
      gradientEnd: const Color(0xFFFFF9F5),
      themeColor: const Color(0xFFFF9F64),
    ),
    OnboardingData(
      title: 'Monitoring Kesehatan Mental',
      description:
          'Pantau dan deteksi awal kondisi kesehatan mentalmu secara mandiri melalui kuesioner interaktif berbasis sistem pakar yang tepercaya.',
      gradientStart: const Color(0xFFF0EDFF),
      gradientEnd: const Color(0xFFF7F5FF),
      themeColor: const Color(0xFF6C63FF),
    ),
    OnboardingData(
      title: 'Jurnal Mood Harian',
      description:
          'Catat perasaanmu setiap hari dan pantau grafik fluktuasi emosimu dari waktu ke waktu untuk memahami dirimu secara lebih mendalam.',
      gradientStart: const Color(0xFFE8F8F5),
      gradientEnd: const Color(0xFFF3FBF9),
      themeColor: const Color(0xFF00C9A7),
    ),
    OnboardingData(
      title: 'Latihan Relaksasi Napas',
      description:
          'Kendalikan rasa cemas dan stres secara instan menggunakan panduan teknik pernapasan Box Breathing yang menenangkan pikiran.',
      gradientStart: const Color(0xFFE6F0FF),
      gradientEnd: const Color(0xFFF2F7FF),
      themeColor: const Color(0xFF3B82F6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Animasi kontinu (looping) untuk doodle latar belakang
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    Provider.of<AuthProvider>(context, listen: false).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final currentSlide = _slides[_currentPage];
          return Stack(
            children: [
              // 1. Background Doodle Painter Dinamis
              Positioned.fill(
                child: CustomPaint(
                  painter: OnboardingDoodlePainter(
                    pageIndex: _currentPage,
                    animationValue: _animationController.value,
                    themeColor: currentSlide.themeColor,
                    startColor: currentSlide.gradientStart,
                    endColor: currentSlide.gradientEnd,
                  ),
                ),
              ),

              // 2. Konten Slide
              SafeArea(
                child: Column(
                  children: [
                    // Header Bar (Tombol Skip)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentPage < _slides.length - 1)
                            TextButton(
                              onPressed: _finishOnboarding,
                              child: const Text(
                                'Lewati',
                                style: TextStyle(
                                  color: Color(0xFF3F3D56),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Slides PageView
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Ilustrasi Slide Kustom yang Terpusat & Tidak Tumpang Tindih
                                SizedBox(
                                  height: 180,
                                  width: 180,
                                  child: CustomPaint(
                                    painter: SlideIllustrationPainter(
                                      pageIndex: index,
                                      animationValue: _animationController.value,
                                      themeColor: slide.themeColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF3F3D56),
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.8),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  slide.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF707070),
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Footer Bar (Dots Indicator & Nav Button)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dots Indicator
                          Row(
                            children: List.generate(
                              _slides.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                height: 8,
                                width: _currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? currentSlide.themeColor
                                      : Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          // Tombol Navigasi
                          ElevatedButton(
                            onPressed: () {
                              if (_currentPage == _slides.length - 1) {
                                _finishOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentSlide.themeColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _slides.length - 1
                                      ? 'Mulai Sekarang'
                                      : 'Lanjut',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_rounded, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
  final Color themeColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
    required this.themeColor,
  });
}

/// Painter kustom untuk menggambar doodle interaktif yang dianimasikan
class OnboardingDoodlePainter extends CustomPainter {
  final int pageIndex;
  final double animationValue;
  final Color themeColor;
  final Color startColor;
  final Color endColor;

  OnboardingDoodlePainter({
    required this.pageIndex,
    required this.animationValue,
    required this.themeColor,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Gambar Gradasi Latar Belakang
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [startColor, endColor],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = null; // Reset shader

    final loopVal = animationValue * 2 * math.pi;

    // 2. Gambar ombak pastel yang bergerak mengayun lembut di bagian bawah
    final waveHeightOffset1 = math.sin(loopVal) * 10.0;
    final waveHeightOffset2 = math.cos(loopVal) * 8.0;
    final wavePath = Path()
      ..moveTo(0, size.height * 0.93 + waveHeightOffset1 * 0.4)
      ..quadraticBezierTo(
          size.width * 0.25, 
          size.height * 0.90 + waveHeightOffset1, 
          size.width * 0.5, 
          size.height * 0.94 + waveHeightOffset2
      )
      ..quadraticBezierTo(
          size.width * 0.75, 
          size.height * 0.98 + waveHeightOffset1, 
          size.width, 
          size.height * 0.92 + waveHeightOffset2 * 0.4
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    paint.color = themeColor.withOpacity(0.12);
    canvas.drawPath(wavePath, paint);

    // 3. Gambar awan-awan tersenyum melayang lambat
    final cloud1Offset = Offset(
      size.width * 0.8 + math.sin(loopVal * 0.8) * 12.0,
      size.height * 0.15 + math.cos(loopVal * 0.6) * 6.0,
    );
    _drawSmilingCloud(canvas, cloud1Offset, 30);

    final cloud2Offset = Offset(
      size.width * 0.15 + math.cos(loopVal * 0.6) * 10.0,
      size.height * 0.25 + math.sin(loopVal * 0.8) * 5.0,
    );
    _drawSmilingCloud(canvas, cloud2Offset, 24);

    final cloud3Offset = Offset(
      size.width * 0.85 + math.sin(loopVal * 0.7) * 8.0,
      size.height * 0.65 + math.cos(loopVal * 0.9) * 6.0,
    );
    _drawSmilingCloud(canvas, cloud3Offset, 26);

    // 4. Gambar matahari tersenyum
    _drawCuteSun(canvas, Offset(size.width * 0.55, size.height * 0.12), 22, loopVal);

    // 5. Gambar bintang-bintang berkelip manis
    _drawStar(canvas, Offset(size.width * 0.38, size.height * 0.15), 8, themeColor, loopVal, 0);
    _drawStar(canvas, Offset(size.width * 0.72, size.height * 0.28), 6, themeColor.withOpacity(0.8), loopVal, 1);
    _drawStar(canvas, Offset(size.width * 0.12, size.height * 0.52), 7, themeColor, loopVal, 2);
    _drawStar(canvas, Offset(size.width * 0.88, size.height * 0.48), 8, themeColor.withOpacity(0.8), loopVal, 3);
    _drawStar(canvas, Offset(size.width * 0.22, size.height * 0.80), 9, themeColor, loopVal, 4);
    _drawStar(canvas, Offset(size.width * 0.78, size.height * 0.78), 7, themeColor.withOpacity(0.8), loopVal, 5);

    // 6. Gambar hati berdenyut lembut
    final heartColor = const Color(0xFFFDA4AF); // Sweet pink
    _drawHeart(canvas, Offset(size.width * 0.28, size.height * 0.32), 10, heartColor, loopVal, 0);
    _drawHeart(canvas, Offset(size.width * 0.68, size.height * 0.58), 12, heartColor.withOpacity(0.85), loopVal, 1);
    _drawHeart(canvas, Offset(size.width * 0.18, size.height * 0.12), 8, heartColor, loopVal, 2);
    _drawHeart(canvas, Offset(size.width * 0.85, size.height * 0.85), 11, heartColor.withOpacity(0.85), loopVal, 3);
  }

  void _drawSmilingCloud(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.82)
      ..style = PaintingStyle.fill;
    
    // 3 overlapping circles
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.6, center.dy + radius * 0.1), radius * 0.75, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.6, center.dy + radius * 0.1), radius * 0.75, paint);

    // Drawing facial expressions
    final linePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Eyes
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.05), radius: 3.0),
      math.pi, math.pi, false, linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.05), radius: 3.0),
      math.pi, math.pi, false, linePaint,
    );
    
    // Happy Smiling Mouth
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + radius * 0.15), radius: 4.0),
      0, math.pi, false, linePaint,
    );

    // Cute pink cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFDA4AF).withOpacity(0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - radius * 0.4, center.dy + radius * 0.15), 3, cheekPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy + radius * 0.15), 3, cheekPaint);
  }

  void _drawCuteSun(Canvas canvas, Offset center, double radius, double loopVal) {
    final pulseRadius = radius * (1.0 + 0.04 * math.sin(loopVal * 1.5));
    final paint = Paint()..style = PaintingStyle.fill;

    // Glow ring
    paint.color = const Color(0xFFFEF08A).withOpacity(0.3 + 0.08 * math.sin(loopVal));
    canvas.drawCircle(center, pulseRadius * 1.35, paint);

    // Sun core
    paint.color = const Color(0xFFFACC15);
    canvas.drawCircle(center, pulseRadius, paint);

    // Cute face
    final linePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(center.dx - pulseRadius * 0.25, center.dy - pulseRadius * 0.1), 1.2, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawCircle(Offset(center.dx + pulseRadius * 0.25, center.dy - pulseRadius * 0.1), 1.2, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + pulseRadius * 0.1), radius: 3.0),
      0, math.pi, false, linePaint,
    );

    // Rays (rotating slowly)
    final rayPaint = Paint()
      ..color = const Color(0xFFFACC15).withOpacity(0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      double angle = i * (math.pi / 4) + (loopVal * 0.2);
      double startX = center.dx + (pulseRadius * 1.2) * math.cos(angle);
      double startY = center.dy + (pulseRadius * 1.2) * math.sin(angle);
      double endX = center.dx + (pulseRadius * 1.42) * math.cos(angle);
      double endY = center.dy + (pulseRadius * 1.42) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color, double loopVal, int index) {
    final starPulse = 0.5 + 0.5 * math.sin(loopVal * 1.6 + index * 1.2);
    final pulseSize = size * (0.7 + 0.3 * starPulse);
    
    final paint = Paint()
      ..color = color.withOpacity(0.35 + 0.5 * starPulse)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - pulseSize);
    path.lineTo(center.dx + pulseSize * 0.25, center.dy - pulseSize * 0.25);
    path.lineTo(center.dx + pulseSize, center.dy - pulseSize * 0.1);
    path.lineTo(center.dx + pulseSize * 0.4, center.dy + pulseSize * 0.3);
    path.lineTo(center.dx + pulseSize * 0.55, center.dy + pulseSize);
    path.lineTo(center.dx, center.dy + pulseSize * 0.55);
    path.lineTo(center.dx - pulseSize * 0.55, center.dy + pulseSize);
    path.lineTo(center.dx - pulseSize * 0.4, center.dy + pulseSize * 0.3);
    path.lineTo(center.dx - pulseSize, center.dy - pulseSize * 0.1);
    path.lineTo(center.dx - pulseSize * 0.25, center.dy - pulseSize * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double width, Color color, double loopVal, int index) {
    final heartPulse = 1.0 + 0.12 * math.sin(loopVal * 2.2 + index * 1.5);
    final pulseWidth = width * heartPulse;
    
    final paint = Paint()
      ..color = color.withOpacity(0.5 + 0.4 * math.sin(loopVal * 2.2 + index * 1.5))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy + pulseWidth * 0.35);
    path.cubicTo(
      center.dx - pulseWidth * 0.6, center.dy - pulseWidth * 0.5,
      center.dx - pulseWidth * 1.1, center.dy + pulseWidth * 0.2,
      center.dx, center.dy + pulseWidth * 0.95,
    );
    path.cubicTo(
      center.dx + pulseWidth * 1.1, center.dy + pulseWidth * 0.2,
      center.dx + pulseWidth * 0.6, center.dy - pulseWidth * 0.5,
      center.dx, center.dy + pulseWidth * 0.35,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant OnboardingDoodlePainter oldDelegate) {
    return oldDelegate.pageIndex != pageIndex ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}

/// Painter kustom untuk menggambar ilustrasi detail setiap slide onboarding secara mandiri
class SlideIllustrationPainter extends CustomPainter {
  final int pageIndex;
  final double animationValue;
  final Color themeColor;

  SlideIllustrationPainter({
    required this.pageIndex,
    required this.animationValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2); // local center (90, 90)
    final loopVal = animationValue * 2 * math.pi;

    switch (pageIndex) {
      case 0:
        // Slide 1: Welcome (Pelangi mini + hati besar berdenyut + kilau)
        _drawRainbow(canvas, center + const Offset(0, 15), themeColor);
        final pulseScale = 1.0 + 0.08 * math.sin(loopVal * 1.8);
        _drawPulsingHeart(canvas, center + const Offset(0, -5), 35 * pulseScale, themeColor);
        _drawSmallSparkles(canvas, center, loopVal, themeColor);
        break;

      case 1:
        // Slide 2: Monitoring (Clipboard Checklist + Kaca Pembesar Melayang + Lampu Ide)
        _drawExpertClipboard(canvas, center, loopVal, themeColor);
        
        final sweepX = center.dx + 20 * math.sin(loopVal * 2.2);
        final sweepY = center.dy - 30 + (1.0 + math.sin(loopVal * 0.7)) * 25;
        _drawMagnifyingGlass(canvas, Offset(sweepX, sweepY), 20, themeColor);
        
        _drawLightbulbWithRays(canvas, center + const Offset(55, -45), loopVal, themeColor);
        break;

      case 2:
        // Slide 3: Mood Tracker (Gelombang Sinus Mood + Balon Emoji + Gelembung Naik)
        _drawMoodSineWave(canvas, size, center, loopVal, themeColor);
        _drawRisingBubbles(canvas, size, loopVal, themeColor);
        
        _drawEmojiBalloon(
          canvas, 
          center + Offset(-45, math.sin(loopVal + math.pi / 3) * 8 - 15), 
          18, 
          Icons.sentiment_very_satisfied_rounded, 
          themeColor, 
          0.05 * math.sin(loopVal * 1.5)
        );
        _drawEmojiBalloon(
          canvas, 
          center + Offset(45, math.sin(loopVal - math.pi / 3) * 7 - 25), 
          15, 
          Icons.sentiment_satisfied_alt_rounded, 
          themeColor.withOpacity(0.7), 
          -0.06 * math.cos(loopVal * 1.2)
        );
        break;

      case 3:
        // Slide 4: Relaksasi Napas (Riak Napas Berlapis + Spa Icon + Daun Berguguran)
        final waveRadius = 45.0 + 12.0 * math.sin(loopVal - math.pi / 2);
        _drawBreathingWaves(canvas, center, waveRadius, themeColor);
        _drawBouncingIcon(canvas, center, Icons.spa_outlined, 36, themeColor);
        _drawFloatingLeaves(canvas, center, loopVal, themeColor);
        break;
    }
  }

  // --- Helper methods untuk SlideIllustrationPainter ---

  void _drawRainbow(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    final rect1 = Rect.fromCircle(center: center + const Offset(0, 25), radius: 55);
    final rect2 = Rect.fromCircle(center: center + const Offset(0, 25), radius: 65);
    final rect3 = Rect.fromCircle(center: center + const Offset(0, 25), radius: 75);

    canvas.drawArc(rect1, math.pi + 0.3, math.pi - 0.6, false, paint..color = color.withOpacity(0.15));
    canvas.drawArc(rect2, math.pi + 0.3, math.pi - 0.6, false, paint..color = color.withOpacity(0.10));
    canvas.drawArc(rect3, math.pi + 0.3, math.pi - 0.6, false, paint..color = color.withOpacity(0.05));
  }

  void _drawPulsingHeart(Canvas canvas, Offset offset, double size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size;
    final height = size;

    path.moveTo(offset.dx, offset.dy - height / 4);
    path.cubicTo(
      offset.dx - width / 2, offset.dy - height * 0.75,
      offset.dx - width, offset.dy,
      offset.dx, offset.dy + height * 0.7,
    );
    path.cubicTo(
      offset.dx + width, offset.dy,
      offset.dx + width / 2, offset.dy - height * 0.75,
      offset.dx, offset.dy - height / 4,
    );
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawSmallSparkles(Canvas canvas, Offset center, double loopVal, Color color) {
    final strokePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final sparkleOffsets = [
      Offset(center.dx - 55, center.dy - 35 + math.sin(loopVal) * 4),
      Offset(center.dx + 55, center.dy - 30 + math.cos(loopVal) * 4),
      Offset(center.dx - 45, center.dy + 40 + math.cos(loopVal * 1.2) * 5),
      Offset(center.dx + 45, center.dy + 35 + math.sin(loopVal * 0.9) * 5),
    ];

    for (var pos in sparkleOffsets) {
      canvas.drawLine(Offset(pos.dx - 4, pos.dy), Offset(pos.dx + 4, pos.dy), strokePaint);
      canvas.drawLine(Offset(pos.dx, pos.dy - 4), Offset(pos.dx, pos.dy + 4), strokePaint);
    }
  }

  void _drawExpertClipboard(Canvas canvas, Offset center, double loopVal, Color color) {
    final boardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final clipPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final clipStroke = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Board
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 95, height: 125),
      const Radius.circular(12),
    );
    canvas.drawRRect(boardRect, boardPaint);
    canvas.drawRRect(boardRect, strokePaint);

    // 2. Klip Logam
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center - const Offset(0, 62), width: 42, height: 14),
      const Radius.circular(5),
    );
    canvas.drawRRect(clipRect, clipPaint);
    canvas.drawRRect(clipRect, clipStroke);

    // 3. Checklist Items
    final textColor = color.withOpacity(0.65);
    final checkColor = const Color(0xFF00C9A7);

    for (int i = 0; i < 3; i++) {
      final yOffset = center.dy - 30 + i * 30;
      
      // Kotak
      final boxRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx - 30, yOffset), width: 12, height: 12),
        const Radius.circular(2.5),
      );
      canvas.drawRRect(boxRect, Paint()..color = color.withOpacity(0.05));
      canvas.drawRRect(boxRect, strokePaint..strokeWidth = 1.2);

      // Coretan baris teks
      final linePath = Path()
        ..moveTo(center.dx - 15, yOffset)
        ..quadraticBezierTo(center.dx + 5, yOffset + math.sin(loopVal + i) * 1.0, center.dx + 35, yOffset);
      canvas.drawPath(linePath, strokePaint..strokeWidth = 1.5..color = textColor);

      // Centang berdetak
      final checkPulse = 0.5 + 0.5 * math.sin(loopVal * 1.5 - i * math.pi / 2);
      if (checkPulse > 0.3) {
        final checkPaint = Paint()
          ..color = checkColor.withOpacity(0.8 * checkPulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        
        final checkPath = Path()
          ..moveTo(center.dx - 34, yOffset)
          ..lineTo(center.dx - 31, yOffset + 2.5)
          ..lineTo(center.dx - 27, yOffset - 2.5);
        canvas.drawPath(checkPath, checkPaint);

        // Efek riak
        final ripplePaint = Paint()
          ..color = checkColor.withOpacity(0.25 * (1.0 - (checkPulse - 0.3) / 0.7))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(center.dx - 30, yOffset), 6 + 10 * ((checkPulse - 0.3) / 0.7), ripplePaint);
      }
    }
  }

  void _drawMagnifyingGlass(Canvas canvas, Offset offset, double radius, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    // 1. Gagang
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawLine(
      Offset(0, radius),
      Offset(0, radius + 16),
      strokePaint..strokeWidth = 3.5..color = color.withOpacity(0.55),
    );
    canvas.restore();

    // 2. Lensa
    canvas.drawCircle(offset, radius, paint);
    canvas.drawCircle(offset, radius, strokePaint..strokeWidth = 2.8);

    // 3. Kilau
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    final arcRect = Rect.fromCircle(center: offset, radius: radius * 0.7);
    canvas.drawArc(arcRect, -math.pi * 0.8, math.pi * 0.4, false, reflectionPaint);
  }

  void _drawLightbulbWithRays(Canvas canvas, Offset offset, double loopVal, Color color) {
    final bulbPulse = 1.0 + 0.08 * math.sin(loopVal * 1.8);
    final bulbSize = 20.0 * bulbPulse;
    
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD460).withOpacity(0.1 * (1.0 + 0.3 * math.sin(loopVal * 1.8)))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, bulbSize * 1.6, glowPaint);
    
    final rayPaint = Paint()
      ..color = const Color(0xFFFFB100).withOpacity(0.5 + 0.3 * math.sin(loopVal * 1.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    
    final numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = (i * 2 * math.pi / numRays) + (loopVal * 0.1);
      final rayStart = Offset(
        offset.dx + bulbSize * 0.9 * math.cos(angle),
        offset.dy + bulbSize * 0.9 * math.sin(angle),
      );
      final rayEnd = Offset(
        offset.dx + (bulbSize * 1.3 + 3 * math.sin(loopVal * 2.0 + i)) * math.cos(angle),
        offset.dy + (bulbSize * 1.3 + 3 * math.sin(loopVal * 2.0 + i)) * math.sin(angle),
      );
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
    
    _drawBouncingIcon(canvas, offset, Icons.lightbulb_outline_rounded, bulbSize, const Color(0xFFFFB100));
  }

  void _drawMoodSineWave(Canvas canvas, Size size, Offset center, double loopVal, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = size.width * 0.08;
    final endX = size.width * 0.92;
    final yCenter = center.dy + 15;

    path.moveTo(startX, yCenter);
    for (double x = startX; x <= endX; x += 4) {
      final relativeX = (x - startX) / (endX - startX);
      final y = yCenter + 15 * math.sin(loopVal + relativeX * 2.2 * math.pi);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawRisingBubbles(Canvas canvas, Size size, double loopVal, Color color) {
    final strokePaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final bubblePositions = [
      Offset(size.width * 0.15, size.height * 0.7 - ((loopVal * 6) % 90)),
      Offset(size.width * 0.35, size.height * 0.65 - (((loopVal + 2) * 8) % 90)),
      Offset(size.width * 0.65, size.height * 0.75 - (((loopVal + 4) * 5) % 90)),
      Offset(size.width * 0.85, size.height * 0.7 - (((loopVal + 1) * 9) % 90)),
    ];

    for (var pos in bubblePositions) {
      canvas.drawCircle(pos, 3.0 + (pos.dy % 2.5), strokePaint);
    }
  }

  void _drawEmojiBalloon(Canvas canvas, Offset offset, double radius, IconData icon, Color color, double angle) {
    final paint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);

    // Balon
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(Offset.zero, radius, strokePaint);

    // Simpul
    final triPath = Path()
      ..moveTo(-2.5, radius)
      ..lineTo(2.5, radius)
      ..lineTo(0, radius + 4)
      ..close();
    canvas.drawPath(triPath, paint..color = color.withOpacity(0.3));
    canvas.drawPath(triPath, strokePaint);

    // Tali
    final stringPath = Path()
      ..moveTo(0, radius + 4)
      ..quadraticBezierTo(4, radius + 12, -2, radius + 22)
      ..quadraticBezierTo(2, radius + 28, 0, radius + 36);
    canvas.drawPath(stringPath, strokePaint..strokeWidth = 1.0..color = color.withOpacity(0.35));

    // Icon
    _drawBouncingIcon(canvas, Offset.zero, icon, radius * 1.1, color.withOpacity(0.75));

    canvas.restore();
  }

  void _drawBreathingWaves(Canvas canvas, Offset offset, double radius, Color color) {
    final fillPaint = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    canvas.drawCircle(offset, radius, fillPaint);
    canvas.drawCircle(offset, radius, strokePaint);

    canvas.drawCircle(offset, radius * 0.75, strokePaint..color = color.withOpacity(0.18));
    canvas.drawCircle(offset, radius * 0.5, strokePaint..color = color.withOpacity(0.12));
    canvas.drawCircle(offset, radius * 0.25, strokePaint..color = color.withOpacity(0.06));
  }

  void _drawFloatingLeaves(Canvas canvas, Offset center, double loopVal, Color color) {
    final leafPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final leafOffsets = [
      Offset(center.dx - 60, center.dy + 40 + math.sin(loopVal) * 8),
      Offset(center.dx + 60, center.dy - 40 + math.cos(loopVal) * 9),
      Offset(center.dx - 50, center.dy - 50 + math.cos(loopVal * 1.1) * 6),
      Offset(center.dx + 50, center.dy + 50 + math.sin(loopVal * 0.9) * 7),
    ];

    for (int i = 0; i < leafOffsets.length; i++) {
      final pos = leafOffsets[i];
      final angle = (i % 2 == 0) ? 0.35 + i * 0.15 : -0.4 - i * 0.12;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + math.sin(loopVal + i) * 0.15);
      
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-6, -9, 0, -18)
        ..quadraticBezierTo(6, -9, 0, 0);
      canvas.drawPath(path, leafPaint);
      canvas.drawLine(const Offset(0, 0), const Offset(0, -15), leafPaint);
      canvas.restore();
    }
  }

  void _drawBouncingIcon(Canvas canvas, Offset offset, IconData icon, double size, Color color) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant SlideIllustrationPainter oldDelegate) {
    return oldDelegate.pageIndex != pageIndex ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.themeColor != themeColor;
  }
}

