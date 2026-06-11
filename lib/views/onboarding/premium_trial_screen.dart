import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/revenue_cat_service.dart';
import '../auth/widgets/doodle_background.dart';

class PremiumTrialScreen extends StatefulWidget {
  const PremiumTrialScreen({super.key});

  @override
  State<PremiumTrialScreen> createState() => _PremiumTrialScreenState();
}

class _PremiumTrialScreenState extends State<PremiumTrialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoading = false;
  Package? _annualPackage;

  @override
  void initState() {
    super.initState();
    // Animasi mengayun lambat untuk balon udara
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _loadOfferings();
  }

  /// Mengambil data penawaran (offerings) secara dinamis dari dashboard RevenueCat
  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);
    try {
      Offerings? offerings = await RevenueCatService.getOfferings();
      if (offerings != null && offerings.current != null) {
        _annualPackage = offerings.current!.annual ??
            (offerings.current!.availablePackages.isNotEmpty
                ? offerings.current!.availablePackages.first
                : null);
      }
    } catch (e) {
      debugPrint('Gagal memuat penawaran RevenueCat: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _proceedToLogin() {
    Provider.of<AuthProvider>(context, listen: false).completeTrialSetup();
  }

  void _goBack() {
    Provider.of<AuthProvider>(context, listen: false).resetTrialSetup();
  }

  /// Memulai alur pembelian nyata atau simulasi jika API Key belum terpasang
  Future<void> _startTrial() async {
    setState(() => _isLoading = true);
    try {
      bool success = await RevenueCatService.purchasePackage(_annualPackage);
      if (success) {
        if (mounted) {
          Provider.of<AuthProvider>(context, listen: false).setPremiumStatus(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selamat! Uji coba premium Anda telah aktif.'),
              backgroundColor: Color(0xFF00C9A7),
            ),
          );
          _proceedToLogin();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pembelian dibatalkan atau terjadi kesalahan.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saat melakukan pembelian: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoodleBackground(
        themeIndexOverride: 2, // Paksa tema gelap premium (Starry Night)
        child: SafeArea(
          child: Stack(
            children: [
              // Konten Utama
              Column(
                children: [
                  // 1. Header (Tombol Kembali & Tombol Close X)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: _isLoading ? null : _goBack,
                          tooltip: 'Kembali',
                        ),
                        // Tombol Close X dengan lingkaran transparan
                        InkWell(
                          onTap: _isLoading ? null : _proceedToLogin,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white12, width: 1),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Judul & Subjudul
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mulai Percobaan Gratis',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bagaimana cara kerja uji coba gratis kamu?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 3. Timeline & Konten
                  Expanded(
                    child: Stack(
                      children: [
                        // Ilustrasi Balon Udara Kustom di Pojok Kanan Bawah agar tidak menutupi teks
                        Positioned(
                          right: 10,
                          bottom: 20,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return SizedBox(
                                width: 140,
                                height: 200,
                                child: CustomPaint(
                                  painter: HotAirBalloonPainter(
                                    animationValue: _animationController.value,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Timeline Langkah-langkah
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTimelineStep(
                                icon: Icons.lock_open_rounded,
                                title: 'Hari Ini',
                                description:
                                    'Akses premium tidak terbatas aktif. Mulai jurnal harian, deteksi emosi awal, dan kustomisasi tema tanpa batasan.',
                                isLast: false,
                              ),
                              _buildTimelineStep(
                                icon: Icons.notifications_active_outlined,
                                title: 'Hari 5: Pengingat Uji Coba',
                                description:
                                    'Kami akan mengirimkan notifikasi pengingat. Anda memiliki waktu 2 hari lagi jika ingin membatalkan.',
                                isLast: false,
                              ),
                              _buildTimelineStep(
                                icon: Icons.star_rounded,
                                title: 'Hari 7: Uji Coba Berakhir',
                                description:
                                    'Masa langganan Anda akan dimulai. Batalkan kapan saja tanpa biaya, atau tetap gunakan versi gratis dengan fitur dasar.',
                                isLast: true,
                              ),
                              const SizedBox(height: 180), // Jarak agar tidak bertabrakan dengan balon di layar kecil
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Area Aksi & Pembayaran di Bagian Bawah
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090715).withOpacity(0.8),
                      border: const Border(
                        top: BorderSide(color: Colors.white10, width: 1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Keterangan Harga
                        const Center(
                          child: Text(
                            'Akses gratis tak terbatas selama 7 hari, lalu Rp 99.000 per tahun (hanya Rp 8.250/bulan)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tombol Utama "Mulai Uji Coba Gratis Saya"
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _startTrial,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C9A7), // Mint green matching reference
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Mulai uji coba gratis saya sekarang',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tombol "LEWATI"
                        Center(
                          child: TextButton(
                            onPressed: _isLoading ? null : _proceedToLogin,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                            ),
                            child: const Text(
                              'LEWATI',
                              style: TextStyle(
                                color: Colors.white38,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Overlay Indikator Memuat (Loading State)
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00C9A7),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String description,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Visual Timeline
        Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF00C9A7), // Mint Green
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 70, // Jarak antar langkah
                color: const Color(0xFF00C9A7).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 18),

        // Teks Deskripsi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // Penyelaras vertikal dengan ikon
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter untuk menggambar Balon Udara Lucu ("RiseUp") yang bergerak mengambang lembut
class HotAirBalloonPainter extends CustomPainter {
  final double animationValue;

  HotAirBalloonPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final loopVal = animationValue * 2 * math.pi;
    
    // Hitung posisi mengapung vertikal (floating) & sedikit goyangan
    final floatY = math.sin(loopVal) * 8.0;
    final tiltAngle = 0.03 * math.cos(loopVal);

    canvas.save();
    // Rotasi dan translasi untuk efek melayang
    canvas.translate(size.width / 2, size.height / 2 + floatY);
    canvas.rotate(tiltAngle);
    canvas.translate(-size.width / 2, -size.height / 2);

    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // Koordinat pusat balon
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.35;

    // 1. Menggambar Tali Penahan Keranjang (Ropes)
    final ropePaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(centerX - 12, centerY + 28), Offset(centerX - 8, centerY + 45), ropePaint);
    canvas.drawLine(Offset(centerX + 12, centerY + 28), Offset(centerX + 8, centerY + 45), ropePaint);

    // 2. Menggambar Keranjang Balon (Basket)
    paint.color = const Color(0xFFB45309); // Brown basket
    final basketRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY + 52), width: 22, height: 16),
      const Radius.circular(3),
    );
    canvas.drawRRect(basketRect, paint);

    // Detail keranjang (garis-garis kayu)
    paint.color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(centerX - 6, centerY + 44, 2, 16), paint);
    canvas.drawRect(Rect.fromLTWH(centerX + 4, centerY + 44, 2, 16), paint);

    // 3. Menggambar Kubah Balon Udara (Balloon Envelope)
    // Bagian balon dibentuk menggunakan Path agar menyerupai tetesan air terbalik
    final balloonPath = Path()
      ..moveTo(centerX, centerY - 48) // Atas balon
      ..cubicTo(centerX - 42, centerY - 48, centerX - 42, centerY + 10, centerX - 16, centerY + 30) // Sisi kiri
      ..lineTo(centerX + 16, centerY + 30) // Bawah datar
      ..cubicTo(centerX + 42, centerY + 10, centerX + 42, centerY - 48, centerX, centerY - 48) // Sisi kanan
      ..close();

    paint.color = const Color(0xFF6C63FF); // Warna dasar: Ungu RiseUp
    canvas.drawPath(balloonPath, paint);

    // 4. Menggambar Pola Garis Vertikal Balon (Gaya Retro Premium)
    final clipPath = Path()..addPath(balloonPath, Offset.zero);
    canvas.save();
    canvas.clipPath(clipPath);

    // Stripe Tengah (Mint Green / Teal)
    paint.color = const Color(0xFF00C9A7);
    final centerStripe = Path()
      ..moveTo(centerX, centerY - 48)
      ..cubicTo(centerX - 12, centerY - 48, centerX - 10, centerY + 10, centerX - 5, centerY + 30)
      ..lineTo(centerX + 5, centerY + 30)
      ..cubicTo(centerX + 10, centerY + 10, centerX + 12, centerY - 48, centerX, centerY - 48)
      ..close();
    canvas.drawPath(centerStripe, paint);

    // Stripe Kuning Emas di samping
    paint.color = const Color(0xFFFFD54F);
    final sideStripeLeft = Path()
      ..moveTo(centerX - 22, centerY - 48)
      ..cubicTo(centerX - 32, centerY - 48, centerX - 28, centerY + 10, centerX - 12, centerY + 30)
      ..lineTo(centerX - 8, centerY + 30)
      ..cubicTo(centerX - 20, centerY + 10, centerX - 18, centerY - 48, centerX - 22, centerY - 48)
      ..close();
    canvas.drawPath(sideStripeLeft, paint);

    final sideStripeRight = Path()
      ..moveTo(centerX + 22, centerY - 48)
      ..cubicTo(centerX + 32, centerY - 48, centerX + 28, centerY + 10, centerX + 12, centerY + 30)
      ..lineTo(centerX + 8, centerY + 30)
      ..cubicTo(centerX + 20, centerY + 10, centerX + 18, centerY - 48, centerX + 22, centerY - 48)
      ..close();
    canvas.drawPath(sideStripeRight, paint);

    canvas.restore(); // Lepas kliping

    // Border putih di sekujur balon agar terkesan bersih
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(balloonPath, strokePaint);

    // 5. Menggambar Wajah Imut di Balon (Cute Face)
    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Mata kiri & kanan senyum
    canvas.drawArc(Rect.fromCircle(center: Offset(centerX - 9, centerY - 4), radius: 2.5), math.pi, math.pi, false, facePaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(centerX + 9, centerY - 4), radius: 2.5), math.pi, math.pi, false, facePaint);

    // Mulut senang
    canvas.drawArc(Rect.fromCircle(center: Offset(centerX, centerY - 3), radius: 3.5), 0, math.pi, false, facePaint);

    // Pipi merona (blush)
    paint.color = const Color(0xFFFDA4AF).withOpacity(0.7);
    canvas.drawCircle(Offset(centerX - 13, centerY + 2), 3, paint);
    canvas.drawCircle(Offset(centerX + 13, centerY + 2), 3, paint);

    // 6. Awan Pendukung di Sekeliling Balon
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    
    // Awan Kiri
    canvas.drawCircle(Offset(centerX - 48, centerY + 32), 16, cloudPaint);
    canvas.drawCircle(Offset(centerX - 32, centerY + 40), 12, cloudPaint);
    
    // Awan Kanan
    canvas.drawCircle(Offset(centerX + 44, centerY + 20), 14, cloudPaint);
    canvas.drawCircle(Offset(centerX + 32, centerY + 26), 11, cloudPaint);

    // 7. Bintang/Sparkle Berkelip di Sekeliling Balon
    final sparklePulse = 0.5 + 0.5 * math.sin(loopVal * 1.5);
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.3 + 0.6 * sparklePulse)
      ..style = PaintingStyle.fill;

    _drawSparkle(canvas, Offset(centerX - 42, centerY - 50), 5, sparklePaint);
    _drawSparkle(canvas, Offset(centerX + 46, centerY - 25), 6, sparklePaint);

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

  @override
  bool shouldRepaint(covariant HotAirBalloonPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
