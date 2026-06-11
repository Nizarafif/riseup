import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/widgets/doodle_background.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderSetupScreen extends StatefulWidget {
  const ReminderSetupScreen({super.key});

  @override
  State<ReminderSetupScreen> createState() => _ReminderSetupScreenState();
}

class _ReminderSetupScreenState extends State<ReminderSetupScreen> {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0); // Default jam 8 malam (20:00)

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF3F3D56),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6C63FF),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked != _reminderTime) {
        setState(() {
          _reminderTime = picked;
        });
      }
      
      // Otomatis memicu pop-up izin notifikasi setelah mengatur jam
      try {
        await Permission.notification.request();
      } catch (e) {
        debugPrint('Gagal meminta izin notifikasi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDarkBg = authProvider.selectedBackgroundThemeIndex == 2;
    final textColor = isDarkBg ? Colors.white : const Color(0xFF3F3D56);
    final subtitleColor = isDarkBg ? Colors.white70 : const Color(0xFF707070);

    return Scaffold(
      body: DoodleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Header dengan Indikator Langkah (Titik Ketiga Aktif) & Tombol Kembali
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                      onPressed: () {
                        authProvider.resetReminderSetup();
                      },
                      tooltip: 'Kembali',
                    ),
                    // Indikator Halaman (3 titik, titik ketiga aktif)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48), // Spacer penyeimbang tombol back
                  ],
                ),
              ),

              // 2. Judul dan Subjudul
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Jadwalkan Waktu Refleksi Anda',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Membangun kebiasaan mencatat jurnal harian membantu Anda memahami pola emosi secara konsisten. Jadwalkan pengingat harian pada waktu yang paling sesuai bagi Anda.',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 3. Ilustrasi Jam Kustom Dinamis
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: InteractiveClockPainter(time: _reminderTime),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Card Set Pengingat Waktu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                  decoration: BoxDecoration(
                    color: isDarkBg 
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: isDarkBg ? Colors.white12 : Colors.grey.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54F).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFFFACC15),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengingat Harian',
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _selectTime(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF6C63FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              'Ubah',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Anda dapat menambahkan atau mengubah pengingat lain nanti melalui pengaturan di dalam aplikasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: subtitleColor.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 5. Tombol Aksi "Mulai Sekarang" (Pill Kuning di Bagian Bawah)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await Permission.notification.request();
                      } catch (e) {
                        debugPrint('Gagal meminta izin notifikasi: $e');
                      }
                      authProvider.completeReminderSetup(_reminderTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F),
                      foregroundColor: const Color(0xFF2C2C2C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Berikutnya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
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
}

class InteractiveClockPainter extends CustomPainter {
  final TimeOfDay time;

  InteractiveClockPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()..isAntiAlias = true;

    // 1. Gambar Ring Jam Luar (Emas/Kuning Premium dengan bayangan lembut)
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFFFD54F);
    canvas.drawCircle(center, radius, paint);

    // 2. Gambar Border Emas Lebih Gelap/Tegas
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0;
    paint.color = const Color(0xFFFACC15);
    canvas.drawCircle(center, radius - 2, paint);

    // 3. Gambar Latar Belakang Face Jam (Cream/Mulus)
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFFFFBEB);
    canvas.drawCircle(center, radius - 10, paint);

    // 4. Gambar Tanda Jam (Ticks)
    final tickPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final isMajor = i % 3 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;
      tickPaint.strokeWidth = isMajor ? 3.0 : 1.5;

      final startX = center.dx + (radius - 22) * math.cos(angle);
      final startY = center.dy + (radius - 22) * math.sin(angle);
      final endX = center.dx + (radius - 22 - tickLength) * math.cos(angle);
      final endY = center.dy + (radius - 22 - tickLength) * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // 5. Hitung Sudut Jarum Jam
    // Jarum Jam (bergeser halus berdasarkan menit)
    final hourAngle = ((time.hour % 12) * 30 + (time.minute * 0.5)) * math.pi / 180 - (math.pi / 2);
    // Jarum Menit
    final minuteAngle = (time.minute * 6) * math.pi / 180 - (math.pi / 2);

    // 6. Gambar Jarum Jam
    final hourHandPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    
    final hourHandLength = radius * 0.52;
    canvas.drawLine(
      center,
      Offset(
        center.dx + hourHandLength * math.cos(hourAngle),
        center.dy + hourHandLength * math.sin(hourAngle),
      ),
      hourHandPaint,
    );

    // 7. Gambar Jarum Menit
    final minuteHandPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final minuteHandLength = radius * 0.72;
    canvas.drawLine(
      center,
      Offset(
        center.dx + minuteHandLength * math.cos(minuteAngle),
        center.dy + minuteHandLength * math.sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    // 8. Gambar Pin Tengah (Central Hub)
    final hubPaint = Paint()..style = PaintingStyle.fill;
    hubPaint.color = const Color(0xFF78350F);
    canvas.drawCircle(center, 7, hubPaint);
    hubPaint.color = const Color(0xFFFFD54F);
    canvas.drawCircle(center, 3, hubPaint);
  }

  @override
  bool shouldRepaint(covariant InteractiveClockPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
