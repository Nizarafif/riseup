import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    // Animasi kontinu lambat yang sangat menenangkan untuk halaman login/register
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base Calm Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F0FE), // Biru pastel tenang
                    Color(0xFFFDF2F8), // Pink ceria pastel lembut
                  ],
                ),
              ),
            ),
            // Programmatic Hand-Drawn Doodles Ber-animasi
            Positioned.fill(
              child: CustomPaint(
                painter: DoodlePainter(animationValue: _controller.value),
              ),
            ),
            // Content overlay
            Positioned.fill(child: widget.child),
          ],
        );
      },
    );
  }
}

class DoodlePainter extends CustomPainter {
  final double animationValue;

  DoodlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
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

  void _drawCloud(Canvas canvas, Offset center, double radius, Paint paint) {
    paint.color = Colors.white.withOpacity(0.85);
    
    // 3 overlapping circles
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.6, center.dy + radius * 0.1), radius * 0.75, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.6, center.dy + radius * 0.1), radius * 0.75, paint);

    // Drawing facial expressions
    final linePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Eyes (sleeping/curved arcs)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx - radius * 0.25, center.dy - radius * 0.05), radius: 3.5),
      math.pi, math.pi, false, linePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx + radius * 0.25, center.dy - radius * 0.05), radius: 3.5),
      math.pi, math.pi, false, linePaint,
    );
    
    // Happy Smiling Mouth
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + radius * 0.15), radius: 4.5),
      0, math.pi, false, linePaint,
    );

    // Cute pink cheeks
    final cheekPaint = Paint()
      ..color = const Color(0xFFFDA4AF).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - radius * 0.4, center.dy + radius * 0.15), 4, cheekPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy + radius * 0.15), 4, cheekPaint);
  }

  void _drawSun(Canvas canvas, Offset center, double radius, Paint paint, double loopVal) {
    final pulseRadius = radius * (1.0 + 0.04 * math.sin(loopVal * 1.5));
    // Glow ring
    paint.color = const Color(0xFFFEF08A).withOpacity(0.35 + 0.1 * math.sin(loopVal));
    canvas.drawCircle(center, pulseRadius * 1.35, paint);

    // Sun core
    paint.color = const Color(0xFFFACC15);
    canvas.drawCircle(center, pulseRadius, paint);

    // Drawing cute sun eyes & smile
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

    // Ray lines (rotating slowly)
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
    return oldDelegate.animationValue != animationValue;
  }
}
