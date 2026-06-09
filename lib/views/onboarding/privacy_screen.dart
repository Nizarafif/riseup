import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';
import '../auth/widgets/doodle_background.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Animasi kontinu lambat untuk efek goyangan gembok (wiggle)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPrivacyPolicyDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(Icons.shield_outlined, color: Color(0xFF6C63FF), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Kebijakan Privasi Lengkap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F3D56),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('1. Informasi yang Kami Kumpulkan'),
                      _buildSectionContent(
                          'Kami mengumpulkan catatan emosi harian (mood) dan respons kuesioner Anda untuk memproses analisis sistem pakar demi mendeteksi kondisi kesehatan mental awal Anda.'),
                      const SizedBox(height: 16),
                      _buildSectionTitle('2. Kerahasiaan & Keamanan Data'),
                      _buildSectionContent(
                          'Semua data Anda disimpan secara aman. Kami menggunakan enkripsi modern untuk menjaga data Anda tetap privat. Data analisis ini hanya dapat diakses oleh Anda secara pribadi dan tidak akan dibagikan ke pihak ketiga tanpa izin eksplisit.'),
                      const SizedBox(height: 16),
                      _buildSectionTitle('3. Penggunaan Mock & Offline Mode'),
                      _buildSectionContent(
                          'Jika aplikasi berjalan dalam mode demo/simulasi tanpa koneksi Firebase aktif, data yang dimasukkan bersifat sementara dan hanya berada di memori perangkat Anda saat sesi aktif.'),
                      const SizedBox(height: 16),
                      _buildSectionTitle('4. Hak Pengguna'),
                      _buildSectionContent(
                          'Anda memiliki kontrol penuh atas akun Anda. Anda berhak menghapus data mood dan riwayat diagnosa kapan saja melalui menu pengaturan akun Anda.'),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.black12),
                      const SizedBox(height: 8),
                      const Text(
                        'Dengan menyetujui, Anda mempercayakan perlindungan kesehatan mental dan privasi Anda bersama kami di RiseUp.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3F3D56),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF707070),
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoodleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Ilustrasi Gembok Custom Paint (Menari/Mengayun Lembut)
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return SizedBox(
                          height: 180,
                          width: 180,
                          child: CustomPaint(
                            painter: PrivacyIllustrationPainter(
                              animationValue: _animationController.value,
                              themeColor: const Color(0xFF6C63FF),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Kami Menjaga Privasi Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3F3D56),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sebelum melangkah lebih jauh di RiseUp, kami berkomitmen untuk melindungi segala bentuk data kesehatan mental, catatan harian, dan hasil diagnosis Anda dengan standar keamanan terbaik.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF707070),
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tombol Baca Selengkapnya
                  Center(
                    child: TextButton(
                      onPressed: _showPrivacyPolicyDetail,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Baca Selengkapnya',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: Color(0xFF6C63FF), size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Card Transparan untuk tombol aksi agar terlihat gemoy
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tombol Setuju (Utama)
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .acceptPrivacy();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Setuju & Lanjutkan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Tombol Tidak Setuju (Kembali ke Onboarding)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Provider.of<AuthProvider>(context, listen: false)
                                  .rejectPrivacy();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                            ),
                            child: const Text(
                              'Tidak Setuju, Kembali',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Painter untuk menggambar Ilustrasi Gembok Lucu yang bergoyang
class PrivacyIllustrationPainter extends CustomPainter {
  final double animationValue;
  final Color themeColor;

  PrivacyIllustrationPainter({
    required this.animationValue,
    required this.themeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final loopVal = animationValue * 2 * math.pi;

    // Hitung kemiringan gembok
    final rotationAngle = 0.06 * math.sin(loopVal);

    canvas.save();
    // Lakukan rotasi di titik pusat ilustrasi
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()..isAntiAlias = true;

    // 1. Gambar kilau manis (Sparkles/Stars) di sekeliling gembok
    final sparklePulse = 0.6 + 0.4 * math.sin(loopVal * 1.5);
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFD460).withOpacity(sparklePulse)
      ..style = PaintingStyle.fill;
    
    // Sparkle 1 (Top Left)
    _drawSparkle(canvas, Offset(center.dx - 50, center.dy - 55), 6, sparklePaint);
    // Sparkle 2 (Bottom Right)
    _drawSparkle(canvas, Offset(center.dx + 55, center.dy + 45), 7, sparklePaint);
    // Love kecil (Top Right)
    _drawMiniHeart(canvas, Offset(center.dx + 45, center.dy - 45), 8, loopVal);

    // 2. Gambar Belenggu Gembok (Lock Shackle / U-shape)
    final shacklePaint = Paint()
      ..color = const Color(0xFFCBD5E1) // Soft Gray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final shacklePath = Path()
      ..moveTo(center.dx - 30, center.dy + 5)
      ..lineTo(center.dx - 30, center.dy - 35)
      ..arcTo(
        Rect.fromCircle(center: Offset(center.dx, center.dy - 35), radius: 30),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(center.dx + 30, center.dy - 35)
      ..lineTo(center.dx + 30, center.dy + 5);

    canvas.drawPath(shacklePath, shacklePaint);

    // 3. Gambar Badan Gembok Chubby (Rounded Card/Square)
    paint.color = themeColor.withOpacity(0.15);
    final bodyShadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center + const Offset(0, 15), width: 90, height: 75),
      const Radius.circular(24),
    );
    // Efek shadow lembut
    canvas.drawRRect(bodyShadowRect.shift(const Offset(0, 6)), Paint()..color = themeColor.withOpacity(0.08)..style = PaintingStyle.fill);

    // Badan gembok utama
    paint.color = themeColor;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(bodyShadowRect, paint);

    // Stroke badan gembok agar terlihat menonjol
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(bodyShadowRect, borderPaint);

    // 4. Gambar Lubang Kunci (Keyhole)
    final keyholePaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    
    // Lingkaran atas lubang kunci
    canvas.drawCircle(Offset(center.dx, center.dy + 15), 8, keyholePaint);
    // Lubang bawah segitiga
    final keyholePath = Path()
      ..moveTo(center.dx - 4, center.dy + 15)
      ..lineTo(center.dx + 4, center.dy + 15)
      ..lineTo(center.dx + 7, center.dy + 30)
      ..lineTo(center.dx - 7, center.dy + 30)
      ..close();
    canvas.drawPath(keyholePath, keyholePaint);

    // 5. Gambar Wajah Imut pada Gembok (Cute Face)
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Mata Kiri (berkedip/senyum)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx - 22, center.dy + 5), radius: 3.5),
      math.pi,
      math.pi,
      false,
      facePaint,
    );
    // Mata Kanan
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx + 22, center.dy + 5), radius: 3.5),
      math.pi,
      math.pi,
      false,
      facePaint,
    );

    // Mulut Senang
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 5), radius: 4.5),
      0,
      math.pi,
      false,
      facePaint,
    );

    // Pipi Merah Muda Lucu (Blush)
    final cheekPaint = Paint()
      ..color = const Color(0xFFFDA4AF).withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 28, center.dy + 12), 4, cheekPaint);
    canvas.drawCircle(Offset(center.dx + 28, center.dy + 12), 4, cheekPaint);

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset offset, double size, Paint paint) {
    final path = Path()
      ..moveTo(offset.dx, offset.dy - size)
      ..lineTo(offset.dx + size * 0.25, offset.dy - size * 0.25)
      ..lineTo(offset.dx + size, offset.dy)
      ..lineTo(offset.dx + size * 0.25, offset.dy + size * 0.25)
      ..lineTo(offset.dx, offset.dy + size)
      ..lineTo(offset.dx - size * 0.25, offset.dy + size * 0.25)
      ..lineTo(offset.dx - size, offset.dy)
      ..lineTo(offset.dx - size * 0.25, offset.dy - size * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawMiniHeart(Canvas canvas, Offset center, double size, double loopVal) {
    final heartPulse = 1.0 + 0.15 * math.sin(loopVal * 2.0);
    final pulseSize = size * heartPulse;
    final paint = Paint()
      ..color = const Color(0xFFFDA4AF).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy + pulseSize * 0.35);
    path.cubicTo(
      center.dx - pulseSize * 0.6, center.dy - pulseSize * 0.5,
      center.dx - pulseSize * 1.1, center.dy + pulseSize * 0.2,
      center.dx, center.dy + pulseSize * 0.95,
    );
    path.cubicTo(
      center.dx + pulseSize * 1.1, center.dy + pulseSize * 0.2,
      center.dx + pulseSize * 0.6, center.dy - pulseSize * 0.5,
      center.dx, center.dy + pulseSize * 0.35,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PrivacyIllustrationPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
