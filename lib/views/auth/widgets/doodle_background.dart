import 'package:flutter/material.dart';
import 'dart:math' as math;

class DoodleBackground extends StatelessWidget {
  final Widget child;

  const DoodleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
        // Programmatic Hand-Drawn Doodles
        Positioned.fill(
          child: CustomPaint(
            painter: DoodlePainter(),
          ),
        ),
        // Content overlay
        Positioned.fill(child: child),
      ],
    );
  }
}

class DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Draw soft green/blue wave at the very bottom
    final wavePath = Path()
      ..moveTo(0, size.height * 0.93)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.90, size.width * 0.5, size.height * 0.94)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.98, size.width, size.height * 0.92)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    paint.color = const Color(0xFFE2F1E8).withOpacity(0.75); // Soft Mint Green
    canvas.drawPath(wavePath, paint);

    // 2. Draw a cute smiling cloud in the top-right
    _drawCloud(canvas, const Offset(310, 100), 38, paint);
    
    // 3. Draw a smiling cloud in the top-left
    _drawCloud(canvas, const Offset(65, 150), 28, paint);

    // 4. Draw a small smiling sun near the top center-right
    _drawSun(canvas, const Offset(210, 75), 22, paint);

    // 5. Draw some pastel-colored stars
    _drawStar(canvas, const Offset(150, 110), 10, const Color(0xFFFDE047)); // Yellow
    _drawStar(canvas, const Offset(260, 210), 7, const Color(0xFFFEF08A));  // Soft Yellow
    _drawStar(canvas, const Offset(60, 480), 9, const Color(0xFFFDE047));   // Yellow
    _drawStar(canvas, const Offset(300, 360), 8, const Color(0xFFFEF08A));  // Soft Yellow

    // 6. Draw some cute pink hearts
    _drawHeart(canvas, const Offset(110, 240), 11, const Color(0xFFFDA4AF)); // Pink
    _drawHeart(canvas, const Offset(270, 490), 14, const Color(0xFFFECDD3)); // Soft Rose
    _drawHeart(canvas, const Offset(40, 60), 8, const Color(0xFFFDA4AF));    // Pink
    _drawHeart(canvas, const Offset(320, 270), 10, const Color(0xFFFECDD3)); // Soft Rose
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

  void _drawSun(Canvas canvas, Offset center, double radius, Paint paint) {
    // Glow ring
    paint.color = const Color(0xFFFEF08A).withOpacity(0.4);
    canvas.drawCircle(center, radius * 1.35, paint);

    // Sun core
    paint.color = const Color(0xFFFACC15);
    canvas.drawCircle(center, radius, paint);

    // Drawing cute sun eyes & smile
    final linePaint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.1), 1.5, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawCircle(Offset(center.dx + radius * 0.25, center.dy - radius * 0.1), 1.5, Paint()..color = const Color(0xFF4A4A4A));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + radius * 0.1), radius: 3.5),
      0, math.pi, false, linePaint,
    );

    // Ray lines
    final rayPaint = Paint()
      ..color = const Color(0xFFFACC15).withOpacity(0.9)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      double angle = i * (math.pi / 4);
      double startX = center.dx + (radius * 1.22) * math.cos(angle);
      double startY = center.dy + (radius * 1.22) * math.sin(angle);
      double endX = center.dx + (radius * 1.45) * math.cos(angle);
      double endY = center.dy + (radius * 1.45) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.25, center.dy - size * 0.25);
    path.lineTo(center.dx + size, center.dy - size * 0.1);
    path.lineTo(center.dx + size * 0.4, center.dy + size * 0.3);
    path.lineTo(center.dx + size * 0.55, center.dy + size);
    path.lineTo(center.dx, center.dy + size * 0.55);
    path.lineTo(center.dx - size * 0.55, center.dy + size);
    path.lineTo(center.dx - size * 0.4, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy - size * 0.1);
    path.lineTo(center.dx - size * 0.25, center.dy - size * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double width, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy + width * 0.35);
    path.cubicTo(
      center.dx - width * 0.6, center.dy - width * 0.5,
      center.dx - width * 1.1, center.dy + width * 0.2,
      center.dx, center.dy + width * 0.95,
    );
    path.cubicTo(
      center.dx + width * 1.1, center.dy + width * 0.2,
      center.dx + width * 0.6, center.dy - width * 0.5,
      center.dx, center.dy + width * 0.35,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
