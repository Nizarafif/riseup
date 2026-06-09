import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../providers/auth_provider.dart';

class DoodleBackground extends StatefulWidget {
  final Widget child;

  const DoodleBackground({super.key, required this.child});

  @override
  State<DoodleBackground> createState() => _DoodleBackgroundState();
}

class _DoodleBackgroundState extends State<DoodleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animasi kontinu lambat yang sangat menenangkan
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeIndex = authProvider.selectedBackgroundThemeIndex;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base Calm Gradient berdasarkan tipe tema
            Container(
              decoration: BoxDecoration(
                gradient: _getGradient(themeIndex),
              ),
            ),
            // Custom Painter Dinamis
            Positioned.fill(
              child: CustomPaint(
                painter: DoodlePainter(
                  animationValue: _controller.value,
                  themeIndex: themeIndex,
                ),
              ),
            ),
            // Content overlay
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }

  LinearGradient _getGradient(int themeIndex) {
    if (themeIndex == 1) {
      // Liquid Blobs: Mint Green to Cool Gray/Blue
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE8F5E9),
          Color(0xFFECEFF1),
        ],
      );
    } else if (themeIndex == 2) {
      // Starry Night: Deep Indigo to Midnight Purple
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF16162D),
          Color(0xFF090715),
        ],
      );
    } else {
      // Classic Doodle: Biru pastel ke Pink pastel
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE8F0FE),
          Color(0xFFFDF2F8),
        ],
      );
    }
  }
}

class DoodlePainter extends CustomPainter {
  final double animationValue;
  final int themeIndex;

  DoodlePainter({required this.animationValue, required this.themeIndex});

  @override
  void paint(Canvas canvas, Size size) {
    if (themeIndex == 1) {
      _paintLiquidBlobs(canvas, size);
    } else if (themeIndex == 2) {
      _paintStarryNight(canvas, size);
    } else {
      _paintClassicDoodle(canvas, size);
    }
  }

  void _paintClassicDoodle(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final loopVal = animationValue * 2 * math.pi;

    // 1. Gambar ombak hijau mint yang bergerak mengayun lembut di bagian bawah
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
    paint.color = const Color(0xFFE2F1E8).withOpacity(0.75); // Soft Mint Green
    canvas.drawPath(wavePath, paint);

    // 2. Gambar awan tersenyum top-right yang melayang perlahan
    final cloud1Offset = Offset(
      310.0 + math.sin(loopVal * 0.8) * 12.0,
      100.0 + math.cos(loopVal * 0.6) * 6.0,
    );
    _drawCloud(canvas, cloud1Offset, 38, paint);
    
    // 3. Gambar awan tersenyum top-left yang melayang perlahan
    final cloud2Offset = Offset(
      65.0 + math.cos(loopVal * 0.6) * 10.0,
      150.0 + math.sin(loopVal * 0.8) * 5.0,
    );
    _drawCloud(canvas, cloud2Offset, 28, paint);

    // 4. Gambar matahari tersenyum dengan sinar berputar perlahan
    _drawSun(canvas, const Offset(210, 75), 22, paint, loopVal);

    // 5. Gambar bintang-bintang pastel berkelip manis (twinkling)
    _drawStar(canvas, const Offset(150, 110), 10, const Color(0xFFFDE047), loopVal, 0); // Yellow
    _drawStar(canvas, const Offset(260, 210), 7, const Color(0xFFFEF08A), loopVal, 1);  // Soft Yellow
    _drawStar(canvas, const Offset(60, 480), 9, const Color(0xFFFDE047), loopVal, 2);   // Yellow
    _drawStar(canvas, const Offset(300, 360), 8, const Color(0xFFFEF08A), loopVal, 3);  // Soft Yellow

    // 6. Gambar hati merah muda berdenyut lembut (pulsing)
    _drawHeart(canvas, const Offset(110, 240), 11, const Color(0xFFFDA4AF), loopVal, 0); // Pink
    _drawHeart(canvas, const Offset(270, 490), 14, const Color(0xFFFECDD3), loopVal, 1); // Soft Rose
    _drawHeart(canvas, const Offset(40, 60), 8, const Color(0xFFFDA4AF), loopVal, 2);    // Pink
    _drawHeart(canvas, const Offset(320, 270), 10, const Color(0xFFFECDD3), loopVal, 3); // Soft Rose
  }

  void _paintLiquidBlobs(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final loopVal = animationValue * 2 * math.pi;

    // Blob 1: Soft Purple (Top Left)
    final blob1Center = Offset(
      size.width * 0.15 + math.sin(loopVal * 0.5) * 35.0,
      size.height * 0.25 + math.cos(loopVal * 0.4) * 40.0,
    );
    paint.color = const Color(0xFFE9D5FF).withOpacity(0.42);
    canvas.drawCircle(blob1Center, 135, paint);

    // Blob 2: Soft Sky Blue (Bottom Right)
    final blob2Center = Offset(
      size.width * 0.85 + math.cos(loopVal * 0.4) * 40.0,
      size.height * 0.70 + math.sin(loopVal * 0.5) * 30.0,
    );
    paint.color = const Color(0xFFBAE6FD).withOpacity(0.45);
    canvas.drawCircle(blob2Center, 160, paint);

    // Blob 3: Soft Mint Green (Center Left)
    final blob3Center = Offset(
      size.width * 0.30 + math.cos(loopVal * 0.3) * 25.0,
      size.height * 0.75 + math.sin(loopVal * 0.4) * 35.0,
    );
    paint.color = const Color(0xFFA7F3D0).withOpacity(0.38);
    canvas.drawCircle(blob3Center, 140, paint);

    // Blob 4: Soft Pink (Top Right)
    final blob4Center = Offset(
      size.width * 0.80 + math.sin(loopVal * 0.4) * 30.0,
      size.height * 0.15 + math.cos(loopVal * 0.3) * 25.0,
    );
    paint.color = const Color(0xFFFDE2E4).withOpacity(0.40);
    canvas.drawCircle(blob4Center, 115, paint);
    
    // Wave gembul menenangkan di bagian bawah
    final wavePath = Path()
      ..moveTo(0, size.height * 0.95 + math.sin(loopVal) * 6)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.92 + math.cos(loopVal) * 8,
        size.width * 0.6, size.height * 0.96 + math.sin(loopVal) * 7,
      )
      ..quadraticBezierTo(
        size.width * 0.85, size.height * 0.93 + math.cos(loopVal) * 5,
        size.width, size.height * 0.95 + math.sin(loopVal) * 4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    paint.color = const Color(0xFFF1F5F9).withOpacity(0.5);
    canvas.drawPath(wavePath, paint);
  }

  void _paintStarryNight(Canvas canvas, Size size) {
    final loopVal = animationValue * 2 * math.pi;

    // 1. Rasi Bintang (Fine Lines)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawLine(const Offset(60, 150), const Offset(120, 180), linePaint);
    canvas.drawLine(const Offset(120, 180), const Offset(90, 240), linePaint);
    canvas.drawLine(const Offset(90, 240), const Offset(160, 220), linePaint);

    canvas.drawLine(const Offset(280, 320), const Offset(310, 390), linePaint);
    canvas.drawLine(const Offset(310, 390), const Offset(250, 420), linePaint);

    // 2. Bulan Sabit Tersenyum Imut (Crescent Moon)
    _drawCrescentMoon(canvas, Offset(size.width * 0.78, 120), 26, loopVal);

    // 3. Bintang Twinkling Emas
    _drawStar(canvas, const Offset(60, 150), 6, const Color(0xFFFDE047), loopVal, 0);
    _drawStar(canvas, const Offset(120, 180), 5, const Color(0xFFFEF08A), loopVal, 1);
    _drawStar(canvas, const Offset(90, 240), 7, const Color(0xFFFDE047), loopVal, 2);
    _drawStar(canvas, const Offset(160, 220), 5, const Color(0xFFFEF08A), loopVal, 3);
    
    _drawStar(canvas, const Offset(280, 320), 6, const Color(0xFFFDE047), loopVal, 4);
    _drawStar(canvas, const Offset(310, 390), 8, const Color(0xFFFEF08A), loopVal, 5);
    _drawStar(canvas, const Offset(250, 420), 5, const Color(0xFFFDE047), loopVal, 6);

    _drawStar(canvas, const Offset(70, 500), 7, const Color(0xFFFDE047), loopVal, 7);
    _drawStar(canvas, const Offset(310, 540), 6, const Color(0xFFFEF08A), loopVal, 8);
    _drawStar(canvas, const Offset(180, 620), 5, const Color(0xFFFDE047), loopVal, 9);

    // 4. Bintang Jatuh (Shooting Star)
    final double shootProgress = (animationValue * 3) % 1.0;
    if (shootProgress < 0.25) {
      final double progress = shootProgress / 0.25;
      final startX = size.width * 0.8;
      final startY = size.height * 0.15;
      final currentX = startX - progress * 150.0;
      final currentY = startY + progress * 90.0;
      
      final shootPaint = Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.0)],
        ).createShader(Rect.fromPoints(Offset(currentX, currentY), Offset(currentX + 50, currentY - 30)))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX + 40, currentY - 24),
        shootPaint,
      );
    }
  }

  void _drawCrescentMoon(Canvas canvas, Offset center, double radius, double loopVal) {
    final pulseRadius = radius * (1.0 + 0.03 * math.sin(loopVal * 1.5));
    final paint = Paint()
      ..color = const Color(0xFFFEF08A).withOpacity(0.20)
      ..style = PaintingStyle.fill;
    
    // Moon glow
    canvas.drawCircle(center, pulseRadius * 1.3, paint);

    // Moon body
    final Path moonPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: pulseRadius));
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(center.dx - pulseRadius * 0.45, center.dy - pulseRadius * 0.2), radius: pulseRadius * 0.95));
    
    final Path crescentPath = Path.combine(PathOperation.difference, moonPath, shadowPath);
    paint.color = const Color(0xFFFDE047);
    canvas.drawPath(crescentPath, paint);

    // Cute face
    final facePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final Offset eyeOffset = Offset(center.dx + pulseRadius * 0.22, center.dy - pulseRadius * 0.12);
    canvas.drawArc(
      Rect.fromCircle(center: eyeOffset, radius: 2.2),
      math.pi,
      math.pi,
      false,
      facePaint,
    );

    final Offset mouthOffset = Offset(center.dx + pulseRadius * 0.3, center.dy + pulseRadius * 0.05);
    canvas.drawArc(
      Rect.fromCircle(center: mouthOffset, radius: 2.8),
      0,
      math.pi,
      false,
      facePaint,
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    paint.color = Colors.white.withOpacity(0.85);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.6, center.dy + radius * 0.1), radius * 0.75, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.6, center.dy + radius * 0.1), radius * 0.75, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.05), radius: 3.5),
      math.pi, math.pi, false, linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.05), radius: 3.5),
      math.pi, math.pi, false, linePaint,
    );
    
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + radius * 0.15), radius: 4.5),
      0, math.pi, false, linePaint,
    );

    final cheekPaint = Paint()
      ..color = const Color(0xFFFDA4AF).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - radius * 0.4, center.dy + radius * 0.15), 4, cheekPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy + radius * 0.15), 4, cheekPaint);
  }

  void _drawSun(Canvas canvas, Offset center, double radius, Paint paint, double loopVal) {
    final pulseRadius = radius * (1.0 + 0.04 * math.sin(loopVal * 1.5));
    paint.color = const Color(0xFFFEF08A).withOpacity(0.35 + 0.1 * math.sin(loopVal));
    canvas.drawCircle(center, pulseRadius * 1.35, paint);

    paint.color = const Color(0xFFFACC15);
    canvas.drawCircle(center, pulseRadius, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(center.dx - pulseRadius * 0.25, center.dy - pulseRadius * 0.1), 1.5, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawCircle(Offset(center.dx + pulseRadius * 0.25, center.dy - pulseRadius * 0.1), 1.5, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + pulseRadius * 0.1), radius: 3.5),
      0, math.pi, false, linePaint,
    );

    final rayPaint = Paint()
      ..color = const Color(0xFFFACC15).withOpacity(0.9)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      double angle = i * (math.pi / 4) + (loopVal * 0.2);
      double startX = center.dx + (pulseRadius * 1.22) * math.cos(angle);
      double startY = center.dy + (pulseRadius * 1.22) * math.sin(angle);
      double endX = center.dx + (pulseRadius * 1.45) * math.cos(angle);
      double endY = center.dy + (pulseRadius * 1.45) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color, double loopVal, int index) {
    final starPulse = 0.5 + 0.5 * math.sin(loopVal * 1.6 + index * 1.2);
    final pulseSize = size * (0.7 + 0.3 * starPulse);
    
    final paint = Paint()
      ..color = color.withOpacity(0.4 + 0.55 * starPulse)
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
      ..color = color.withOpacity(0.55 + 0.4 * math.sin(loopVal * 2.2 + index * 1.5))
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
  bool shouldRepaint(covariant DoodlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.themeIndex != themeIndex;
  }
}
