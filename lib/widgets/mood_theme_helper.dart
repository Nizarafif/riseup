import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodPalette {
  final String name;
  final List<Color> colors;

  const MoodPalette({required this.name, required this.colors});
}

class MoodThemeHelper {
  // 4 Pilihan Palet Warna (Tingkat 1 sampai 5)
  static const List<MoodPalette> palettes = [
    MoodPalette(
      name: 'Calm Pastel',
      colors: [
        Color(0xFFFCA5A5), // 1: Sangat Buruk (Soft Red)
        Color(0xFFFED7AA), // 2: Buruk (Soft Orange)
        Color(0xFFDBEAFE), // 3: Normal (Soft Blue)
        Color(0xFFD9F99D), // 4: Baik (Soft Lime)
        Color(0xFF99F6E4), // 5: Sangat Baik (Soft Teal)
      ],
    ),
    MoodPalette(
      name: 'Cute Candy',
      colors: [
        Color(0xFFFDA4AF), // 1: Sangat Buruk (Rose Pink)
        Color(0xFFFFEDD5), // 2: Buruk (Warm Cream)
        Color(0xFFE9D5FF), // 3: Normal (Soft Lavender)
        Color(0xFFBAE6FD), // 4: Baik (Sky Blue)
        Color(0xFFA7F3D0), // 5: Sangat Baik (Mint Green)
      ],
    ),
    MoodPalette(
      name: 'Retro Forest',
      colors: [
        Color(0xFFEF4444), // 1: Sangat Buruk (Vibrant Red)
        Color(0xFFF97316), // 2: Buruk (Orange)
        Color(0xFFFACC15), // 3: Normal (Yellow)
        Color(0xFF84CC16), // 4: Baik (Lime)
        Color(0xFF10B981), // 5: Sangat Baik (Emerald)
      ],
    ),
    MoodPalette(
      name: 'Warm Sunset',
      colors: [
        Color(0xFFB91C1C), // 1: Sangat Buruk (Dark Red)
        Color(0xFFEA580C), // 2: Buruk (Rust Orange)
        Color(0xFFFBBF24), // 3: Normal (Amber)
        Color(0xFFF87171), // 4: Baik (Peach Coral)
        Color(0xFFFECDD3), // 5: Sangat Baik (Rose Gold)
      ],
    ),
  ];

  static List<Color> getPaletteColors(int index) {
    if (index < 0 || index >= palettes.length) return palettes[0].colors;
    return palettes[index].colors;
  }

  static Color getMoodColor(int paletteIndex, int moodLevel) {
    final colors = getPaletteColors(paletteIndex);
    int idx = moodLevel - 1;
    if (idx < 0) idx = 0;
    if (idx >= colors.length) idx = colors.length - 1;
    return colors[idx];
  }

  static String getMoodName(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Normal';
      case 4:
        return 'Baik';
      case 5:
        return 'Sangat Baik';
      default:
        return 'Normal';
    }
  }
}

class MoodEmojiWidget extends StatelessWidget {
  final int level; // 1 to 5
  final double size;
  final int paletteIndex;
  final int emojiThemeIndex;
  final bool isSelected;

  const MoodEmojiWidget({
    super.key,
    required this.level,
    this.size = 50,
    this.paletteIndex = 0,
    this.emojiThemeIndex = 0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = MoodThemeHelper.getMoodColor(paletteIndex, level);
    
    return Container(
      width: size,
      height: size,
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: MoodEmojiPainter(
          level: level,
          color: color,
          themeIndex: emojiThemeIndex,
        ),
      ),
    );
  }
}

class MoodEmojiPainter extends CustomPainter {
  final int level;
  final Color color;
  final int themeIndex;

  MoodEmojiPainter({
    required this.level,
    required this.color,
    required this.themeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..isAntiAlias = true;

    // Menentukan jenis gambar wajah (Isi atau Outline)
    final bool isOutline = themeIndex == 1;
    final bool hasEars = themeIndex == 2;
    final bool isCloud = themeIndex == 3;
    final bool isStar = themeIndex == 4;
    final bool isBoxy = themeIndex == 5;
    final bool isHeart = themeIndex == 6;
    final bool isFlower = themeIndex == 7;
    final bool isCat = themeIndex == 8;
    final bool isGhost = themeIndex == 9;

    // 1. Gambar Telinga Lucu (Jika Tema == 2 - Cute Animal Ears atau Tema == 8 - Cute Kitty Cats)
    if (hasEars) {
      paint.style = PaintingStyle.fill;
      paint.color = color;
      
      // Telinga Kiri
      final earLeftPath = Path()
        ..moveTo(center.dx - radius * 0.9, center.dy - radius * 0.4)
        ..cubicTo(
          center.dx - radius * 1.1, center.dy - radius * 1.1,
          center.dx - radius * 0.3, center.dy - radius * 1.1,
          center.dx - radius * 0.4, center.dy - radius * 0.8,
        )
        ..close();
      canvas.drawPath(earLeftPath, paint);

      // Telinga Kanan
      final earRightPath = Path()
        ..moveTo(center.dx + radius * 0.9, center.dy - radius * 0.4)
        ..cubicTo(
          center.dx + radius * 1.1, center.dy - radius * 1.1,
          center.dx + radius * 0.3, center.dy - radius * 1.1,
          center.dx + radius * 0.4, center.dy - radius * 0.8,
        )
        ..close();
      canvas.drawPath(earRightPath, paint);

      // Bagian Dalam Telinga Kiri (Pink)
      paint.color = const Color(0xFFFDA4AF); // Sweet Pink
      final earLeftInner = Path()
        ..moveTo(center.dx - radius * 0.75, center.dy - radius * 0.5)
        ..cubicTo(
          center.dx - radius * 0.9, center.dy - radius * 0.9,
          center.dx - radius * 0.5, center.dy - radius * 0.9,
          center.dx - radius * 0.5, center.dy - radius * 0.75,
        )
        ..close();
      canvas.drawPath(earLeftInner, paint);

      // Bagian Dalam Telinga Kanan (Pink)
      final earRightInner = Path()
        ..moveTo(center.dx + radius * 0.75, center.dy - radius * 0.5)
        ..cubicTo(
          center.dx + radius * 0.9, center.dy - radius * 0.9,
          center.dx + radius * 0.5, center.dy - radius * 0.9,
          center.dx + radius * 0.5, center.dy - radius * 0.75,
        )
        ..close();
      canvas.drawPath(earRightInner, paint);
    } else if (isCat) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      // Telinga Kiri Kucing (Pointy)
      final earLeftPath = Path()
        ..moveTo(center.dx - radius * 0.8, center.dy - radius * 0.4)
        ..lineTo(center.dx - radius * 0.95, center.dy - radius * 1.05)
        ..lineTo(center.dx - radius * 0.3, center.dy - radius * 0.8)
        ..close();
      canvas.drawPath(earLeftPath, paint);

      // Telinga Kanan Kucing (Pointy)
      final earRightPath = Path()
        ..moveTo(center.dx + radius * 0.8, center.dy - radius * 0.4)
        ..lineTo(center.dx + radius * 0.95, center.dy - radius * 1.05)
        ..lineTo(center.dx + radius * 0.3, center.dy - radius * 0.8)
        ..close();
      canvas.drawPath(earRightPath, paint);

      // Bagian Dalam Telinga Kiri (Pink)
      paint.color = const Color(0xFFFDA4AF); // Sweet Pink
      final earLeftInner = Path()
        ..moveTo(center.dx - radius * 0.7, center.dy - radius * 0.5)
        ..lineTo(center.dx - radius * 0.82, center.dy - radius * 0.92)
        ..lineTo(center.dx - radius * 0.42, center.dy - radius * 0.75)
        ..close();
      canvas.drawPath(earLeftInner, paint);

      // Bagian Dalam Telinga Kanan (Pink)
      final earRightInner = Path()
        ..moveTo(center.dx + radius * 0.7, center.dy - radius * 0.5)
        ..lineTo(center.dx + radius * 0.82, center.dy - radius * 0.92)
        ..lineTo(center.dx + radius * 0.42, center.dy - radius * 0.75)
        ..close();
      canvas.drawPath(earRightInner, paint);
    }

    // 2. Gambar Wajah Utama sesuai Tema
    if (isCloud) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      // Gambar 3 lingkaran gembul bertumpuk (Awan)
      canvas.drawCircle(center, radius * 0.65, paint);
      canvas.drawCircle(Offset(center.dx - radius * 0.45, center.dy + radius * 0.1), radius * 0.48, paint);
      canvas.drawCircle(Offset(center.dx + radius * 0.45, center.dy + radius * 0.1), radius * 0.48, paint);
      
      final bottomRect = Rect.fromLTRB(
        center.dx - radius * 0.45,
        center.dy,
        center.dx + radius * 0.45,
        center.dy + radius * 0.58,
      );
      canvas.drawRect(bottomRect, paint);

      final whiteBorder = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04);
      
      final borderPath = Path()
        ..moveTo(center.dx - radius * 0.9, center.dy + radius * 0.58)
        ..lineTo(center.dx + radius * 0.9, center.dy + radius * 0.58)
        ..arcToPoint(Offset(center.dx + radius * 0.45, center.dy - radius * 0.38), radius: Radius.circular(radius * 0.48))
        ..arcToPoint(Offset(center.dx - radius * 0.45, center.dy - radius * 0.38), radius: Radius.circular(radius * 0.65))
        ..arcToPoint(Offset(center.dx - radius * 0.9, center.dy + radius * 0.58), radius: Radius.circular(radius * 0.48))
        ..close();
      canvas.drawPath(borderPath, whiteBorder);
    } else if (isStar) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      final starPath = Path();
      final double angle = math.pi / 5;
      for (int i = 0; i < 10; i++) {
        final double r = (i % 2 == 0) ? radius : radius * 0.45;
        final double currentAngle = i * angle;
        final double x = center.dx + r * math.sin(currentAngle);
        final double y = center.dy - r * math.cos(currentAngle);
        if (i == 0) {
          starPath.moveTo(x, y);
        } else {
          starPath.lineTo(x, y);
        }
      }
      starPath.close();
      canvas.drawPath(starPath, paint);

      final whiteBorder = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04);
      canvas.drawPath(starPath, whiteBorder);
    } else if (isBoxy) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      final boxRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width * 0.88, height: size.height * 0.88),
        const Radius.circular(16),
      );
      canvas.drawRRect(boxRect, paint);

      final whiteBorder = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04);
      canvas.drawRRect(boxRect, whiteBorder);
    } else if (isHeart) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      final heartPath = Path();
      heartPath.moveTo(center.dx, center.dy + radius * 0.95);
      heartPath.cubicTo(
        center.dx - radius * 1.1, center.dy + radius * 0.2,
        center.dx - radius * 1.0, center.dy - radius * 0.9,
        center.dx, center.dy - radius * 0.45,
      );
      heartPath.cubicTo(
        center.dx + radius * 1.0, center.dy - radius * 0.9,
        center.dx + radius * 1.1, center.dy + radius * 0.2,
        center.dx, center.dy + radius * 0.95,
      );
      heartPath.close();
      canvas.drawPath(heartPath, paint);

      final whiteBorder = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04);
      canvas.drawPath(heartPath, whiteBorder);
    } else if (isFlower) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      final petalRadius = radius * 0.38;
      final dist = radius * 0.55;
      for (int i = 0; i < 6; i++) {
        final double angle = i * math.pi / 3;
        final petalCenter = Offset(
          center.dx + dist * math.cos(angle),
          center.dy + dist * math.sin(angle),
        );
        canvas.drawCircle(petalCenter, petalRadius, paint);
      }
      canvas.drawCircle(center, radius * 0.5, paint);

      final whiteBorder = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04);
      for (int i = 0; i < 6; i++) {
        final double angle = i * math.pi / 3;
        final petalCenter = Offset(
          center.dx + dist * math.cos(angle),
          center.dy + dist * math.sin(angle),
        );
        canvas.drawCircle(petalCenter, petalRadius, whiteBorder);
      }
      canvas.drawCircle(center, radius * 0.5, whiteBorder);
    } else if (isGhost) {
      paint.style = PaintingStyle.fill;
      paint.color = color;

      final ghostPath = Path();
      ghostPath.moveTo(center.dx - radius * 0.8, center.dy + radius * 0.8);
      ghostPath.lineTo(center.dx - radius * 0.8, center.dy - radius * 0.1);
      ghostPath.arcToPoint(
        Offset(center.dx + radius * 0.8, center.dy - radius * 0.1),
        radius: Radius.circular(radius * 0.8),
        clockwise: true,
      );
      ghostPath.lineTo(center.dx + radius * 0.8, center.dy + radius * 0.8);
      ghostPath.quadraticBezierTo(
        center.dx + radius * 0.53, center.dy + radius * 0.6,
        center.dx + radius * 0.26, center.dy + radius * 0.8,
      );
      ghostPath.quadraticBezierTo(
        center.dx, center.dy + radius * 0.6,
        center.dx - radius * 0.26, center.dy + radius * 0.8,
      );
      ghostPath.quadraticBezierTo(
        center.dx - radius * 0.53, center.dy + radius * 0.6,
        center.dx - radius * 0.8, center.dy + radius * 0.8,
      );
      ghostPath.close();
      canvas.drawPath(ghostPath, paint);

      final whiteBorder = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04);
      canvas.drawPath(ghostPath, whiteBorder);
    } else {
      paint.color = color;
      if (isOutline) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = math.max(2.0, size.width * 0.07);
        canvas.drawCircle(center, radius - paint.strokeWidth / 2, paint);
      } else {
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(center, radius, paint);
        
        final whiteBorder = Paint()
          ..color = Colors.white.withOpacity(0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, size.width * 0.04);
        canvas.drawCircle(center, radius - whiteBorder.strokeWidth / 2, whiteBorder);
      }
    }

    // 3. Gambar Mata dan Mulut (Face Features)
    final facePaint = Paint()
      ..color = (isOutline ? color : const Color(0xFF2C2C2C))
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, size.width * 0.05)
      ..strokeCap = StrokeCap.round;

    final fillFacePaint = Paint()
      ..color = (isOutline ? color : const Color(0xFF2C2C2C))
      ..style = PaintingStyle.fill;

    // Koordinat mata
    final double eyeY = center.dy - radius * 0.1;
    final double eyeDist = radius * 0.35;

    switch (level) {
      case 1: // Sangat Buruk (Angry/Crying - >_< )
        // Mata Kiri '>'
        canvas.drawLine(Offset(center.dx - eyeDist - 3, eyeY - 3), Offset(center.dx - eyeDist + 3, eyeY), facePaint);
        canvas.drawLine(Offset(center.dx - eyeDist - 3, eyeY + 3), Offset(center.dx - eyeDist + 3, eyeY), facePaint);
        
        // Mata Kanan '<'
        canvas.drawLine(Offset(center.dx + eyeDist + 3, eyeY - 3), Offset(center.dx + eyeDist - 3, eyeY), facePaint);
        canvas.drawLine(Offset(center.dx + eyeDist + 3, eyeY + 3), Offset(center.dx + eyeDist - 3, eyeY), facePaint);

        // Mulut sedih meliuk (downturned wave)
        final mouthPath = Path()
          ..moveTo(center.dx - radius * 0.25, center.dy + radius * 0.35)
          ..quadraticBezierTo(
            center.dx, center.dy + radius * 0.1,
            center.dx + radius * 0.25, center.dy + radius * 0.35,
          );
        canvas.drawPath(mouthPath, facePaint);

        // Air Mata Biru Kecil (Hanya jika terisi)
        if (!isOutline) {
          final tearPaint = Paint()..color = const Color(0xFF60A5FA)..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(center.dx - eyeDist - 1, eyeY + 8), radius * 0.09, tearPaint);
          canvas.drawCircle(Offset(center.dx + eyeDist + 1, eyeY + 8), radius * 0.09, tearPaint);
        }
        break;

      case 2: // Buruk (Sad - 🙁 )
        // Mata berupa bulatan sedih kecil
        canvas.drawCircle(Offset(center.dx - eyeDist, eyeY), radius * 0.07, fillFacePaint);
        canvas.drawCircle(Offset(center.dx + eyeDist, eyeY), radius * 0.07, fillFacePaint);

        // Mulut cemberut melengkung ke bawah
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.38),
          width: radius * 0.45,
          height: radius * 0.35,
        );
        canvas.drawArc(mouthRect, math.pi, math.pi, false, facePaint);
        break;

      case 3: // Normal (Neutral - 😐 )
        // Mata titik bulat
        canvas.drawCircle(Offset(center.dx - eyeDist, eyeY), radius * 0.08, fillFacePaint);
        canvas.drawCircle(Offset(center.dx + eyeDist, eyeY), radius * 0.08, fillFacePaint);

        // Mulut garis lurus mendatar
        canvas.drawLine(
          Offset(center.dx - radius * 0.22, center.dy + radius * 0.28),
          Offset(center.dx + radius * 0.22, center.dy + radius * 0.28),
          facePaint,
        );
        break;

      case 4: // Baik (Happy - 🙂 )
        // Mata melengkung tersenyum (^ ^)
        final leftEyeRect = Rect.fromCenter(
          center: Offset(center.dx - eyeDist, eyeY + 1),
          width: radius * 0.22,
          height: radius * 0.16,
        );
        final rightEyeRect = Rect.fromCenter(
          center: Offset(center.dx + eyeDist, eyeY + 1),
          width: radius * 0.22,
          height: radius * 0.16,
        );
        canvas.drawArc(leftEyeRect, math.pi, math.pi, false, facePaint);
        canvas.drawArc(rightEyeRect, math.pi, math.pi, false, facePaint);

        // Mulut tersenyum kecil
        final mouthRect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.12),
          width: radius * 0.45,
          height: radius * 0.38,
        );
        canvas.drawArc(mouthRect, 0, math.pi, false, facePaint);
        break;

      case 5: // Sangat Baik (Very Happy / Excited - 😄 )
        // Mata melengkung bahagia
        final leftEyeRect = Rect.fromCenter(
          center: Offset(center.dx - eyeDist, eyeY + 1),
          width: radius * 0.24,
          height: radius * 0.18,
        );
        final rightEyeRect = Rect.fromCenter(
          center: Offset(center.dx + eyeDist, eyeY + 1),
          width: radius * 0.24,
          height: radius * 0.18,
        );
        canvas.drawArc(leftEyeRect, math.pi, math.pi, false, facePaint);
        canvas.drawArc(rightEyeRect, math.pi, math.pi, false, facePaint);

        // Mulut tertawa lebar terisi
        final mouthPath = Path()
          ..moveTo(center.dx - radius * 0.32, center.dy + radius * 0.1)
          ..lineTo(center.dx + radius * 0.32, center.dy + radius * 0.1)
          ..arcTo(
            Rect.fromCenter(
              center: Offset(center.dx, center.dy + radius * 0.1),
              width: radius * 0.64,
              height: radius * 0.5,
            ),
            0,
            math.pi,
            false,
          )
          ..close();
        
        if (isOutline) {
          canvas.drawPath(mouthPath, facePaint);
        } else {
          canvas.drawPath(mouthPath, Paint()..color = Colors.white..style = PaintingStyle.fill);
          canvas.drawPath(mouthPath, facePaint);
        }

        // Pipi Merah Muda Merona (Blush - jika terisi)
        if (!isOutline) {
          final blushPaint = Paint()..color = const Color(0xFFFDA4AF).withOpacity(0.75)..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(center.dx - eyeDist - 6, eyeY + 10), radius * 0.13, blushPaint);
          canvas.drawCircle(Offset(center.dx + eyeDist + 6, eyeY + 10), radius * 0.13, blushPaint);
        }
        break;
    }

    // Draw Cat Whiskers
    if (isCat) {
      final whiskerPaint = Paint()
        ..color = (isOutline ? color : const Color(0xFF2C2C2C))
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, size.width * 0.04)
        ..strokeCap = StrokeCap.round;

      // Whiskers Kiri
      canvas.drawLine(
        Offset(center.dx - radius * 0.55, center.dy + radius * 0.05),
        Offset(center.dx - radius * 0.88, center.dy + radius * 0.02),
        whiskerPaint,
      );
      canvas.drawLine(
        Offset(center.dx - radius * 0.55, center.dy + radius * 0.15),
        Offset(center.dx - radius * 0.85, center.dy + radius * 0.22),
        whiskerPaint,
      );

      // Whiskers Kanan
      canvas.drawLine(
        Offset(center.dx + radius * 0.55, center.dy + radius * 0.05),
        Offset(center.dx + radius * 0.88, center.dy + radius * 0.02),
        whiskerPaint,
      );
      canvas.drawLine(
        Offset(center.dx + radius * 0.55, center.dy + radius * 0.15),
        Offset(center.dx + radius * 0.85, center.dy + radius * 0.22),
        whiskerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
