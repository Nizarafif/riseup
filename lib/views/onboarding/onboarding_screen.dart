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
      title: 'Monitoring Sistem Pakar',
      description:
          'Identifikasi kondisi psikologismu secara dini melalui kuesioner interaktif berbasis sistem pakar Forward Chaining yang tepercaya.',
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
                                // Placeholder spacer untuk area doodle visual di atas
                                const SizedBox(height: 180),
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
    final paint = Paint()..style = PaintingStyle.fill;

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

    // 2. Gambar Doodle Berdasarkan Slide Aktif
    final center = Offset(size.width / 2, size.height * 0.30);
    final loopVal = animationValue * 2 * math.pi;

    switch (pageIndex) {
      case 0:
        // Slide 1: Welcome (Pelangi + Parallax Awan + Matahari + Bintang/Hati Ramai)
        _drawRainbow(canvas, center + const Offset(0, 20), themeColor);
        _drawSun(canvas, center + Offset(90, -80), 32, loopVal);
        
        // 4 Awan Parallax (berbeda kecepatan & ukuran untuk efek kedalaman)
        _drawCloud(canvas, center + Offset(math.sin(loopVal) * 18 - 50, 40), 55, themeColor);
        _drawCloud(canvas, center + Offset(math.cos(loopVal * 1.3) * 12 + 60, 70), 38, themeColor.withOpacity(0.55));
        _drawCloud(canvas, center + Offset(math.sin(loopVal * 0.8) * 15 - 90, 80), 32, themeColor.withOpacity(0.35));
        _drawCloud(canvas, center + Offset(math.cos(loopVal * 0.9) * 10 + 100, 20), 42, themeColor.withOpacity(0.45));
        
        _drawSmallHeartsAndStars(canvas, size, loopVal, themeColor);
        break;

      case 1:
        // Slide 2: Monitoring (Clipboard Checklist + Kaca Pembesar Melayang + Lampu Ide + Bintang Ramai)
        _drawTwinklingStars(canvas, center, loopVal, themeColor);
        _drawFloatingPapers(canvas, center, loopVal, themeColor);
        _drawExpertClipboard(canvas, center, loopVal, themeColor);
        
        // Gambar Kaca Pembesar dengan gerakan aktif memindai (Scanning)
        final sweepX = center.dx + 25 * math.sin(loopVal * 2.2);
        final sweepY = center.dy - 35 + (1.0 + math.sin(loopVal * 0.7)) * 35;
        _drawMagnifyingGlass(canvas, Offset(sweepX, sweepY), 24, themeColor);
        
        // Lampu Ide / Insight dengan radiasi gelombang energi cahaya yang memancar
        _drawLightbulbWithRays(canvas, center + const Offset(70, -50), loopVal, themeColor);
        break;

      case 2:
        // Slide 3: Mood Tracker (Gelombang Sinus Mood + Balon Emoji Terikat + Gelembung Naik)
        _drawMoodSineWave(canvas, size, center, loopVal, themeColor);
        _drawRisingBubbles(canvas, size, loopVal, themeColor);
        
        // Balon Emoji Bergoyang (tali terikat ke grafik)
        final pulseScale = 1.0 + 0.08 * math.sin(loopVal);
        _drawPulsingHeart(canvas, center + const Offset(0, -60), 40 * pulseScale, themeColor.withOpacity(0.85));
        
        _drawEmojiBalloon(
          canvas, 
          center + Offset(-75, math.sin(loopVal + math.pi/3) * 10 - 20), 
          24, 
          Icons.sentiment_very_satisfied_rounded, 
          themeColor, 
          0.05 * math.sin(loopVal * 1.5)
        );
        _drawEmojiBalloon(
          canvas, 
          center + Offset(75, math.sin(loopVal - math.pi/3) * 8 - 40), 20, 
          Icons.sentiment_satisfied_alt_rounded, 
          themeColor.withOpacity(0.7), 
          -0.06 * math.cos(loopVal * 1.2)
        );
        break;

      case 3:
        // Slide 4: Relaksasi Napas (Aliran Angin + Riak Napas Berlapis + Spa Icon + Daun Berguguran)
        _drawWindBreeze(canvas, size, center, loopVal, themeColor);
        
        // 4 Tingkat Riak Napas Konsentris
        final waveRadius = 70.0 + 18.0 * math.sin(loopVal - math.pi / 2);
        _drawBreathingWaves(canvas, center, waveRadius, themeColor);
        
        _drawBouncingIcon(canvas, center, Icons.spa_outlined, 44, themeColor);
        _drawFloatingLeaves(canvas, center, loopVal, themeColor);
        break;
    }
  }

  // --- Helpers Menggambar Doodle Baru & Lebih Ramai ---

  void _drawRainbow(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    final rect1 = Rect.fromCircle(center: center + const Offset(0, 40), radius: 100);
    final rect2 = Rect.fromCircle(center: center + const Offset(0, 40), radius: 112);
    final rect3 = Rect.fromCircle(center: center + const Offset(0, 40), radius: 124);

    canvas.drawArc(rect1, math.pi + 0.3, math.pi - 0.6, false, paint..color = color.withOpacity(0.12));
    canvas.drawArc(rect2, math.pi + 0.3, math.pi - 0.6, false, paint..color = color.withOpacity(0.08));
    canvas.drawArc(rect3, math.pi + 0.3, math.pi - 0.6, false, paint..color = color.withOpacity(0.04));
  }

  void _drawCloud(Canvas canvas, Offset offset, double width, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.16)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(offset.dx, offset.offsetY(10))
      ..arcToPoint(Offset(offset.dx + width * 0.3, offset.offsetY(-10)),
          radius: Radius.circular(width * 0.2))
      ..arcToPoint(Offset(offset.dx + width * 0.7, offset.offsetY(-10)),
          radius: Radius.circular(width * 0.25))
      ..arcToPoint(Offset(offset.dx + width, offset.offsetY(10)),
          radius: Radius.circular(width * 0.2))
      ..arcToPoint(offset, radius: Radius.circular(width * 0.15))
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawSun(Canvas canvas, Offset offset, double radius, double rotation) {
    final fillPaint = Paint()
      ..color = const Color(0xFFFFD460).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFFFB100).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(offset, radius, fillPaint);
    canvas.drawCircle(offset, radius, strokePaint);

    // Sinar Matahari Berputar
    final numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = rotation + (i * 2 * math.pi / numRays);
      final start = Offset(
        offset.dx + radius * 1.25 * math.cos(angle),
        offset.dy + radius * 1.25 * math.sin(angle),
      );
      final end = Offset(
        offset.dx + radius * 1.55 * math.cos(angle),
        offset.dy + radius * 1.55 * math.sin(angle),
      );
      canvas.drawLine(start, end, strokePaint);
    }
  }

  void _drawSmallHeartsAndStars(Canvas canvas, Size size, double loopVal, Color color) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Partikel mengapung
    final particles = [
      Offset(size.width * 0.15, size.height * 0.15 + math.sin(loopVal) * 12),
      Offset(size.width * 0.85, size.height * 0.18 + math.cos(loopVal) * 10),
      Offset(size.width * 0.22, size.height * 0.42 + math.cos(loopVal * 1.2) * 8),
      Offset(size.width * 0.78, size.height * 0.45 + math.sin(loopVal * 0.9) * 14),
      Offset(size.width * 0.45, size.height * 0.10 + math.sin(loopVal * 1.5) * 6),
      Offset(size.width * 0.10, size.height * 0.30 + math.cos(loopVal * 0.7) * 10),
      Offset(size.width * 0.90, size.height * 0.35 + math.sin(loopVal * 1.1) * 8),
    ];

    for (int i = 0; i < particles.length; i++) {
      final pos = particles[i];
      if (i % 2 == 0) {
        // Gambar bintang kecil (silang)
        canvas.drawLine(Offset(pos.dx - 5, pos.dy), Offset(pos.dx + 5, pos.dy), strokePaint);
        canvas.drawLine(Offset(pos.dx, pos.dy - 5), Offset(pos.dx, pos.dy + 5), strokePaint);
      } else {
        // Gambar lingkaran gelembung kecil
        canvas.drawCircle(pos, 3, strokePaint);
        canvas.drawCircle(pos, 1.5, fillPaint..color = color.withOpacity(0.15));
      }
    }
  }

  void _drawTwinklingStars(Canvas canvas, Offset center, double loopVal, Color color) {
    final strokePaint = Paint()
      ..color = color.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    final starPositions = [
      Offset(center.dx - 110, center.dy - 50),
      Offset(center.dx + 110, center.dy - 60),
      Offset(center.dx - 100, center.dy + 70),
      Offset(center.dx + 110, center.dy + 50),
      Offset(center.dx - 30, center.dy - 80),
      Offset(center.dx + 40, center.dy + 90),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final offset = starPositions[i];
      final alphaFactor = 0.25 + 0.75 * math.sin(loopVal + i * 1.3);
      strokePaint.color = color.withOpacity(0.55 * alphaFactor);
      
      final starSize = 6.0 + 4.0 * alphaFactor;
      canvas.drawLine(Offset(offset.dx - starSize, offset.dy), Offset(offset.dx + starSize, offset.dy), strokePaint);
      canvas.drawLine(Offset(offset.dx, offset.dy - starSize), Offset(offset.dx, offset.dy + starSize), strokePaint);
    }
  }

  void _drawExpertClipboard(Canvas canvas, Offset center, double loopVal, Color color) {
    final boardPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final clipPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final clipStroke = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 1. Gambar Board (Clipboard) dengan Bayangan Menyala (Glow Shadow)
    final boardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 110, height: 140),
      const Radius.circular(16),
    );
    final glowPaint = Paint()
      ..color = color.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawRRect(boardRect.shift(const Offset(0, 5)), glowPaint);

    canvas.drawRRect(boardRect, boardPaint);
    canvas.drawRRect(boardRect, strokePaint);

    // 2. Gambar Klip Logam di bagian atas
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center - const Offset(0, 70), width: 50, height: 16),
      const Radius.circular(6),
    );
    canvas.drawRRect(clipRect, clipPaint);
    canvas.drawRRect(clipRect, clipStroke);

    // 3. Gambar Checklist Item
    final textColor = color.withOpacity(0.7);
    final checkColor = const Color(0xFF00C9A7); // Hijau checkmarks

    for (int i = 0; i < 3; i++) {
      final yOffset = center.dy - 35 + i * 35;
      
      // Kotak Checklist (14x14)
      final boxRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx - 35, yOffset), width: 14, height: 14),
        const Radius.circular(3),
      );
      canvas.drawRRect(boxRect, Paint()..color = color.withOpacity(0.06)..style = PaintingStyle.fill);
      canvas.drawRRect(boxRect, strokePaint..strokeWidth = 1.5);

      // Baris teks coretan tangan bergaya meliuk kustom
      final linePath = Path()
        ..moveTo(center.dx - 18, yOffset)
        ..quadraticBezierTo(center.dx + 10, yOffset + math.sin(loopVal + i) * 1.5, center.dx + 40, yOffset);
      canvas.drawPath(linePath, strokePaint..strokeWidth = 1.8..color = textColor);

      // Baris sub-teks di bawahnya
      final subLinePath = Path()
        ..moveTo(center.dx - 18, yOffset + 6)
        ..quadraticBezierTo(center.dx + 5, yOffset + 6 + math.cos(loopVal + i) * 1.0, center.dx + 20, yOffset + 6);
      canvas.drawPath(subLinePath, strokePaint..strokeWidth = 1.0..color = textColor.withOpacity(0.4));

      // Centang memantul / berdetak bergantian di dalam kotak
      final checkPulse = 0.5 + 0.5 * math.sin(loopVal * 1.5 - i * math.pi / 2);
      if (checkPulse > 0.3) {
        final checkPaint = Paint()
          ..color = checkColor.withOpacity(0.85 * checkPulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round;
        
        final checkPath = Path()
          ..moveTo(center.dx - 39, yOffset)
          ..lineTo(center.dx - 36, yOffset + 3)
          ..lineTo(center.dx - 31, yOffset - 3);
        canvas.drawPath(checkPath, checkPaint);

        // Efek riak melingkar meluas (Success ripple) saat tercentang
        final ripplePaint = Paint()
          ..color = checkColor.withOpacity(0.3 * (1.0 - (checkPulse - 0.3) / 0.7))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(Offset(center.dx - 35, yOffset), 8 + 12 * ((checkPulse - 0.3) / 0.7), ripplePaint);
      }
    }
  }

  void _drawMagnifyingGlass(Canvas canvas, Offset offset, double radius, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // 1. Gagang Kayu Kaca Pembesar (miring 45 derajat)
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(math.pi / 4);
    canvas.drawLine(
      Offset(0, radius),
      Offset(0, radius + 22),
      strokePaint..strokeWidth = 4.5..color = color.withOpacity(0.65),
    );
    canvas.restore();

    // 2. Lensa Kaca Pembesar (Lingkaran)
    canvas.drawCircle(offset, radius, paint);
    canvas.drawCircle(offset, radius, strokePaint..strokeWidth = 3.5);

    // 3. Efek Refleksi/Kilau Lensa
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final arcRect = Rect.fromCircle(center: offset, radius: radius * 0.7);
    canvas.drawArc(arcRect, -math.pi * 0.8, math.pi * 0.4, false, reflectionPaint);
  }

  void _drawLightbulbWithRays(Canvas canvas, Offset offset, double loopVal, Color color) {
    final bulbPulse = 1.0 + 0.08 * math.sin(loopVal * 1.8);
    final bulbSize = 26.0 * bulbPulse;
    
    // 1. Gambar aura cahaya lingkaran kuning tipis di belakang
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD460).withOpacity(0.12 * (1.0 + 0.3 * math.sin(loopVal * 1.8)))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(offset, bulbSize * 1.8, glowPaint);
    canvas.drawCircle(offset, bulbSize * 1.2, glowPaint..color = const Color(0xFFFFD460).withOpacity(0.18));
    
    // 2. Gambar pancaran sinar energi (Insight Rays)
    final rayPaint = Paint()
      ..color = const Color(0xFFFFB100).withOpacity(0.6 + 0.3 * math.sin(loopVal * 1.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = (i * 2 * math.pi / numRays) + (loopVal * 0.1);
      final rayStart = Offset(
        offset.dx + bulbSize * 0.9 * math.cos(angle),
        offset.dy + bulbSize * 0.9 * math.sin(angle),
      );
      final rayEnd = Offset(
        offset.dx + (bulbSize * 1.35 + 4 * math.sin(loopVal * 2.0 + i)) * math.cos(angle),
        offset.dy + (bulbSize * 1.35 + 4 * math.sin(loopVal * 2.0 + i)) * math.sin(angle),
      );
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
    
    // 3. Gambar Icon Lampu Ide
    _drawBouncingIcon(canvas, offset, Icons.lightbulb_rounded, bulbSize, const Color(0xFFFFD460));
    _drawBouncingIcon(canvas, offset, Icons.lightbulb_outline_rounded, bulbSize, const Color(0xFFFFB100));
  }

  void _drawFloatingPapers(Canvas canvas, Offset center, double loopVal, Color color) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    final paperPositions = [
      Offset(center.dx - 100, center.dy + 65),
      Offset(center.dx + 105, center.dy + 45),
      Offset(center.dx - 90, center.dy - 75),
    ];
    
    for (int i = 0; i < paperPositions.length; i++) {
      final pos = paperPositions[i];
      final floatY = math.sin(loopVal + i * 1.8) * 8.0;
      final floatAngle = math.cos(loopVal * 0.9 + i) * 0.15;
      
      canvas.save();
      canvas.translate(pos.dx, pos.dy + floatY);
      canvas.rotate(floatAngle);
      
      // Menggambar rect miring kertas kecil
      final rect = Rect.fromCenter(center: Offset.zero, width: 22, height: 28);
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, strokePaint);
      
      // Garis coretan teks di kertas
      canvas.drawLine(const Offset(-7, -8), const Offset(7, -8), strokePaint..strokeWidth = 1.0);
      canvas.drawLine(const Offset(-7, -2), const Offset(4, -2), strokePaint);
      canvas.drawLine(const Offset(-7, 4), const Offset(6, 4), strokePaint);
      
      canvas.restore();
    }
  }

  void _drawMoodSineWave(Canvas canvas, Size size, Offset center, double loopVal, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = size.width * 0.05;
    final endX = size.width * 0.95;
    final yCenter = center.dy + 30;

    path.moveTo(startX, yCenter);
    for (double x = startX; x <= endX; x += 6) {
      final relativeX = x / size.width;
      final y = yCenter + 22 * math.sin(loopVal + relativeX * 2.8 * math.pi);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Garis bantu tipis bermotif putus-putus di atasnya
    final dashPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final pathDash = Path();
    pathDash.moveTo(startX, yCenter - 35);
    for (double x = startX; x <= endX; x += 15) {
      final relativeX = x / size.width;
      final y = yCenter - 35 + 22 * math.sin(loopVal + relativeX * 2.8 * math.pi);
      pathDash.lineTo(x, y);
      pathDash.moveTo(x + 8, yCenter - 35 + 22 * math.sin(loopVal + (x + 8) / size.width * 2.8 * math.pi));
    }
    canvas.drawPath(pathDash, dashPaint);
  }

  void _drawRisingBubbles(Canvas canvas, Size size, double loopVal, Color color) {
    final strokePaint = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final bubblePositions = [
      Offset(size.width * 0.12, size.height * 0.4 - (loopVal * 10) % 180),
      Offset(size.width * 0.28, size.height * 0.35 - ((loopVal + 2) * 12) % 180),
      Offset(size.width * 0.72, size.height * 0.43 - ((loopVal + 4) * 8) % 180),
      Offset(size.width * 0.88, size.height * 0.38 - ((loopVal + 1) * 15) % 180),
    ];

    for (var pos in bubblePositions) {
      canvas.drawCircle(pos, 4.0 + (pos.dy % 3), strokePaint);
      canvas.drawCircle(pos - const Offset(1, 1), 1, Paint()..color = Colors.white.withOpacity(0.3));
    }
  }

  void _drawEmojiBalloon(Canvas canvas, Offset offset, double radius, IconData icon, Color color, double angle) {
    final paint = Paint()
      ..color = color.withOpacity(0.14)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle);

    // Balon Lingkaran
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.drawCircle(Offset.zero, radius, strokePaint);

    // Simpul Segitiga Balon di Bawah
    final triPath = Path()
      ..moveTo(-3, radius)
      ..lineTo(3, radius)
      ..lineTo(0, radius + 5)
      ..close();
    canvas.drawPath(triPath, paint..color = color.withOpacity(0.35));
    canvas.drawPath(triPath, strokePaint);

    // Tali Balon Bergelombang
    final stringPath = Path()
      ..moveTo(0, radius + 5)
      ..quadraticBezierTo(5, radius + 15, -2, radius + 28)
      ..quadraticBezierTo(2, radius + 35, 0, radius + 45);
    canvas.drawPath(stringPath, strokePaint..strokeWidth = 1.2..color = color.withOpacity(0.4));

    // Emoji Icon di Dalam Balon
    _drawBouncingIcon(canvas, Offset.zero, icon, radius * 1.2, color.withOpacity(0.8));

    canvas.restore();
  }

  void _drawWindBreeze(Canvas canvas, Size size, Offset center, double loopVal, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final yCenter = center.dy;
    final startX = size.width * 0.05;
    final endX = size.width * 0.95;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final offsetOffset = i * 25 - 25;
      path.moveTo(startX, yCenter + offsetOffset);
      for (double x = startX; x <= endX; x += 12) {
        final relativeX = x / size.width;
        final y = yCenter + offsetOffset + 18 * math.sin(loopVal + relativeX * 1.5 * math.pi + i * math.pi / 3);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint..color = color.withOpacity(0.12 - i * 0.035));
    }
  }

  void _drawBreathingWaves(Canvas canvas, Offset offset, double radius, Color color) {
    final fillPaint = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 4 Tingkat Riak Napas Konsentris
    canvas.drawCircle(offset, radius, fillPaint);
    canvas.drawCircle(offset, radius, strokePaint);

    canvas.drawCircle(offset, radius * 0.8, strokePaint..color = color.withOpacity(0.22));
    canvas.drawCircle(offset, radius * 0.6, strokePaint..color = color.withOpacity(0.14));
    canvas.drawCircle(offset, radius * 0.4, strokePaint..color = color.withOpacity(0.08));
  }

  void _drawFloatingLeaves(Canvas canvas, Offset center, double loopVal, Color color) {
    final leafPaint = Paint()
      ..color = color.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final leafOffsets = [
      Offset(center.dx - 100, center.dy + 50 + math.sin(loopVal) * 12),
      Offset(center.dx + 100, center.dy - 50 + math.cos(loopVal) * 14),
      Offset(center.dx - 80, center.dy - 70 + math.cos(loopVal * 1.1) * 8),
      Offset(center.dx + 80, center.dy + 70 + math.sin(loopVal * 0.9) * 10),
    ];

    for (int i = 0; i < leafOffsets.length; i++) {
      final pos = leafOffsets[i];
      final angle = (i % 2 == 0) ? 0.35 + i * 0.2 : -0.4 - i * 0.15;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + math.sin(loopVal + i) * 0.18);
      
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-8, -12, 0, -24)
        ..quadraticBezierTo(8, -12, 0, 0);
      canvas.drawPath(path, leafPaint);
      canvas.drawLine(const Offset(0, 0), const Offset(0, -20), leafPaint);
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
        shadows: [
          Shadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 6,
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
  }

  void _drawPulsingHeart(Canvas canvas, Offset offset, double size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
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

  @override
  bool shouldRepaint(covariant OnboardingDoodlePainter oldDelegate) {
    return oldDelegate.pageIndex != pageIndex ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}

extension OffsetExtension on Offset {
  double offsetY(double delta) => dy + delta;
}

